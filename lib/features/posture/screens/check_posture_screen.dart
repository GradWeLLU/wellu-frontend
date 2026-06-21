import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imglib;

// ==========================================
// 🚀 1. OPTIMIZED INFERENCE SERVICE
// ==========================================
class InferenceService {
  // ⚠️ IMPORTANT: Change this to your computer's local IPv4 address!
  final String baseUrl = "http://10.0.2.2:8000";

  // Persistent client for super-fast network speeds
  final http.Client _client = http.Client();

  Future<void> sendStreamFrame(List<int> jpegBytes) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/upload_frame'),
        headers: {'Content-Type': 'application/octet-stream'},
        body: jpegBytes,
      ).timeout(const Duration(milliseconds: 500));
    } catch (e) {
      // Silently catch to avoid dropping frames
    }
  }

  Future<Map<String, dynamic>> fetchResult() async {
    try {
      final response = await _client.get(
          Uri.parse('$baseUrl/result')
      ).timeout(const Duration(milliseconds: 500));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // Silently catch
    }
    return {"status": "error"};
  }
}

// ==========================================
// ⚡ BACKGROUND ISOLATE: YUV to JPEG
// ==========================================
List<int> convertCameraImageToJpeg(CameraImage image) {
  try {
    imglib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      // Android
      final int width = image.width;
      final int height = image.height;
      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel!;
      img = imglib.Image(width: width, height: height);

      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * image.planes[0].bytesPerRow + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];

          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

          img.setPixelRgb(x, y, r, g, b);
        }
      }
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      // iOS
      img = imglib.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: image.planes[0].bytes.buffer,
        order: imglib.ChannelOrder.bgra,
      );
    } else {
      return [];
    }
    // Drop quality to 60% for fast network transport
    return imglib.encodeJpg(img, quality: 60);
  } catch (e) {
    return [];
  }
}

// ==========================================
// 📱 MAIN UI WIDGET
// ==========================================
class PoseDetectorScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String exerciseTitle;

  const PoseDetectorScreen({
    Key? key,
    required this.cameras,
    required this.exerciseTitle,
  }) : super(key: key);

  @override
  State<PoseDetectorScreen> createState() => _PoseDetectorScreenState();
}

class _PoseDetectorScreenState extends State<PoseDetectorScreen> {
  late CameraController _controller;
  final InferenceService _api = InferenceService();

  bool _isProcessingFrame = false;
  int _lastFrameTime = 0;

  bool _isFetchingResult = false;
  Map<String, dynamic> _lastResult = {};
  Map<String, dynamic>? _lastRepDisplay;
  DateTime? _lastRepTime;

  Timer? _resultPollingTimer;

  // Hold "rep_done" messages on screen for 2.5 seconds
  static const int displayDurationMs = 2500;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startResultPolling();
  }

  Future<void> _initCamera() async {
    final camera = widget.cameras.length > 1 ? widget.cameras[1] : widget.cameras[0];
    _controller = CameraController(camera, ResolutionPreset.low, enableAudio: false);

    await _controller.initialize();
    if (!mounted) return;

    setState(() {});
    _startLiveStream();
  }

  void _startResultPolling() {
    _resultPollingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (_isFetchingResult) return;

      _isFetchingResult = true;
      try {
        final result = await _api.fetchResult();
        if (!mounted) return;

        final now = DateTime.now();
        setState(() {
          if (result['status'] == 'rep_done') {
            _lastRepDisplay = result;
            _lastRepTime = now;
          }
          _lastResult = result;
        });
      } finally {
        _isFetchingResult = false;
      }
    });
  }

  void _startLiveStream() {
    _controller.startImageStream((CameraImage image) async {
      if (_isProcessingFrame) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      // 🔥 UPDATED SPEED LIMIT: 40ms gives us a clean ~25 FPS!
      if (now - _lastFrameTime < 40) return;

      _isProcessingFrame = true;
      _lastFrameTime = now;

      try {
        final List<int> jpegBytes = await compute(convertCameraImageToJpeg, image);

        if (jpegBytes.isNotEmpty) {
          await _api.sendStreamFrame(jpegBytes);
        }
      } catch (e) {
        print("Stream processing error: $e");
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Map<String, dynamic> get _currentDisplayData {
    if (_lastRepDisplay != null && _lastRepTime != null) {
      final diff = DateTime.now().difference(_lastRepTime!).inMilliseconds;
      if (diff < displayDurationMs) {
        return _lastRepDisplay!;
      }
    }
    return _lastResult;
  }

  @override
  void dispose() {
    _resultPollingTimer?.cancel();
    _controller.stopImageStream();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD946EF))),
      );
    }

    final data = _currentDisplayData;
    final int reps = data['rep_count'] ?? 0;

    final dynamic rawFeedback = data['feedback'];
    List<String> feedbackLines = [];

    if (rawFeedback is List && rawFeedback.isNotEmpty) {
      feedbackLines = rawFeedback.map((e) => e.toString()).toList();
    } else if (rawFeedback is String && rawFeedback.isNotEmpty) {
      feedbackLines = [rawFeedback];
    } else {
      feedbackLines = ["Analyzing your form..."];
    }

    final List<dynamic>? landmarks = data['landmarks'] as List<dynamic>?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Feed
          CameraPreview(_controller),

          // 2. ✨ SKELETON LAYER
          if (landmarks != null)
            Positioned.fill(
              child: CustomPaint(
                painter: SkeletonPainter(landmarks),
              ),
            ),

          // 3. UI Layer
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Main Dashboard
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F0FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.exerciseTitle,
                                    style: const TextStyle(
                                      color: Color(0xFFA855F7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Reps: $reps",
                                    style: const TextStyle(
                                      color: Color(0xFF4338CA),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Text(
                              "WellU Live Feedback",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ...feedbackLines.map((line) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4, right: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFD946EF),
                                      size: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      line,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🎨 SKELETON PAINTER
// ==========================================
class SkeletonPainter extends CustomPainter {
  final List<dynamic> landmarks;

  SkeletonPainter(this.landmarks);

  static const List<List<int>> _poseConnections = [
    [0, 1], [1, 2], [2, 3], [3, 7], [0, 4], [4, 5], [5, 6], [6, 8], [9, 10],
    [11, 12], [11, 13], [13, 15], [15, 17], [15, 19], [15, 21], [17, 19],
    [12, 14], [14, 16], [16, 18], [16, 20], [16, 22], [18, 20], [11, 23],
    [12, 24], [23, 24], [23, 25], [24, 26], [25, 27], [26, 28], [27, 29],
    [28, 30], [29, 31], [30, 32], [27, 31], [28, 32]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    List<Offset> points = [];
    for (var lm in landmarks) {
      if (lm is Map<String, dynamic>) {
        double x = (lm['x'] as num).toDouble() * size.width;
        double y = (lm['y'] as num).toDouble() * size.height;
        points.add(Offset(x, y));
      }
    }

    for (var connection in _poseConnections) {
      int startIdx = connection[0];
      int endIdx = connection[1];

      if (startIdx < points.length && endIdx < points.length) {
        canvas.drawLine(points[startIdx], points[endIdx], linePaint);
      }
    }

    for (var point in points) {
      canvas.drawCircle(point, 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) {
    return true;
  }
}
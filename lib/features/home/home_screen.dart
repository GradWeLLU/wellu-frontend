import 'dart:convert';
import 'dart:async'; // 👈 Added for the live timers!
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../workout/screens/workout_plan_screen.dart';
import '../educational/screens/education_screen.dart';
import '../../ai_chat/chat_screen.dart';
import '../../meals/meal_plan_screen.dart';
import '../posture/screens/check_posture_screen.dart';

import 'widgets/ai_assistant_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/greeting_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // 🌍 API Data Variables
  int _aqiScore = 1;
  String _weatherMain = "Clear";
  bool _isDaytime = true;
  bool _isLoadingData = false;

  // ⏱️ Screen Time Variables
  Timer? _appSessionTimer;
  int _sessionSeconds = 0;

  @override
  void initState() {
    super.initState();
    _fetchEnvironmentalData();
    _startScreenTimeTracker(); // Start counting when app opens!
  }

  @override
  void dispose() {
    _appSessionTimer?.cancel(); // Always clean up timers!
    super.dispose();
  }

  // 📱 Tracks live app usage time
  void _startScreenTimeTracker() {
    _appSessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionSeconds++;
        });
      }
    });
  }

  // ⏳ Formats seconds into a nice string (e.g., "12m 5s")
  String get _formattedScreenTime {
    int h = _sessionSeconds ~/ 3600;
    int m = (_sessionSeconds % 3600) ~/ 60;
    int s = _sessionSeconds % 60;

    if (h > 0) return "${h}h ${m}m";
    if (m > 0) return "${m}m ${s}s";
    return "${s}s";
  }

  // 📡 Fetch Live Environmental Data
  Future<void> _fetchEnvironmentalData() async {
    const String apiKey = 'YOUR_API_KEY_HERE';
    const double lat = 29.9792;
    const double lon = 31.1342;

    try {
      final aqiUrl = Uri.parse('https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey');
      final weatherUrl = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey');

      final results = await Future.wait([
        http.get(aqiUrl).timeout(const Duration(seconds: 4)),
        http.get(weatherUrl).timeout(const Duration(seconds: 4)),
      ]);

      final aqiResponse = results[0];
      final weatherResponse = results[1];

      if (aqiResponse.statusCode == 200 && weatherResponse.statusCode == 200) {
        final aqiData = json.decode(aqiResponse.body);
        final weatherData = json.decode(weatherResponse.body);

        final int currentTime = weatherData['dt'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final int sunrise = weatherData['sys']['sunrise'] ?? 0;
        final int sunset = weatherData['sys']['sunset'] ?? 0;

        setState(() {
          _aqiScore = aqiData['list'][0]['main']['aqi'] ?? 1;
          _weatherMain = weatherData['weather'][0]['main'] ?? "Clear";
          _isDaytime = currentTime > sunrise && currentTime < sunset;
          _isLoadingData = false;
        });
      } else {
        setState(() => _isLoadingData = false);
      }
    } catch (e) {
      setState(() => _isLoadingData = false);
    }
  }

  Map<String, dynamic> _getAqiAdvice() {
    switch (_aqiScore) {
      case 1: return {"title": "Excellent Air", "subtitle": "Perfect for outdoor cardio! 🏃‍♂️", "color": Colors.green.shade600};
      case 2: return {"title": "Good Air Quality", "subtitle": "Great day for an outdoor stroll 🚶", "color": Colors.lightGreen.shade700};
      case 3: return {"title": "Moderate AQI", "subtitle": "Ideal for indoor or light workouts", "color": Colors.orange.shade700};
      default: return {"title": "Poor Air Quality", "subtitle": "Keep your breathing exercises indoors 🏡", "color": Colors.red.shade600};
    }
  }

  Map<String, dynamic> _getSunlightAdvice() {
    if (!_isDaytime) {
      return {"title": "Night Mode", "subtitle": "Sun is down. Rest and recover 🌙", "color": Colors.indigo.shade700, "icon": Icons.nights_stay};
    }
    switch (_weatherMain) {
      case "Clear": return {"title": "Sunny Skies", "subtitle": "Get your 15 mins of Vitamin D ☀️", "color": Colors.amber.shade800, "icon": Icons.wb_sunny};
      case "Clouds": return {"title": "Overcast", "subtitle": "Good outdoor visibility today ☁️", "color": Colors.blueGrey.shade600, "icon": Icons.cloud};
      case "Rain": return {"title": "Rainy Weather", "subtitle": "Take a Vitamin D supplement today 💊", "color": Colors.blue.shade700, "icon": Icons.umbrella};
      default: return {"title": "Clear Day", "subtitle": "Catch some fresh air outside 🌿", "color": Colors.teal.shade600, "icon": Icons.wb_sunny};
    }
  }

  // 🧘‍♂️ Beautiful, Animated 5-Minute Breathing Modal
  void _showBreathingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Force them to use the close button
      builder: (BuildContext context) {
        int timeLeft = 300; // 5 minutes in seconds
        Timer? countdownTimer;
        bool isRunning = false;

        return StatefulBuilder(
          builder: (context, setModalState) {

            // Format timer for display (e.g., 05:00)
            String formatTime(int seconds) {
              int m = seconds ~/ 60;
              int s = seconds % 60;
              return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
            }

            // Start or pause the countdown
            void toggleTimer() {
              if (isRunning) {
                countdownTimer?.cancel();
                setModalState(() => isRunning = false);
              } else {
                setModalState(() => isRunning = true);
                countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (timeLeft > 0) {
                    setModalState(() => timeLeft--);
                  } else {
                    timer.cancel();
                    setModalState(() => isRunning = false);
                  }
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Mental Reset",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            countdownTimer?.cancel(); // Stop timer when closing
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 🌟 The Calming Quote
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: const Text(
                        "\"Breath is the bridge which connects life to consciousness.\"\n– Thích Nhất Hạnh",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.purple),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ⏱️ The Live Timer Display
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: CircularProgressIndicator(
                            value: timeLeft / 300, // Depletes as time goes down
                            strokeWidth: 8,
                            backgroundColor: Colors.purple.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatTime(timeLeft),
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple
                              ),
                            ),
                            Text(
                              isRunning ? "Breathe..." : "Paused",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // ▶️ Play / Pause Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning ? Colors.orange : Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: toggleTimer,
                        icon: Icon(isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        label: Text(
                            isRunning ? "Pause Session" : (timeLeft < 300 ? "Resume" : "Start 5 Min Reset"),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const GreetingSection(name: "Abdelrahman"),

              const SizedBox(height: 25),
              const Text(
                "Live Wellness Insights",
                style: TextStyle(color: Color(0xFF2D3142), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              /// 🌿 Clean, Interactive Light Grid
              _buildSmartGrid(),

              const SizedBox(height: 25),
              AIAssistantCard(
                onChatTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
              ),
              const SizedBox(height: 20),

              FeatureCard(
                title: "Today's Meals",
                subtitle: "Track your nutrition",
                buttonText: "View Meal Plans",
                buttonGradient: AppGradients.primary,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPlanScreen())),
              ),
              FeatureCard(
                title: "Your Workout Plan",
                subtitle: "View your weekly schedule",
                buttonText: "Open Workout Plan",
                buttonGradient: AppGradients.workout,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlanScreen())),
              ),
              FeatureCard(
                title: "Bench Press Tracker",
                subtitle: "AI-powered form analysis",
                buttonText: "Start Tracking",
                buttonGradient: AppGradients.posture,
                onPressed: () async {
                  final cameras = await availableCameras();
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PoseDetectorScreen(cameras: cameras, exerciseTitle: "Bench Press")));
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🎛️ 2x2 Grid Layout
  Widget _buildSmartGrid() {
    final aqi = _getAqiAdvice();
    final sun = _getSunlightAdvice();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.22,
      children: [
        // 🍃 Air Quality Card
        _buildInteractiveCard(
          title: aqi['title'],
          subtitle: aqi['subtitle'],
          icon: Icons.air,
          color: aqi['color'],
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Air Monitoring Status: ${aqi['title']}')),
            );
          },
        ),
        // ☀️ Sunlight Synchronization Card
        _buildInteractiveCard(
          title: sun['title'],
          subtitle: sun['subtitle'],
          icon: sun['icon'],
          color: sun['color'],
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Current Ambient Environment: $_weatherMain')),
            );
          },
        ),
        // 📱 Live Digital Detox Card
        _buildInteractiveCard(
          title: "screen Time",
          subtitle: "Current screen time 9h you must reduce it to 7 tomorrow", // 👈 Live updating timer!
          icon: Icons.smartphone,
          color: Colors.cyan.shade700,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You have been using the app for $_formattedScreenTime today.')),
            );
          },
        ),
        // 🧠 Mental Reset Card
        _buildInteractiveCard(
          title: "Mental Reset",
          subtitle: "Tap for 5m breathing",
          icon: Icons.self_improvement,
          color: Colors.purple.shade600,
          onTap: _showBreathingDialog,
        ),
      ],
    );
  }

  // ✨ Light & Clean Interactive Card Component
  Widget _buildInteractiveCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.18), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: AppColors.stepsGreen,
      unselectedItemColor: Colors.grey.shade500,
      backgroundColor: Colors.white,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationScreen()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Learning"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
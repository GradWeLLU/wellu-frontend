import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutLogDetailScreen extends StatefulWidget {
  final String logId;
  final String workoutDate;

  const WorkoutLogDetailScreen({
    super.key,
    required this.logId,
    required this.workoutDate
  });

  @override
  State<WorkoutLogDetailScreen> createState() => _WorkoutLogDetailScreenState();
}

class _WorkoutLogDetailScreenState extends State<WorkoutLogDetailScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _completedExercises = [];

  @override
  void initState() {
    super.initState();
    _loadLogDetails();
  }

  Future<void> _loadLogDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8081/exerciseLogs/${widget.logId}'),
        headers: {'Authorization': 'Bearer $myToken'},
      );

      if (response.statusCode == 200) {
        final logData = json.decode(response.body);
        setState(() {
          // Check for 'entries' or 'exerciseEntries' based on your backend
          _completedExercises = logData['entries'] ?? logData['exerciseEntries'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load details.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error connecting to server.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "Workout on ${widget.workoutDate}",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    if (_completedExercises.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text("No exercises logged for this day.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _completedExercises.length,
      itemBuilder: (context, index) {
        final entry = _completedExercises[index];
        bool isCardio = entry['type'] == 'CARDIO';

        // 📦 Grab the sets list safely
        List<dynamic> setsList = entry['sets'] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align to top since the list can get tall
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFF22E1A0).withOpacity(0.2),
                    shape: BoxShape.circle
                ),
                child: Icon(
                    isCardio ? Icons.directions_run : Icons.fitness_center,
                    color: const Color(0xFF22E1A0)
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        entry['exerciseName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 6),

                    // 🔀 Display logic: Cardio vs Strength
                    if (isCardio)
                      Text(
                          "${entry['durationMinutes']} mins • ${entry['distanceKm']} km",
                          style: const TextStyle(color: Colors.grey, fontSize: 13)
                      )
                    else ...[
                      Text(
                          "${setsList.length} Sets Completed:",
                          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 6),

                      // 🔄 Loop through the sets and display the reps and weight!
                      ...setsList.asMap().entries.map((setEntry) {
                        int setNum = setEntry.key + 1; // Array index starts at 0, so add 1
                        var setData = setEntry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6)
                                ),
                                child: Text("Set $setNum", style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  "${setData['reps']} reps  ${setData['weight']} kg",
                                  style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
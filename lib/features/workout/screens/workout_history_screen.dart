import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'workout_log_detail_screen.dart'; // 👈 Make sure to import the detail screen!

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _allLoggedDays = [];

  @override
  void initState() {
    super.initState();
    _loadAllLogs();
  }

  Future<void> _loadAllLogs() async {
    const String baseUrl = 'http://10.0.2.2:8081/exerciseLogs';
    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $myToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> logs = json.decode(response.body);

        // Sort the logs so the newest date is at the top!
        logs.sort((a, b) => b['workoutDate'].compareTo(a['workoutDate']));

        setState(() {
          _allLoggedDays = logs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load history.";
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    if (_allLoggedDays.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
              "You haven't logged any workouts yet. Time to get started! 💪",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16)
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _allLoggedDays.length,
      itemBuilder: (context, index) {
        final log = _allLoggedDays[index];
        final String date = log['workoutDate'] ?? 'Unknown Date';
        // Handle UUIDs safely
        final String logId = (log['id'] ?? log['logId']).toString();

        return GestureDetector(
          onTap: () {
            // 🚀 Navigate to the Details Screen when a day is tapped!
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutLogDetailScreen(
                  logId: logId,
                  workoutDate: date,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5)
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withOpacity(0.15),
                      shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.calendar_month, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Workout Session",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 4),
                      Text(
                          date,
                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
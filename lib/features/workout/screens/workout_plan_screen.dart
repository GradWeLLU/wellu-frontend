import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_plan_model2.dart';
import 'ActiveWorkoutScreen2.dart'; // Ensure this points to the file above!
import 'workout_history_screen.dart'; // Make sure you created this file!

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  WorkoutResponse? _workoutResponse;
  bool _isLoading = true;
  String? _error;

  // 🔄 Toggle State!
  bool isPlanSelected = true;

  int _currentDayIndex = 0;
  final Set<int> _completedDays = {};

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    const String apiUrl = 'http://10.0.2.2:8082/workouts/plans';
    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) {
      setState(() {
        _error = "Session expired. Please log in again.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
      );

      print("🌐 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        setState(() {
          if (decodedData is List && decodedData.isNotEmpty) {
            _workoutResponse = WorkoutResponse.fromJson(decodedData[0]);
          } else if (decodedData is Map<String, dynamic>) {
            _workoutResponse = WorkoutResponse.fromJson(decodedData);
          } else {
            _error = "No workout plans found.";
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Server error (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("🚨 MODEL MAPPING ERROR: $e");
      setState(() {
        _error = "Failed to process workout data.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Error: $_error",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_workoutResponse == null) {
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F4F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Workout Plan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🎚️ The Toggle Switch
          _buildToggleSwitch(),

          // 🔀 Swaps between Plan and Logs!
          // 🔀 Swaps between Plan and Logs!
          Expanded(
            child: isPlanSelected
                ? _buildPlanView()
                : const SingleChildScrollView(child: WorkoutHistoryScreen()), // 👈 Changed here!
          ),
        ],
      ),
      // Only show the "Start Workout" button if we are looking at the plan!
      bottomNavigationBar: isPlanSelected ? _buildBottomActions() : null,
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 45,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isPlanSelected = true),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isPlanSelected ? const LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)]) : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                      "Plan",
                      style: TextStyle(
                          color: isPlanSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isPlanSelected = false),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: !isPlanSelected ? const LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)]) : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                      "Logs",
                      style: TextStyle(
                          color: !isPlanSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),

          _buildProgressCard(),
          const SizedBox(height: 20),

          ..._workoutResponse!.days.map((dayPlan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildSection(
                title: dayPlan.day,
                subtitle: dayPlan.focus,
                exercises: dayPlan.exercises,
              ),
            );
          }).toList(),

          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: SummaryItem(
              icon: Icons.fitness_center,
              value: _workoutResponse!.planType,
              label: "Type",
              gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
          ),
          Expanded(
            child: SummaryItem(
              icon: Icons.trending_up,
              value: _workoutResponse!.difficulty,
              label: "Difficulty",
              gradient: const [Color(0xFFFFA726), Color(0xFFFF7043)],
            ),
          ),
          Expanded(
            child: SummaryItem(
              icon: Icons.calendar_view_week,
              value: _workoutResponse!.weeklySplit,
              label: "Split",
              gradient: const [Color(0xFF66BB6A), Color(0xFF00C853)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    double progress = _workoutResponse!.days.isEmpty
        ? 0.0
        : _completedDays.length / _workoutResponse!.days.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Workout Progress",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "${_completedDays.length} / ${_workoutResponse!.days.length} Days",
                style: const TextStyle(color: Color(0xFF22E1A0), fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E5E5),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22E1A0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Exercise> exercises,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E8E),
            ),
          ),
          const SizedBox(height: 16),
          ...exercises.map((e) => _buildExerciseTile(e)).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)],
              ),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${exercise.sets} Sets • ${exercise.reps} Reps • ${exercise.restTime}s Rest",
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF22E1A0),
                    Color(0xFF1E88E5),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_completedDays.length == _workoutResponse!.days.length) {
                    setState(() {
                      _completedDays.clear();
                      _currentDayIndex = 0;
                    });
                    return;
                  }

                  final isFinished = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutScreen(
                        plan: _workoutResponse!,
                        dayIndex: _currentDayIndex,
                      ),
                    ),
                  );

                  if (isFinished == true) {
                    setState(() {
                      _completedDays.add(_currentDayIndex);

                      if (_currentDayIndex < _workoutResponse!.days.length - 1) {
                        _currentDayIndex++;
                      }
                    });
                  }
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  _completedDays.length == _workoutResponse!.days.length
                      ? "Plan Completed! 🎉"
                      : "Start Day ${_currentDayIndex + 1}",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _outlineActionButton(
            icon: Icons.visibility_outlined,
            text: "Preview Exercises",
            onPressed: () {},
          ),
          const SizedBox(height: 14),
          _outlineActionButton(
            icon: Icons.calendar_today_outlined,
            text: "View Weekly Plan",
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _outlineActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black54),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;

  const SummaryItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: gradient),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E8E8E),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
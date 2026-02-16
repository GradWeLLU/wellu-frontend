import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_plan_model.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutPlan plan;

  const ActiveWorkoutScreen({super.key, required this.plan});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  // Logic Variables
  late List<ExerciseWithCategory> _allExercises;
  int _currentIndex = 0;
  final Set<int> _completedIndices = {};

  // Track sets for the current specific exercise
  int _currentSetProgress = 0;

  // Timer Variables
  Timer? _sessionTimer;
  Duration _elapsedTime = Duration.zero;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _flattenExercises();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _flattenExercises() {
    _allExercises = [
      ...widget.plan.warmup.map((e) => ExerciseWithCategory(e, "Warmup")),
      ...widget.plan.main.map((e) => ExerciseWithCategory(e, "Main")),
      ...widget.plan.cooldown.map((e) => ExerciseWithCategory(e, "Cooldown")),
    ];
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  // Jump to a specific exercise when clicked from the list
  void _jumpToExercise(int index) {
    setState(() {
      _currentIndex = index;
      _currentSetProgress = 0; // Reset local set counter for the new exercise
    });
  }

  void _nextExercise({required bool markComplete}) {
    setState(() {
      if (markComplete) {
        _completedIndices.add(_currentIndex);
      }

      if (_currentIndex < _allExercises.length - 1) {
        _currentIndex++;
        _currentSetProgress = 0; // Reset set counter for the next exercise
      } else {
        _showFinishDialog();
      }
    });
  }

  void _incrementSet(int maxSets) {
    if (_currentSetProgress < maxSets) {
      setState(() {
        _currentSetProgress++;
      });

      // AUTO-COMPLETE LOGIC:
      // If we just finished the last set, complete the exercise and move on.
      if (_currentSetProgress == maxSets) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _nextExercise(markComplete: true);
        });
      }
    }
  }

  void _showFinishDialog() {
    _sessionTimer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Workout Complete!"),
        content: Text("You finished in ${_formatDuration(_elapsedTime)}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _completedIndices.length / _allExercises.length;
    if (_allExercises.isEmpty) return const Scaffold(body: Center(child: Text("No exercises found")));

    final currentExerciseObj = _allExercises[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(_elapsedTime),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Active Workout",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Track your progress in real-time",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Overall Progress",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    Text(
                      "${_completedIndices.length} / ${_allExercises.length} exercises",
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E5E5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22E1A0)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentExerciseCard(currentExerciseObj),

                  const SizedBox(height: 30),

                  const Text(
                    "All Exercises",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allExercises.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildListItem(index);
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ---------------- WIDGETS ---------------- //

  Widget _buildCurrentExerciseCard(ExerciseWithCategory exerciseData) {
    bool isMain = exerciseData.category == "Main";

    // MOCK DATA
    int totalSets = 4;
    String reps = "12";
    String weight = "60";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseData.exercise.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exerciseData.category,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${_allExercises.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // -- DYNAMIC CONTENT BASED ON TYPE --
            if (isMain)
              _buildMainWorkoutContent(totalSets, reps, weight)
            else
              _buildDurationContent(),

            const SizedBox(height: 24),

            // -- BOTTOM BUTTONS (Skip / Complete) --
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () => _nextExercise(markComplete: false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F4F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Skip Exercise",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _nextExercise(markComplete: true),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Complete",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF131B2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Layout for "Main" exercises
  Widget _buildMainWorkoutContent(int totalSets, String reps, String weight) {
    return Column(
      children: [
        // 1. Stats Row
        Row(
          children: [
            Expanded(child: _buildStatBox("Sets", "$_currentSetProgress / $totalSets")),
            const SizedBox(width: 12),
            Expanded(child: _buildStatBox("Reps", reps)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatBox("Weight", "$weight kg")),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Check Posture Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFB066F5), Color(0xFF7B52FF)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                // Posture check logic
              },
              icon: const Icon(Icons.visibility, color: Colors.white),
              label: const Text("Check Posture", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Complete Set Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)],
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _incrementSet(totalSets),
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                  _currentSetProgress >= totalSets ? "Done" : "Complete Set",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Layout for Warmup/Cooldown
  Widget _buildDurationContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Text(
            "Duration",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 6),
          Text(
            "30 sec",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(int index) {
    final item = _allExercises[index];
    final bool isCompleted = _completedIndices.contains(index);
    final bool isActive = index == _currentIndex;

    Color borderColor = Colors.transparent;
    Color backgroundColor = Colors.white;
    Color iconBgColor = const Color(0xFFF2F4F3);
    Color iconColor = Colors.grey;
    IconData iconData = Icons.fitness_center;

    if (isCompleted) {
      borderColor = const Color(0xFF22E1A0).withOpacity(0.3);
      backgroundColor = const Color(0xFFF0FDF9);
      iconBgColor = const Color(0xFF22E1A0);
      iconColor = Colors.white;
      iconData = Icons.check;
    } else if (isActive) {
      borderColor = const Color(0xFF1E88E5);
      backgroundColor = Colors.white;
      iconBgColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF1E88E5);
    }

    return InkWell(
      onTap: () => _jumpToExercise(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive || isCompleted ? borderColor : Colors.grey.shade200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isCompleted ? const Color(0xFF22E1A0) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _togglePause,
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: Colors.black87),
                label: Text(
                  _isPaused ? "Resume" : "Pause",
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F4F3),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)],
                ),
              ),
              child: ElevatedButton(
                onPressed: _showFinishDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Finish Workout",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseWithCategory {
  final Exercise exercise;
  final String category;

  ExerciseWithCategory(this.exercise, this.category);
}
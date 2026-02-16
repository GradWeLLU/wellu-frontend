import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../models/workout_plan_model.dart';
import 'active_workout_screen.dart';


class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {

  late WorkoutService _service;

  WorkoutPlan? _plan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = WorkoutService();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    try {
      final plan = await _service.fetchWorkoutPlan();

      setState(() {
        _plan = plan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
          child: Text("Error loading workout"),
        ),
      );
    }

    if (_plan == null) {
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSummaryCard(),
            const SizedBox(height: 20),

            _buildProgressCard(),
            const SizedBox(height: 20),

            _buildSection(
              title: "Warm-up",
              subtitle: "Prepare your body",
              exercises: _plan!.warmup,
            ),

            const SizedBox(height: 20),

            _buildSection(
              title: "Main Exercises",
              subtitle: "Build strength and endurance",
              exercises: _plan!.main,
            ),

            const SizedBox(height: 20),

            _buildSection(
              title: "Cooldown",
              subtitle: "Recover and relax",
              exercises: _plan!.cooldown,
            ),

            const SizedBox(height: 20),

            _buildTipsCard(),

            const SizedBox(height: 140),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomActions(),
    );
  }

  // ─────────────────────────────

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SummaryItem(
            icon: Icons.access_time,
            value: "${_plan!.duration} min",
            label: "Duration",
            gradient: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          SummaryItem(
            icon: Icons.trending_up,
            value: _plan!.difficulty,
            label: "Difficulty",
            gradient: const [Color(0xFFFFA726), Color(0xFFFF7043)],
          ),
          SummaryItem(
            icon: Icons.local_fire_department,
            value: "${_plan!.calories} kcal",
            label: "Est. Burn",
            gradient: const [Color(0xFF66BB6A), Color(0xFF00C853)],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Workout Progress",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const LinearProgressIndicator(
              value: 0.0,
              minHeight: 10,
              backgroundColor: Color(0xFFE5E5E5),
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFF22E1A0)),
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
          Column(
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
                exercise.detail,
                style: const TextStyle(
                  color: Color(0xFF8E8E8E),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF22E1A0).withOpacity(0.15),
            const Color(0xFF1E88E5).withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF22E1A0).withOpacity(0.3),
        ),
      ),
      child: Text(
        "💪 Workout Tips\n\n${_plan!.tip}",
        style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActiveWorkoutScreen(plan: _plan!),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  "Start Workout",
                  style: TextStyle(
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
          ),
          const SizedBox(height: 14),
          _outlineActionButton(
            icon: Icons.calendar_today_outlined,
            text: "View Weekly Plan",
          ),
        ],
      ),
    );
  }

  Widget _outlineActionButton({
    required IconData icon,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {},
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

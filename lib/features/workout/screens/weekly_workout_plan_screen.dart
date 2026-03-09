import 'package:flutter/material.dart';

// --- MOCK DATA MODEL ---
enum DayStatus { completed, rest, pending }

class DailyPlan {
  final String day;
  final String date;
  final String title;
  final int? duration;
  final int? calories;
  final DayStatus status;

  DailyPlan({
    required this.day,
    required this.date,
    required this.title,
    this.duration,
    this.calories,
    required this.status,
  });
}

class WeeklyWorkoutPlanScreen extends StatefulWidget {
  const WeeklyWorkoutPlanScreen({super.key});

  @override
  State<WeeklyWorkoutPlanScreen> createState() => _WeeklyWorkoutPlanScreenState();
}

class _WeeklyWorkoutPlanScreenState extends State<WeeklyWorkoutPlanScreen> {
  // Mock data representing the week shown in your screenshots
  final List<DailyPlan> _weekPlan = [
    DailyPlan(day: "Mon", date: "Dec 9", title: "Strength Training", duration: 45, calories: 270, status: DayStatus.completed),
    DailyPlan(day: "Tue", date: "Dec 10", title: "Cardio", duration: 30, calories: 180, status: DayStatus.completed),
    DailyPlan(day: "Wed", date: "Dec 11", title: "Upper Body", duration: 40, calories: 240, status: DayStatus.completed),
    DailyPlan(day: "Thu", date: "Dec 12", title: "Rest Day", status: DayStatus.rest),
    DailyPlan(day: "Fri", date: "Dec 13", title: "Lower Body", duration: 45, calories: 270, status: DayStatus.pending),
    DailyPlan(day: "Sat", date: "Dec 14", title: "HIIT", duration: 35, calories: 210, status: DayStatus.pending),
    DailyPlan(day: "Sun", date: "Dec 15", title: "Yoga & Stretch", duration: 30, calories: 180, status: DayStatus.pending),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Weekly Workout Plan",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "Your personalized training schedule",
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            const Text(
              "This Week's Plan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ..._weekPlan.map((plan) => _buildDailyCard(plan)), // Removed the unnecessary .toList() warning
            const SizedBox(height: 8),
            _buildTipCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGETS ---------------- //

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42D293), Color(0xFF3B82F6)], // Green to Blue Gradient
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Week Summary",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSummaryStat("Total Time", "225 min")),
              Expanded(child: _buildSummaryStat("Calories Burned", "890 kcal")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSummaryStat("Workouts Done", "3 / 6")),
              Expanded(child: _buildSummaryStat("Completion", "50%")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDailyCard(DailyPlan plan) {
    // Styling based on status
    Color borderColor;
    Color bgColor = Colors.white;
    Color iconBgColor;
    Color iconColor = Colors.white;
    IconData icon;

    switch (plan.status) {
      case DayStatus.completed:
        borderColor = const Color(0xFF42D293).withValues(alpha: 0.4);
        bgColor = const Color(0xFFF0FDF4); // Very light green tint
        iconBgColor = const Color(0xFF42D293);
        icon = Icons.check;
        break;
      case DayStatus.pending:
        borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.3);
        iconBgColor = const Color(0xFF3B82F6);
        icon = Icons.fitness_center;
        break;
      case DayStatus.rest:
        borderColor = Colors.grey.shade300;
        iconBgColor = Colors.grey.shade300;
        icon = Icons.calendar_today;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${plan.day} • ${plan.date}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: plan.status == DayStatus.completed ? const Color(0xFF42D293) : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    if (plan.status == DayStatus.completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF42D293),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Completed",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Bottom row (Duration & Calories OR Rest Day Text)
                if (plan.status == DayStatus.rest)
                  const Text(
                    "Active recovery and muscle repair",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("${plan.duration} min", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("~${plan.calories} cal", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4FB), // Light pinkish/purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3DDF3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb, color: Color(0xFFEBC18D)), // Yellowish/Gold icon
              SizedBox(width: 8),
              Text(
                "Weekly Tip",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Consistency is key! Try to complete at least 80% of your scheduled workouts this week. Remember to stay hydrated and listen to your body.",
            style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
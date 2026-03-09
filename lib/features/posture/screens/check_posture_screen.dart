import 'package:flutter/material.dart';

class SelectExerciseScreen extends StatelessWidget {
  const SelectExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Exercise",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Banner
            const Text(
              "Choose an exercise to check your posture",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F0FF), // Light purple background
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.headphones,
                    color: Color(0xFFA855F7), // Purple icon
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Real-time audio feedback through your AirPods or speakers",
                      style: TextStyle(
                        color: const Color(0xFFA855F7), // Purple text
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Warm-up Section
            _buildSectionTitle("Warm-up"),
            _buildExerciseCard(
              title: "Jumping Jacks",
              detail: "30 sec",
            ),
            _buildExerciseCard(
              title: "Dynamic Stretching",
              detail: "45 sec",
            ),
            const SizedBox(height: 24),

            // 3. Main Exercises Section
            _buildSectionTitle("Main Exercises"),
            _buildExerciseCard(
              title: "Barbell Squats",
              detail: "4 sets × 12 reps @ 60kg",
              tag: "Legs",
            ),
            _buildExerciseCard(
              title: "Bench Press",
              detail: "4 sets × 10 reps @ 50kg",
              tag: "Chest",
            ),
            _buildExerciseCard(
              title: "Deadlifts",
              detail: "3 sets × 8 reps @ 80kg",
              tag: "Back",
            ),
            _buildExerciseCard(
              title: "Shoulder Press",
              detail: "3 sets × 12 reps @ 30kg",
              tag: "Shoulders",
            ),
            _buildExerciseCard(
              title: "Pull-ups",
              detail: "3 sets × 10 reps",
              tag: "Back",
            ),
            _buildExerciseCard(
              title: "Lunges",
              detail: "3 sets × 12 reps @ 20kg",
              tag: "Legs",
            ),
            const SizedBox(height: 24),

            // 4. Cooldown Section
            _buildSectionTitle("Cooldown"),
            _buildExerciseCard(
              title: "Light Walking",
              detail: "2 min",
            ),
            _buildExerciseCard(
              title: "Static Stretching",
              detail: "45 sec",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String detail,
    String? tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fitness_center, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),

          // Exercise Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF), // Light blue background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Color(0xFF4338CA), // Dark blue text
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Pink Camera Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF4FF), // Very light pink background
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF0ABFC), // Pink border
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFD946EF), // Pink icon
                size: 20,
              ),
              onPressed: () {
                // Navigate to actual camera/posture check screen later
              },
            ),
          ),
        ],
      ),
    );
  }
}
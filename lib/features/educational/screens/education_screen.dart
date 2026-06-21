import 'package:flutter/material.dart';
import '../services/education_service.dart';
import 'quiz_screen.dart';
import 'quiz_history_screen.dart';

class EducationScreen extends StatefulWidget {
  // 🔹 No more userId required here!
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final EducationService _apiService = EducationService();
  Map<String, dynamic>? _dailyFact;
  bool _isLoadingFact = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyFact();
  }

  Future<void> _fetchDailyFact() async {
    final fact = await _apiService.getDailyFact();
    setState(() {
      _dailyFact = fact;
      _isLoadingFact = false;
    });
  }

  void _startQuizApp(String difficulty) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 🔹 Only passing the difficulty now!
    final quizData = await _apiService.startQuiz(difficulty);

    if (mounted) Navigator.pop(context); // Remove loading indicator

    if (quizData != null && mounted) {
      // 🔹 OPEN THE QUIZ SCREEN HERE
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(quizData: quizData),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Learn",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        actions: [
          // 🔹 NEW: History Button
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizHistoryScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.auto_awesome, color: Colors.blue),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Improve your form, nutrition, and wellness knowledge by taking daily quizzes!",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              /// 🔹 Daily Fact Card
              _buildDailyFactCard(),

              const SizedBox(height: 32),

              /// 🔹 Quiz Categories Section
              const Text(
                "Choose Your Challenge",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              /// 🔹 Difficulty Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDifficultyCard(
                    title: "Easy",
                    subtitle: "10 questions",
                    icon: Icons.sentiment_satisfied_alt,
                    iconColor: const Color(0xFF00E676),
                    difficulty: "EASY",
                  ),
                  _buildDifficultyCard(
                    title: "Medium",
                    subtitle: "15 questions",
                    icon: Icons.fitness_center,
                    iconColor: const Color(0xFF2979FF),
                    difficulty: "MEDIUM",
                  ),
                  _buildDifficultyCard(
                    title: "Hard",
                    subtitle: "20 questions",
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFFF3D00),
                    difficulty: "HARD",
                  ),
                  _buildDifficultyCard(
                    title: "Random",
                    subtitle: "Mixed level",
                    icon: Icons.shuffle,
                    iconColor: const Color(0xFFE040FB),
                    difficulty: "MEDIUM",
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 The Gradient Daily Fact Card
  Widget _buildDailyFactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2979FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Fact",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _dailyFact?['category'] ?? "Loading...",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoadingFact)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            Text(
              _dailyFact?['content'] ?? "Check your connection to get today's fact!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 The Clean White Difficulty Cards
  Widget _buildDifficultyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String difficulty,
  }) {
    return GestureDetector(
      onTap: () => _startQuizApp(difficulty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
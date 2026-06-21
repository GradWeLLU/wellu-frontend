import 'package:flutter/material.dart';
import '../services/education_service.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final EducationService _apiService = EducationService();
  List<dynamic>? _attempts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final attempts = await _apiService.getMyAttempts();
    setState(() {
      _attempts = attempts;
      _isLoading = false;
    });
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
          "My Past Quizzes",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attempts == null || _attempts!.isEmpty
          ? const Center(
        child: Text(
          "You haven't completed any quizzes yet! 🌱",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _attempts!.length,
        itemBuilder: (context, index) {
          final attempt = _attempts![index];
          final quiz = attempt['quiz'];

          // Format the date slightly
          DateTime date = DateTime.parse(attempt['completedAt'] ?? DateTime.now().toIso8601String());
          String formattedDate = "${date.day}/${date.month}/${date.year}";

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz['title'] ?? "Quiz",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Completed: $formattedDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${attempt['score']} pts",
                    style: const TextStyle(
                      color: Color(0xFF2979FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
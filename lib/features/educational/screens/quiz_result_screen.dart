import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizResultsScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const QuizResultsScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final score = resultData['score'];
    final List<dynamic> questionResults = resultData['questionResults'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context), // Go back to Education Screen
        ),
        title: const Text(
          "Quiz Results",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Top Score Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "You Scored",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$score pts",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Question Breakdown List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: questionResults.length,
                itemBuilder: (context, index) {
                  final qResult = questionResults[index];
                  final choices = List<String>.from(qResult['choices']);
                  final selectedIdx = qResult['selectedAnswerIndex'];
                  final correctIdx = qResult['correctAnswerIndex'];
                  final explanation = qResult['explanation'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}: ${qResult['content']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Choices Loop
                        ...List.generate(choices.length, (choiceIdx) {
                          bool isCorrect = choiceIdx == correctIdx;
                          bool isSelected = choiceIdx == selectedIdx;

                          Color bgColor = Colors.transparent;
                          Color borderColor = Colors.grey.shade300;
                          IconData? icon;

                          if (isCorrect) {
                            bgColor = Colors.green.withOpacity(0.1);
                            borderColor = Colors.green;
                            icon = Icons.check_circle;
                          } else if (isSelected && !isCorrect) {
                            bgColor = Colors.red.withOpacity(0.1);
                            borderColor = Colors.red;
                            icon = Icons.cancel;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(color: borderColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    choices[choiceIdx],
                                    style: TextStyle(
                                      color: isCorrect ? Colors.green[800] : (isSelected ? Colors.red[800] : Colors.black87),
                                      fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (icon != null) Icon(icon, color: borderColor, size: 20),
                              ],
                            ),
                          );
                        }),

                        // Explanation Section
                        if (explanation != null && explanation.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    explanation,
                                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
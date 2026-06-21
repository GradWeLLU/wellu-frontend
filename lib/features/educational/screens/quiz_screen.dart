import 'package:flutter/material.dart';
import '../services/education_service.dart';
import 'quiz_result_screen.dart'; // Make sure this matches your file name!
import 'quiz_history_screen.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizScreen({super.key, required this.quizData});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final EducationService _apiService = EducationService();

  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  // 🔹 Define your signature gradient here!
  final LinearGradient _primaryGradient = const LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF2979FF)], // Green to Blue
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  List<dynamic> get _questions => widget.quizData['quiz']['questions'];
  String get _attemptId => widget.quizData['attemptId'];

  void _selectAnswer(int choiceIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = choiceIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _isSubmitting = true;
    });

    Map<String, int> formattedApiAnswers = {};
    _selectedAnswers.forEach((questionIndex, choiceIndex) {
      String questionId = _questions[questionIndex]['id'];
      formattedApiAnswers[questionId] = choiceIndex;
    });

    final results = await _apiService.submitQuiz(_attemptId, formattedApiAnswers);

    setState(() {
      _isSubmitting = false;
    });

    if (results != null && mounted) {
      // 🔹 OPEN THE RESULTS SCREEN AND CLOSE THE QUIZ!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(resultData: results),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting quiz. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final choices = List<String>.from(question['choices']);
    bool hasAnsweredCurrent = _selectedAnswers.containsKey(_currentQuestionIndex);
    bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.quizData['quiz']['title'] ?? "Quiz",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                  ),

                  // Gradient text for points!
                  ShaderMask(
                    shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
                    child: Text(
                      "${question['points']} pts",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// 🔹 Custom Gradient Progress Bar
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentQuestionIndex + 1) / _questions.length,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// 🔹 Question Content
              Text(
                question['content'],
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              /// 🔹 Choices List
              Expanded(
                child: ListView.builder(
                  itemCount: choices.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;

                    return GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2979FF).withOpacity(0.5) : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            if (!isSelected)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            /// Custom Gradient Radio Button
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSelected ? null : Border.all(color: Colors.grey.shade400, width: 2),
                                gradient: isSelected ? _primaryGradient : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: isSelected
                                  ? ShaderMask(
                                shaderCallback: (bounds) => _primaryGradient.createShader(bounds),
                                child: Text(
                                  choices[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : Text(
                                choices[index],
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// 🔹 Custom Gradient Next / Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: hasAnsweredCurrent ? _primaryGradient : null,
                  color: hasAnsweredCurrent ? null : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: hasAnsweredCurrent
                      ? [
                    BoxShadow(
                      color: const Color(0xFF2979FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: hasAnsweredCurrent && !_isSubmitting ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                  )
                      : Text(
                    isLastQuestion ? "Submit Quiz" : "Continue",
                    style: TextStyle(
                        color: hasAnsweredCurrent ? Colors.white : Colors.grey.shade500,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
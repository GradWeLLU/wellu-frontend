import 'dart:convert';
import 'dart:math';

class EducationService {

  /// 🔹 Get Today's Daily Fact (MOCK)
  Future<Map<String, dynamic>?> getDailyFact() async {
    // Simulate a network delay of 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    return {
      "id": "fact-123",
      "content": "Drinking 500ml of water can temporarily boost your metabolism by 24-30% for up to an hour!",
      "category": "Nutrition",
      "factDate": "2026-05-18",
      "createdAt": "2026-05-18T08:00:00"
    };
  }

  /// 🔹 Start a New Quiz (MOCK)
  Future<Map<String, dynamic>?> startQuiz(String userId, String difficulty) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    return {
      "attemptId": "attempt-999",
      "userId": userId,
      "score": 0.0,
      "completedAt": null,
      "quiz": {
        "id": "quiz-001",
        "title": "$difficulty Wellness Challenge",
        "difficulty": difficulty,
        "timeLimit": 300,
        "isDaily": true,
        "totalPoints": 20,
        "questions": [
          {
            "id": "q-1",
            "content": "Which macronutrient is primarily responsible for muscle repair and growth?",
            "choices": ["Carbohydrates", "Proteins", "Fats", "Vitamins"],
            "difficulty": difficulty,
            "points": 10
          },
          {
            "id": "q-2",
            "content": "How many hours of sleep is generally recommended for optimal muscle recovery?",
            "choices": ["4-5 hours", "6-7 hours", "7-9 hours", "10+ hours"],
            "difficulty": difficulty,
            "points": 10
          }
        ]
      },
      "answers": {} // Empty at start
    };
  }

  /// 🔹 Submit Quiz Answers (MOCK)
  Future<Map<String, dynamic>?> submitQuiz(String attemptId, Map<int, int> answers) async {
    // Simulate network processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Hardcoding a perfect score response for demo purposes!
    return {
      "attemptId": attemptId,
      "userId": "uuid-123",
      "score": 20.0,
      "completedAt": "2026-05-18T18:20:00",
      "quiz": {
        "id": "quiz-001",
        "title": "Wellness Challenge",
        "difficulty": "EASY",
        "timeLimit": 300,
        "isDaily": true,
        "totalPoints": 20,
        "questions": [
          {
            "id": "q-1",
            "content": "Which macronutrient is primarily responsible for muscle repair and growth?",
            "choices": ["Carbohydrates", "Proteins", "Fats", "Vitamins"],
            "difficulty": "EASY",
            "points": 10
          },
          {
            "id": "q-2",
            "content": "How many hours of sleep is generally recommended for optimal muscle recovery?",
            "choices": ["4-5 hours", "6-7 hours", "7-9 hours", "10+ hours"],
            "difficulty": "EASY",
            "points": 10
          }
        ]
      },
      "questionResults": [
        {
          "questionId": "q-1",
          "content": "Which macronutrient is primarily responsible for muscle repair and growth?",
          "choices": ["Carbohydrates", "Proteins", "Fats", "Vitamins"],
          "selectedAnswerIndex": answers[0] ?? 1,
          "correctAnswerIndex": 1,
          "correct": answers[0] == 1,
          "explanation": "Proteins are made of amino acids, which are the building blocks of muscle.",
          "points": answers[0] == 1 ? 10 : 0
        },
        {
          "questionId": "q-2",
          "content": "How many hours of sleep is generally recommended for optimal muscle recovery?",
          "choices": ["4-5 hours", "6-7 hours", "7-9 hours", "10+ hours"],
          "selectedAnswerIndex": answers[1] ?? 2,
          "correctAnswerIndex": 2,
          "correct": answers[1] == 2,
          "explanation": "7-9 hours of sleep allows the body to release growth hormones necessary for recovery.",
          "points": answers[1] == 2 ? 10 : 0
        }
      ]
    };
  }
}
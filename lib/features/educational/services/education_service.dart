import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EducationService {
  // 🔹 Use 10.0.2.2 if testing on an Android emulator!
  final String baseUrl = 'http://10.0.2.2:8083';

  /// 🔹 Helper method to safely grab your JWT
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// 🔹 Helper to generate standard headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 🔹 GET: Today's Daily Fact
  Future<Map<String, dynamic>?> getDailyFact() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/daily-facts/today'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching daily fact: $e');
    }
    return null;
  }

  /// 🔹 POST: Start a New Quiz
  Future<Map<String, dynamic>?> startQuiz(String difficulty) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/quiz-attempts/start'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'difficulty': difficulty, // 👈 No more userId needed!
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error starting quiz: $e');
    }
    return null;
  }

  /// 🔹 POST: Submit Quiz Answers
  Future<Map<String, dynamic>?> submitQuiz(String attemptId, Map<String, int> answers) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/quiz-attempts/$attemptId/submit'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'answers': answers,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error submitting quiz: $e');
    }
    return null;
  }

  /// 🔹 GET: Fetch User's Past Attempts
  Future<List<dynamic>?> getMyAttempts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quiz-attempts/my-attempts'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns the array of attempts
      }
    } catch (e) {
      print('Error fetching past attempts: $e');
    }
    return null;
  }
}
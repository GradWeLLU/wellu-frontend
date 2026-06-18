import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutService {
  // Changed return type to Future<String> since we only return "ok"
  Future<String> fetchWorkoutPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8082/workouts/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $myToken',
      },
    );

    if (response.statusCode == 200) {
      // Just return the string as requested!
      return "ok";
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
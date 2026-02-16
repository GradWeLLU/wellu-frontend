import 'dart:async';
import '../models/workout_plan_model.dart';

class WorkoutService {

  Future<WorkoutPlan> fetchWorkoutPlan() async {

    await Future.delayed(const Duration(seconds: 1));
    final fakeJson = {
      "duration": 45,
      "difficulty": "Intermediate",
      "calories": 320,
      "warmup": [
        {"name": "Jumping Jacks", "detail": "30 sec"},
        {"name": "Dynamic Stretching", "detail": "45 sec"}
      ],
      "main": [
        {"name": "Barbell Squats", "detail": "4 x 12 • 60 kg"},
        {"name": "Bench Press", "detail": "4 x 10 • 50 kg"},
        {"name": "Deadlifts", "detail": "3 x 8 • 80 kg"},
        {"name": "Shoulder Press", "detail": "3 x 12 • 30 kg"}
      ],
      "cooldown": [
        {"name": "Light Walking", "detail": "2 min"},
        {"name": "Static Stretching", "detail": "45 sec"}
      ],
      "tip": "Stay hydrated throughout your workout. Focus on form over heavy weights."
    };

    return WorkoutPlan.fromJson(fakeJson);
  }
}

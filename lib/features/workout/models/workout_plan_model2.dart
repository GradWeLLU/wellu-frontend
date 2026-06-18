class WorkoutResponse {
  final String id;
  final String weeklySplit;
  final String planType;
  final String difficulty;
  final String status;
  final List<DayPlan> days;

  WorkoutResponse({
    required this.id,
    required this.weeklySplit,
    required this.planType,
    required this.difficulty,
    required this.status,
    required this.days,
  });

  factory WorkoutResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutResponse(
      id: json['id'] ?? "",
      weeklySplit: json['weekly_split'] ?? "Standard Split",
      planType: json['plan_type'] ?? "GENERAL",
      difficulty: json['difficulty'] ?? "INTERMEDIATE",
      status: json['status'] ?? "INACTIVE",
      days: json['days'] != null
          ? (json['days'] as List).map((d) => DayPlan.fromJson(d)).toList()
          : [],
    );
  }
}

class DayPlan {
  final String day;
  final String focus;
  final List<Exercise> exercises;

  DayPlan({
    required this.day,
    required this.focus,
    required this.exercises,
  });

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] ?? "Workout Day",
      focus: json['focus'] ?? "General Training",
      exercises: json['exercises'] != null
          ? (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList()
          : [],
    );
  }
}



class Exercise {
  final String name;
  final List<String> muscleGroups;
  final String exerciseType;
  final int sets;
  final String reps;
  final String difficulty;
  final String videoUrl;
  final double restTime; // Changed to int to match your JSON (120)

  Exercise({
    required this.name,
    required this.muscleGroups,
    required this.exerciseType,
    required this.sets,
    required this.reps,
    required this.difficulty,
    required this.videoUrl,
    required this.restTime,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? "Exercise",
      muscleGroups: List<String>.from(json['muscle_group'] ?? []),
      exerciseType: json['exercise_type'] ?? "STRENGTH",
      sets: json['sets'] ?? 0,
      reps: json['reps']?.toString() ?? "0",
      difficulty: json['difficulty'] ?? "MEDIUM",
      videoUrl: json['video_url'] ?? "",
      restTime: json['rest_time'] ?? 0,
    );
  }
}
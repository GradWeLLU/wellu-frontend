class Exercise {
  final String name;
  final String detail;
  final String? muscleGroup;

  Exercise({
    required this.name,
    required this.detail,
    this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      detail: json['detail'],
      muscleGroup: json['muscleGroup'],
    );
  }
}

class WorkoutPlan {
  final int duration;
  final String difficulty;
  final int calories;

  final List<Exercise> warmup;
  final List<Exercise> main;
  final List<Exercise> cooldown;

  final String tip;

  WorkoutPlan({
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.warmup,
    required this.main,
    required this.cooldown,
    required this.tip,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      duration: json['duration'],
      difficulty: json['difficulty'],
      calories: json['calories'],
      warmup: (json['warmup'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      main: (json['main'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      cooldown: (json['cooldown'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      tip: json['tip'],
    );
  }
}

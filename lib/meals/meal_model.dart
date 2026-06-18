class MealPlanResponse {
  final String id;
  final String planType;
  final String status;
  final List<DailyMealPlan> days;


  MealPlanResponse({
    required this.id,
    required this.planType,
    required this.status,
    required this.days,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      id: json['id'] ?? "",
      planType: json['plan_type'] ?? "GENERAL",
      status: json['status'] ?? "INACTIVE",
      days: json['days'] != null
          ? (json['days'] as List).map((d) => DailyMealPlan.fromJson(d)).toList()
          : [],
    );
  }
}

class DailyMealPlan {
  final String day;
  final int totalCalories;
  final List<Meal> meals;

  DailyMealPlan({
    required this.day,
    required this.totalCalories,
    required this.meals,
  });

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      day: json['day'] ?? "Day 1",
      totalCalories: json['total_calories'] ?? 0,
      meals: json['meals'] != null
          ? (json['meals'] as List).map((m) => Meal.fromJson(m)).toList()
          : [],
    );
  }
}
class Meal {
  final String name;
  final String mealType;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients; // 👈 Make sure this is List<String>

  // (Optional: add imageUrl and mealTips if you want them, or remove them from the UI if your backend doesn't send them yet!)

  Meal({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? "Meal",
      mealType: json['name']?.split(' - ')[0] ?? "Meal", // Grabs "Breakfast" from "Breakfast - Egg White"
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fats'] ?? 0).toDouble(), // Notice your JSON says 'fats' with an 's'
      ingredients: List<String>.from(json['ingredients'] ?? []), // 👈 Correctly parses your strings!
    );
  }
}
class RecipeIngredient {
  final String name;
  final String unit;
  double quantity;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFats;

  RecipeIngredient({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFats,
  });
}

class Meal {
  final String id;
  final String title;
  final String time;
  final int totalCalories; // The default total
  final String imageUrl;
  final String categoryIcon;
  final String mealTips;
  final List<RecipeIngredient> ingredients; // 🔹 Now using the smart object!

  Meal({
    required this.id,
    required this.title,
    required this.time,
    required this.totalCalories,
    required this.imageUrl,
    required this.categoryIcon,
    required this.mealTips,
    required this.ingredients,
  });
}
import 'dart:async';
import 'meal_model.dart';

class MealService {
  Future<List<Meal>> fetchTodayMeals() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    return [
      Meal(
        id: "1",
        title: "Power Breakfast Bowl",
        time: "8:00 AM",
        totalCalories: 450,
        categoryIcon: "coffee",
        imageUrl: "https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=500&q=80",
        mealTips: "This meal is balanced and provides sustained energy. It's rich in fiber and protein to keep you full until your next meal.",
        ingredients: [
          RecipeIngredient(name: "Oatmeal", unit: "cup", quantity: 1.0, baseCalories: 150, baseProtein: 5, baseCarbs: 27, baseFats: 3),
          RecipeIngredient(name: "Berries", unit: "cup", quantity: 0.5, baseCalories: 80, baseProtein: 2, baseCarbs: 15, baseFats: 0),
          RecipeIngredient(name: "Almonds", unit: "g", quantity: 30.0, baseCalories: 5.6, baseProtein: 0.2, baseCarbs: 0.2, baseFats: 0.5),
        ],
      ),
      Meal(
        id: "2",
        title: "Grilled Chicken Salad",
        time: "12:30 PM",
        totalCalories: 520,
        categoryIcon: "salad",
        imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80",
        mealTips: "High in lean protein and essential vitamins. Great for post-workout recovery.",
        ingredients: [
          RecipeIngredient(name: "Chicken Breast", unit: "g", quantity: 150.0, baseCalories: 1.6, baseProtein: 0.31, baseCarbs: 0, baseFats: 0.03),
          RecipeIngredient(name: "Mixed Greens", unit: "cup", quantity: 2.0, baseCalories: 10, baseProtein: 1, baseCarbs: 2, baseFats: 0),
          RecipeIngredient(name: "Quinoa", unit: "cup", quantity: 0.5, baseCalories: 222, baseProtein: 8, baseCarbs: 39, baseFats: 3.5),
        ],
      ),
    ];
  }
}
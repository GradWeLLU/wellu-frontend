import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'meal_model.dart';
import 'meal_service.dart';
import '../../meals/meal_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealService _mealService = MealService();
  bool isTodaySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 MATCHING HOME SCREEN BACKGROUND
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Your Meal Plan", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleSwitch(),
                _buildNutritionSummary(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Today's Meals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _buildMealsList(),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomActions(),
          ),
        ],
      ),
    );
  }

  /// 🔹 1. Custom Toggle Switch (Using AppGradients)
  Widget _buildToggleSwitch() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 45,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isTodaySelected = true),
                child: Container(
                  decoration: BoxDecoration(
                    // 🔹 USING APP GRADIENT
                    gradient: isTodaySelected ? AppGradients.primary : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text("Today", style: TextStyle(color: isTodaySelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isTodaySelected = false),
                child: Container(
                  decoration: BoxDecoration(
                    // 🔹 USING APP GRADIENT
                    gradient: !isTodaySelected ? AppGradients.primary : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text("This Week", style: TextStyle(color: !isTodaySelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 2. Nutrition Summary Grid
  Widget _buildNutritionSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Nutrition", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              // 🔹 Using AppColors.caloriesOrange to match Home Screen
              Expanded(child: _buildNutrientItem("Calories", "1850", "2000 kcal", AppColors.caloriesOrange, Icons.local_fire_department)),
              const SizedBox(width: 15),
              // 🔹 Using AppColors.stepsGreen if available, else a standard color
              Expanded(child: _buildNutrientItem("Protein", "120", "150 g", AppColors.stepsGreen, Icons.egg_alt)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildNutrientItem("Carbs", "180", "220 g", Colors.teal, Icons.bakery_dining)),
              const SizedBox(width: 15),
              Expanded(child: _buildNutrientItem("Fats", "65", "80 g", Colors.cyan, Icons.opacity)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(String label, String current, String total, Color color, IconData icon) {
    double progress = double.parse(current) / double.parse(total.split(' ')[0]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(current, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(" / $total", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
      ],
    );
  }

  /// 🔹 3. FutureBuilder for Meals List
  Widget _buildMealsList() {
    return FutureBuilder<List<Meal>>(
      future: _mealService.fetchTodayMeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading meals"));
        } else {
          final meals = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: meals.length,
            itemBuilder: (context, index) => _buildMealCard(meals[index]),
          );
        }
      },
    );
  }

  /// 🔹 4. Individual Meal Card
  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(image: NetworkImage(meal.imageUrl), fit: BoxFit.cover),
                ),
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 15, left: 15,
                child: Text(meal.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                top: 15, left: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(_getIconForCategory(meal.categoryIcon), size: 16, color: AppColors.stepsGreen), // 🔹 AppColors
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(meal.time, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: AppColors.caloriesOrange, size: 16), // 🔹 AppColors
                        Text(" ${meal.totalCalories} cal", style: const TextStyle(fontWeight: FontWeight.bold)),                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: meal.ingredients.map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
// We need to specify '.name' because 'item' is now a RecipeIngredient object!
                      child: Text(item.name, style: TextStyle(fontSize: 12, color: Colors.grey[800])),                    )).toList(),
                  ),
                ),
                const SizedBox(height: 15),

                // 🔹 MATCHING BUTTON STYLES
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary, // 🔹 Use core theme gradient
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child:TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealDetailScreen(meal: meal),
                        ),
                      );
                    },
                    child: const Text("View Details >", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'coffee': return Icons.local_cafe;
      case 'salad': return Icons.eco;
      case 'fish': return Icons.set_meal;
      default: return Icons.restaurant;
    }
  }

  /// 🔹 5. Bottom Floating Actions
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary, // 🔹 Use core theme gradient
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                  onPressed: () {},
                  child: const Text("+ Log a Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87),
                label: const Text("Scan Meal", style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
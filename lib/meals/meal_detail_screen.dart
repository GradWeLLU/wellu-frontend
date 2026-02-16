import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'meal_model.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late List<RecipeIngredient> _ingredients;

  @override
  void initState() {
    super.initState();
    // Clone the ingredients so we can safely modify quantities
    _ingredients = widget.meal.ingredients.map((i) => RecipeIngredient(
      name: i.name, unit: i.unit, quantity: i.quantity,
      baseCalories: i.baseCalories, baseProtein: i.baseProtein,
      baseCarbs: i.baseCarbs, baseFats: i.baseFats,
    )).toList();
  }

  // 🧮 LOGIC: Recalculate totals dynamically
  double get totalCalories => _ingredients.fold(0, (sum, i) => sum + (i.baseCalories * i.quantity));
  double get totalProtein => _ingredients.fold(0, (sum, i) => sum + (i.baseProtein * i.quantity));
  double get totalCarbs => _ingredients.fold(0, (sum, i) => sum + (i.baseCarbs * i.quantity));
  double get totalFats => _ingredients.fold(0, (sum, i) => sum + (i.baseFats * i.quantity));

  void _updateQuantity(int index, double delta) {
    setState(() {
      if (_ingredients[index].quantity + delta >= 0.5) {
        _ingredients[index].quantity += delta;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildNutritionFacts(),
                      const SizedBox(height: 20),
                      _buildIngredientsList(),
                      const SizedBox(height: 20),
                      _buildMealTips(),

                      // ✅ ADD THIS INSTEAD to give space for the floating button
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Log Button
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildLogButton(),
          ),
        ],
      ),
    );
  }

  /// 🖼️ 1. Expanding Header Image
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: AppColors.stepsGreen, // Matches your theme
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.meal.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.meal.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(widget.meal.time, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 2. Dynamic Nutrition Facts Card
  Widget _buildNutritionFacts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nutrition Facts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem(AppColors.caloriesOrange, Icons.local_fire_department, totalCalories.toInt().toString(), "calories"),
              _buildMacroItem(const Color(0xFFFF2D7B), Icons.set_meal, "${totalProtein.toInt()}g", "protein"),
              _buildMacroItem(const Color(0xFFF5A623), Icons.grass, "${totalCarbs.toInt()}g", "carbs"),
              _buildMacroItem(AppColors.workoutBlue, Icons.water_drop, "${totalFats.toInt()}g", "fats"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(Color color, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          height: 50, width: 50,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  /// 🥬 3. Ingredients List with Logic Stepper
  Widget _buildIngredientsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ingredients", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ...List.generate(_ingredients.length, (index) {
            final item = _ingredients[index];
            final itemCal = (item.baseCalories * item.quantity).toInt();
            final itemPro = (item.baseProtein * item.quantity).toInt();

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("$itemCal cal • ${itemPro}g protein", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildStepper(index, item.quantity, item.unit),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepper(int index, double quantity, String unit) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _updateQuantity(index, -0.5),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.remove, size: 16, color: Colors.black54),
          ),
        ),
        const SizedBox(width: 12),
        Text("$quantity $unit", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _updateQuantity(index, 0.5),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.add, size: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  /// 💡 4. Meal Tips Card
  Widget _buildMealTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.stepsGreen.withOpacity(0.05), // Uses your theme color lightly
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stepsGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.caloriesOrange, size: 20),
              const SizedBox(width: 8),
              const Text("Meal Tips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.meal.mealTips,
            style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// ✅ 5. Bottom Log Button
  Widget _buildLogButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: AppGradients.primary, // Using your theme gradient
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged ${totalCalories.toInt()} calories! ✅'),
                  backgroundColor: AppColors.stepsGreen,
                ),
              );
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text("Log This Meal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
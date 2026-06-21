import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'meal_model.dart';
import 'meal_service.dart';
import '../../meals/meal_detail_screen.dart';
import 'today_logs_screen.dart'; // 👈 Make sure to import your new screen here!

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealService _mealService = MealService();

  // 🔄 Changed this to toggle between Plan and Logged!
  bool isPlanSelected = true;

  MealPlanResponse? _mealPlanResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    const String apiUrl = 'http://10.0.2.2:8082/nutrition/plans';

    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) {
      setState(() {
        _error = "Session expired. Please log in again.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        setState(() {
          if (decodedData is List && decodedData.isNotEmpty) {
            _mealPlanResponse = MealPlanResponse.fromJson(decodedData[0]);
          } else if (decodedData is Map<String, dynamic>) {
            _mealPlanResponse = MealPlanResponse.fromJson(decodedData);
          } else {
            _error = "No meal plans found.";
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Server error (${response.statusCode})";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to process meal data.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text("Error: $_error", style: const TextStyle(color: Colors.red, fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Nutrition", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildToggleSwitch(),

          // 🔀 Here is the magic! It swaps the entire screen based on the toggle!
          Expanded(
            child: isPlanSelected
                ? _buildPlanView()
                : const TodayLogsScreen(),
          ),
        ],
      ),
    );
  }

  // 📦 Extracted your Plan layout into its own widget function
  Widget _buildPlanView() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
    );
  }

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
                onTap: () => setState(() => isPlanSelected = true),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isPlanSelected ? AppGradients.primary : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text("Plan", style: TextStyle(color: isPlanSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isPlanSelected = false),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: !isPlanSelected ? AppGradients.primary : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text("Logged", style: TextStyle(color: !isPlanSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    if (_mealPlanResponse == null || _mealPlanResponse!.days.isEmpty) return const SizedBox();

    final currentMeals = _mealPlanResponse!.days[0].meals; // Always fetching index 0 for today now
    int dailyCalories = 0;
    double dailyProtein = 0;
    double dailyCarbs = 0;
    double dailyFats = 0;

    for (var meal in currentMeals) {
      dailyCalories += meal.calories;
      dailyProtein += meal.protein;
      dailyCarbs += meal.carbs;
      dailyFats += meal.fat;
    }

    int targetCalories = 2000;
    int targetProtein = 150;
    int targetCarbs = 200;
    int targetFats = 70;

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
          const Text("Today's Nutrition Plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildNutrientItem("Calories", "$dailyCalories", "$targetCalories kcal", const Color(0xFFFF9800), Icons.local_fire_department)),
              const SizedBox(width: 15),
              Expanded(child: _buildNutrientItem("Protein", "${dailyProtein.toInt()}", "$targetProtein g", const Color(0xFF4CAF50), Icons.egg_alt)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildNutrientItem("Carbs", "${dailyCarbs.toInt()}", "$targetCarbs g", Colors.teal, Icons.bakery_dining)),
              const SizedBox(width: 15),
              Expanded(child: _buildNutrientItem("Fats", "${dailyFats.toInt()}", "$targetFats g", Colors.cyan, Icons.opacity)),
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
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation<Color>(color), borderRadius: BorderRadius.circular(10), minHeight: 6),
      ],
    );
  }

  Widget _buildMealsList() {
    if (_mealPlanResponse == null || _mealPlanResponse!.days.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No meals planned yet!", style: TextStyle(color: Colors.grey))));
    }

    final currentMeals = _mealPlanResponse!.days[0].meals;
    if (currentMeals.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No meals found for this day.", style: TextStyle(color: Colors.grey))));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: currentMeals.length,
      itemBuilder: (context, index) => _buildMealCard(currentMeals[index]),
    );
  }

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
              Container(height: 160, decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(24)), color: Colors.grey)),
              Container(height: 160, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
              Positioned(bottom: 15, left: 15, child: Text(meal.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Positioned(top: 15, left: 15, child: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: Icon(_getIconForCategory(meal.mealType), size: 10, color: const Color(0xFF4CAF50)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFFFF9800), size: 16),
                        Text(" ${meal.calories} cal", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: meal.ingredients.take(4).map((ingredient) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                      child: Text(ingredient, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity, height: 45,
                  decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(15)),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailScreen(meal: meal)));
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
    String lowerCat = category.toLowerCase();
    if (lowerCat.contains('coffee') || lowerCat.contains('breakfast')) return Icons.local_cafe;
    if (lowerCat.contains('salad') || lowerCat.contains('lunch')) return Icons.eco;
    if (lowerCat.contains('fish') || lowerCat.contains('dinner')) return Icons.set_meal;
    return Icons.restaurant;
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 50, decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(15)),
                child: TextButton(onPressed: () {}, child: const Text("+ Log a Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87),
                label: const Text("Scan", style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
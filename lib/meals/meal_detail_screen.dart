import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  // State variable to show a loading spinner on the button
  bool _isLogging = false;

  Future<void> _logMealToBackend() async {
    setState(() => _isLogging = true);

    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expired.'), backgroundColor: Colors.red));
      setState(() => _isLogging = false);
      return;
    }

    try {
      final String todayDate = DateTime.now().toIso8601String().split('T')[0];

      // 🛠️ FIX 1: Change to String? instead of int? to handle UUIDs
      String? currentLogId;

      // 1️⃣ CHECK IF TODAY'S LOG EXISTS
      final getLogsResponse = await http.get(
        Uri.parse('http://10.0.2.2:8081/mealLogs'),
        headers: {'Authorization': 'Bearer $myToken'},
      );

      if (getLogsResponse.statusCode == 200) {
        final List<dynamic> logs = json.decode(getLogsResponse.body);
        final todayLog = logs.firstWhere(
                (log) => log['mealDate'] == todayDate,
            orElse: () => null
        );

        if (todayLog != null) {
          var rawId = todayLog['id'] ?? todayLog['logId'];
          // 🛠️ FIX 2: Just save it as a string! No more int.tryParse
          if (rawId != null) currentLogId = rawId.toString();
        }
      }

      // 2️⃣ IF NO LOG FOR TODAY, CREATE ONE
      if (currentLogId == null) {
        final createLogResponse = await http.post(
          Uri.parse('http://10.0.2.2:8081/mealLogs'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $myToken'},
          body: json.encode({'mealDate': todayDate}),
        );

        if (createLogResponse.statusCode == 200 || createLogResponse.statusCode == 201) {
          final newLog = json.decode(createLogResponse.body);
          var rawNewId = newLog['id'] ?? newLog['logId'];

          // 🛠️ FIX 3: Save as string here too
          if (rawNewId != null) currentLogId = rawNewId.toString();
        } else {
          throw Exception("Failed to create daily log.");
        }
      }

      // 3️⃣ ADD THE MEAL ENTRY USING THE LOG ID
      if (currentLogId != null) {
        final entryBody = {
          "mealType": widget.meal.mealType.toUpperCase(),
          "mealName": widget.meal.name,
          "foodItems": widget.meal.ingredients,
          "calories": widget.meal.calories is String ? int.tryParse(widget.meal.calories.toString()) : widget.meal.calories,
          "protein": widget.meal.protein is String ? double.tryParse(widget.meal.protein.toString()) : widget.meal.protein,
          "carbs": widget.meal.carbs is String ? double.tryParse(widget.meal.carbs.toString()) : widget.meal.carbs,
          "fats": widget.meal.fat is String ? double.tryParse(widget.meal.fat.toString()) : widget.meal.fat,
          "notes": "Logged from Meal Plan"
        };

        final addEntryResponse = await http.post(
          Uri.parse('http://10.0.2.2:8081/mealLogs/addEntry/$currentLogId'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $myToken'},
          body: json.encode(entryBody),
        );

        if (addEntryResponse.statusCode == 200 || addEntryResponse.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged ${widget.meal.calories} calories! ✅'), backgroundColor: Colors.green));
            Navigator.pop(context);
          }
        } else {
          throw Exception("Failed to add entry. Status: ${addEntryResponse.statusCode}");
        }
      } else {
        throw Exception("Could not find or create a valid log ID for today.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildNutritionFacts(),
                      const SizedBox(height: 20),
                      _buildIngredientsList(),

                      // Space for the floating button so it doesn't cover your long list of ingredients!
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
      backgroundColor: AppColors.stepsGreen,
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
            // Placeholder color if you don't have an image URL yet
            Container(color: Colors.grey.shade300),

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
                  Text(widget.meal.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(widget.meal.mealType, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 2. Static Nutrition Facts Card (Reads directly from backend)
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
              _buildMacroItem(AppColors.caloriesOrange, Icons.local_fire_department, "${widget.meal.calories}", "calories"),
              _buildMacroItem(const Color(0xFFFF2D7B), Icons.set_meal, "${widget.meal.protein.toInt()}g", "protein"),
              _buildMacroItem(const Color(0xFFF5A623), Icons.grass, "${widget.meal.carbs.toInt()}g", "carbs"),
              _buildMacroItem(AppColors.workoutBlue, Icons.water_drop, "${widget.meal.fat.toInt()}g", "fats"),
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

  /// 🥬 3. Simple Wrapping Ingredients List
  Widget _buildIngredientsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ingredients (${widget.meal.ingredients.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // Using a Wrap so if there are 20 ingredients, they flow nicely onto the next lines!
          Wrap(
            spacing: 8.0, // Gap between adjacent chips
            runSpacing: 8.0, // Gap between lines
            children: widget.meal.ingredients.map((ingredient) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.stepsGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.stepsGreen.withOpacity(0.3)),
                ),
                child: Text(
                  ingredient,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// ✅ 4. Bottom Log Button
  Widget _buildLogButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: TextButton.icon(
            onPressed: _isLogging ? null : _logMealToBackend,
            icon: _isLogging
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
                _isLogging ? "Logging..." : "Log This Meal",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
        ),
      ),
    );
  }
}
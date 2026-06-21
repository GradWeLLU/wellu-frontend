import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

class TodayLogsScreen extends StatefulWidget {
  const TodayLogsScreen({super.key});

  @override
  State<TodayLogsScreen> createState() => _TodayLogsScreenState();
}

class _TodayLogsScreenState extends State<TodayLogsScreen> {
  bool _isLoading = true;
  String? _error;

  // Actual totals calculated from backend
  int _totalCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFats = 0;

  // List to hold today's meal entries
  List<dynamic> _todayEntries = [];

  @override
  void initState() {
    super.initState();
    _loadTodayLogs();
  }
  Future<void> _loadTodayLogs() async {
    const String baseUrl = 'http://10.0.2.2:8081/mealLogs';

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
      String todayDate = DateTime.now().toIso8601String().split('T')[0];

      // 1️⃣ Changed to a NEW key name to avoid crashing on old, broken integer data!
      String prefKey = 'log_uuid_$todayDate';

      // 2️⃣ UUIDs are Strings! Changed from getInt to getString
      String? todayLogId = prefs.getString(prefKey);

      Map<String, dynamic>? todayLogData;

      if (todayLogId != null) {
        print("🎯 Using specific API: GET /mealLogs/$todayLogId");
        final response = await http.get(
          Uri.parse('$baseUrl/$todayLogId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $myToken',
          },
        );

        if (response.statusCode == 200) {
          todayLogData = json.decode(response.body);
        }
      }

      if (todayLogData == null) {
        print("🔍 ID not found locally. Searching all logs...");
        final response = await http.get(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $myToken',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> allLogs = json.decode(response.body);

          // 3️⃣ Bulletproof loop (safer than firstWhere which can crash if not found)
          for (var log in allLogs) {
            if (log['mealDate'] == todayDate) {
              todayLogData = log;
              break;
            }
          }

          if (todayLogData != null) {
            // 4️⃣ Safely extract the UUID as a String and save it
            var rawId = todayLogData['id'] ?? todayLogData['logId'];
            if (rawId != null) {
              await prefs.setString(prefKey, rawId.toString());
            }
          }
        }
      }

      if (todayLogData != null) {
        // Check for both 'entries' and 'mealEntries' depending on your Spring Boot DTO
        List<dynamic> entries = todayLogData['entries'] ?? todayLogData['mealEntries'] ?? [];

        int calcCals = 0;
        int calcPro = 0;
        int calcCarbs = 0;
        int calcFats = 0;

        for (var entry in entries) {
          // 5️⃣ Bulletproof Macro Parsing (handles Strings, Ints, and Decimals safely)
          calcCals += (double.tryParse(entry['calories']?.toString() ?? '0') ?? 0).toInt();
          calcPro += (double.tryParse(entry['protein']?.toString() ?? '0') ?? 0).toInt();
          calcCarbs += (double.tryParse(entry['carbs']?.toString() ?? '0') ?? 0).toInt();
          calcFats += (double.tryParse(entry['fats']?.toString() ?? '0') ?? 0).toInt();
        }

        setState(() {
          _todayEntries = entries;
          _totalCalories = calcCals;
          _totalProtein = calcPro;
          _totalCarbs = calcCarbs;
          _totalFats = calcFats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _todayEntries = [];
          _isLoading = false;
        });
      }

    } catch (e) {
      // 🚨 If it STILL crashes, this print statement will tell us exactly why!
      print("🚨 CRITICAL FETCH ERROR: $e");
      setState(() {
        _error = "Failed to load logs: $e"; // Will show on your phone screen!
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // Removed Scaffold
    }

    if (_error != null) {
      return Center(child: Text("Error: $_error", style: const TextStyle(color: Colors.red))); // Removed Scaffold
    }

    // 👇 Just return the SingleChildScrollView directly!
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActualNutritionSummary(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
                "Logged Meals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
          _buildEntriesList(),
        ],
      ),
    );
  }

  Widget _buildActualNutritionSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary, // Using your gradient for a premium look!
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Text("Total Consumed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("$_totalCalories", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const Text(" kcal", style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroColumn("Protein", "$_totalProtein g"),
              _buildDivider(),
              _buildMacroColumn("Carbs", "$_totalCarbs g"),
              _buildDivider(),
              _buildMacroColumn("Fats", "$_totalFats g"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white30);
  }

  Widget _buildEntriesList() {
    if (_todayEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text("You haven't logged any meals today!", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _todayEntries.length,
      itemBuilder: (context, index) {
        final entry = _todayEntries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.stepsGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, color: Colors.green),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['mealName'] ?? 'Unknown Meal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(entry['mealType'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${entry['calories']} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 4),
              Text("P:${entry['protein']} C:${entry['carbs']} F:${entry['fats']}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}
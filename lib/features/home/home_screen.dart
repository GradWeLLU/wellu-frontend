import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../workout/screens/workout_plan_screen.dart';
import '../../ai_chat/chat_screen.dart';


import 'widgets/stat_card.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/greeting_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomNavigation(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              /// 🔹 Greeting
              const GreetingSection(name: "tawfik"),

              const SizedBox(height: 30),



              const StatCard(
                icon: Icons.local_fire_department,
                iconBgColor: AppColors.caloriesOrange,
                title: "Calories",
                value: "420 / 600 cal",
                progress: 0.9,
                progressColor: AppColors.caloriesOrange,
              ),

              const StatCard(
                icon: Icons.fitness_center,
                iconBgColor: AppColors.workoutBlue,
                title: "Workout",
                value: "15 / 30 min",
                progress: 0.5,
                progressColor: AppColors.workoutBlue,
              ),

              const SizedBox(height: 10),

              /// 🔹 AI Assistant Card
              AIAssistantCard(
                onChatTap: () {
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatScreen(),
                      ),
                    );
                  }
                  // TODO: Navigate to AI Chat Screen
                },
              ),

              const SizedBox(height: 20),

              /// 🔹 Meals Feature
              FeatureCard(
                title: "Today's Meals",
                subtitle: "Track your nutrition",
                buttonText: "View Meal Plans",
                buttonGradient: AppGradients.primary,
                onPressed: () {
                  // TODO: Navigate to Nutrition Screen
                },
              ),

              /// 🔹 Workout Plan Feature
              FeatureCard(
                title: "Your Workout Plan",
                subtitle: "30 min strength training",
                buttonText: "Open Workout Plan",
                buttonGradient: AppGradients.workout,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkoutPlanScreen(),
                    ),
                  );

                },
              ),

              /// 🔹 Posture Feature
              FeatureCard(
                title: "Check Workout Posture",
                subtitle: "AI-powered form analysis",
                buttonText: "Check Posture",
                buttonGradient: AppGradients.posture,
                onPressed: () {
                  // TODO: Navigate to Posture Detection Screen
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Bottom Navigation
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: AppColors.stepsGreen,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "Learning",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Community",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}

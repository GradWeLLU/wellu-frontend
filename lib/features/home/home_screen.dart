import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../workout/screens/workout_plan_screen.dart';
import '../educational/screens/education_screen.dart';

import '../workout/services/workout_service.dart'; // Make sure this is imported
import '../../ai_chat/chat_screen.dart';
import '../../meals/meal_plan_screen.dart';
// ADDED IMPORT HERE: Update the path if you placed the file in a different folder
import '../posture/screens/check_posture_screen.dart';


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
      bottomNavigationBar: _buildBottomNavigation(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              /// 🔹 Greeting
              const GreetingSection(name: "Tawfik"),

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealPlanScreen(),
                    ),
                  );
                },
              ),

              /// 🔹 Workout Plan Feature
            /// 🔹 Workout Plan Feature
              FeatureCard(
                title: "Your Workout Plan",
                subtitle: "View your weekly schedule",
                buttonText: "Open Workout Plan",
                buttonGradient: AppGradients.workout,
                onPressed: () {
                  // Just navigate straight to the screen!
                  // The WorkoutPlanScreen handles its own loading and fetching now. 🛠️
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WorkoutPlanScreen(),
                    ),
                  );
                },
              ),

              /// 🔹 Posture Feature
              /// 🔹 Posture Feature
              FeatureCard(
                title: "Bench Press Tracker",
                subtitle: "AI-powered form analysis",
                buttonText: "Start Tracking",
                buttonGradient: AppGradients.posture,
                onPressed: () async {
                  // 1. Grab the phone's cameras instantly
                  final cameras = await availableCameras();

                  if (context.mounted) {
                    // 2. Push directly to the camera screen and lock in Bench Press!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PoseDetectorScreen(
                          cameras: cameras,
                          exerciseTitle: "Bench Press", // 👈 Hardcoded forever!
                        ),
                      ),
                    );
                  }
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

  /// 🔹 Bottom Navigation
  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // 0 because this is the Home screen
      selectedItemColor: AppColors.stepsGreen,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,

      // 🔹 Add the onTap navigation here!
      onTap: (index) {
        if (index == 0) {
          // Already on Home, do nothing
          return;
        } else if (index == 1) {
          // Navigate to Learning (Education Screen)
          Navigator.push(
            context,
            MaterialPageRoute(
              // Replace "dummy_id" with your actual user ID logic later!
              builder: (context) => const EducationScreen(),
            ),
          );
        } else if (index == 2) {
          // Navigate to Dashboard (When ready)
        } else if (index == 3) {
          // Navigate to Community (When ready)
        } else if (index == 4) {
          // Navigate to Profile (When ready)
        }
      },

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
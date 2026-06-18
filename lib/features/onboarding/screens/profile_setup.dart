import 'package:flutter/material.dart';
import 'dart:convert'; // 🌟 This gives you the jsonEncode superpower!
 import '../../home/home_screen.dart'; // Make sure your path is correct!
import '../screens/user_profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../workout/services/workout_service.dart';
import '../../../meals/meal_service.dart';

import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int currentStep = 0;
  static const int totalSteps = 13;

  // 🌟 Your brand new, strongly-typed Data Model!
  final UserProfileModel userProfile = UserProfileModel();

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    bool _isLoading = false;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF22E1A0),
              Color(0xFF1E88E5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ─────────── Progress Header ───────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  children: [
                    Text(
                      'Step ${currentStep + 1} of $totalSteps',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ─────────── Card ───────────
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepContent(),
                            const SizedBox(height: 32),

                            // ─────────── Dynamic Bottom Buttons ───────────
                            if (currentStep == 12) ...[
                              // 🌟 Step 11: Final Summary Screen (Stacked Buttons)
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                                    ),
                                  ),
                                    child: ElevatedButton(
                                      // 👇 1. Disable the button if it is already loading so they can't spam it!
                                      onPressed: _isLoading ? null : () async {
                                        setState(() {
                                          _isLoading = true; // Tell the UI we are starting!
                                        });

                                        try {
                                          // 1. First, send the profile to the backend
                                          bool profileSaved = await submitProfile();

                                          // 2. ONLY if the profile was saved successfully, generate the workout
                                          if (profileSaved) {
                                            final workoutService = WorkoutService();
                                            final mealService = MealService();
                                            String result = await workoutService.fetchWorkoutPlan();
                                            String mealResult = await mealService.fetchNutritonPlan();

                                            if (result == "ok" && mealResult == "ok" && context.mounted) {
                                              // 3. Success! Now go to the Home Screen 🚀
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Oops! Something went wrong: $e")),
                                            );
                                          }
                                        } finally {
                                          // 👇 2. ALWAYS run this at the end to stop the loading spinner
                                          if (context.mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28),
                                        ),
                                      ),
                                      // 👇 3. Show a spinner if loading, otherwise show the text
                                      child: _isLoading
                                          ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                          : const Text(
                                        'Generate My Personalized Plan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ), // 👈 FIX 1: Added missing closing bracket for DecoratedBox
                              ), // 👈 FIX 1: Added missing closing bracket for DecoratedBox
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() => currentStep = 0);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (currentStep == 4 || currentStep == 9) ...[
                              // 🌟 Steps 5 & 10: Skip & Continue
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 60,
                                      child: OutlinedButton(
                                        onPressed: _nextStep,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                        ),
                                        child: const Text(
                                          'Skip',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SizedBox(
                                      height: 60,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _nextStep,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                          ),
                                          child: const Text(
                                            'Continue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ] else ...[
                              // 🌟 All other steps: Single Main Button
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: Text(
                                      currentStep == 0 ? 'Start' : 'Continue',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Logic: Send the complete profile to the backend!
  // Logic: Returns true if saved, false if failed
  Future<bool> submitProfile() async {
    // 1. Grab the saved VIP Pass (Token) 🎟️
    final prefs = await SharedPreferences.getInstance();
    final String? myToken = prefs.getString('auth_token');

    if (myToken == null) {
      print("❌ No token found!");
      return false;
    }

    // 2. The Backend Endpoint
    final url = Uri.parse("http://10.0.2.2:8081/profile/me/onboarding");


    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $myToken",
        },
        body: jsonEncode(userProfile.toJson()),
      );
      print("📦 SENDING PROFILE DATA: ${jsonEncode(userProfile.toJson())}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Profile successfully saved to the database!");
        return true; // ✨ Success!
      } else {
        print("❌ Server rejected the profile: ${response.statusCode}");

        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save profile: ${response.body}")),
        );
        return false; // 🛑 Failed
      }
    } catch (e) {
      print("💥 Connection error: $e");

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection failed. Check your network.")),
      );
      return false; // 🛑 Failed
    }
  }

  // 🌟 Updated to use your new Model!
  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _startStep();
      case 1:
        return _GenderStep(
          onSelected: (val) => userProfile.gender = val,
          onBack: () => setState(() => currentStep--),
        );
      case 2:
        return _BodyStatsStep(onSaved: (val) {
          // The ?? 0.0 means "if it's somehow null, use 0.0 so we don't crash"
          userProfile.age = (val['age'] ?? 0.0).toInt();
          userProfile.height = (val['height'] ?? 0.0).toInt();
          userProfile.weight = (val['weight'] ?? 0.0).toInt();
        });
      case 3:
        return _MainGoalStep(onSaved: (val) => userProfile.mainGoals = val);
      case 4:
        return _PrecisionStep(onSaved: (val) {
          //userProfile.bodyType = val['bodyType'] as String?;
          //userProfile.bodyFat = val['bodyFat'] as double?;
          //userProfile.muscleMass = val['muscleMass'] as String?;
        });
      case 5:
        return _FitnessLevelStep(onSaved: (val) => userProfile.fitnessLevel = val);
      case 6:
        return _TrainingPreferenceStep(onSaved: (val) {
          userProfile.duration = (val['duration'] ?? 0.0).toInt();
          userProfile.intensity = val['intensity'];
        });
      case 7:
        return _WorkoutTimeStep(onSaved: (val) => userProfile.workoutTime = val);
      case 8:
        return _DietPreferenceStep(onSaved: (val) => userProfile.diet = val);
      case 9:
        return _InjuryStep(
          onSaved: (val) {
            // 'val' is now the Map with all our cool new date and status info!
            userProfile.injuryDetails = val;
          },

        );
      case 10:
       /** return _SummaryStep(data: userProfile); // Pass the model down**/
       return _MedicationStep(
       onSaved: (val) {
         userProfile.medicationDetails = val;
    },
    );
      case 11:
        return _AllergyStep(
          onSaved: (val) {
            userProfile.allergyDetails = val;
          },
        );
      case 12:
       return _SummaryStep(data: userProfile); // Pass the model down**/

      default:
        return const Text('Next steps coming...');
    }
  }

  void _nextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
    }
  }
}

// ─────────── Step Widgets ───────────

class _startStep extends StatefulWidget {
  const _startStep({super.key });
  @override
  State<_startStep> createState() => _startStepState();
}

class _startStepState extends State<_startStep> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.track_changes, size: 64, color: Color(0xFF2979FF)),
        SizedBox(height: 16),
        Text(
          "Let's build your WellU profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'No forms. Just a few smart choices.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
      ],
    );
  }
}

class _GenderStep extends StatefulWidget {
  final Function(String) onSelected;
  final VoidCallback onBack;
  const _GenderStep({required this.onSelected, required this.onBack});
  @override
  State<_GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<_GenderStep> {
  String? selectedGender;
  final genders = [
    {'label': 'Male', 'icon': Icons.person_outline},
    {'label': 'Female', 'icon': Icons.people_outline},
    {'label': 'Prefer not to say', 'icon': Icons.person_off_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'I identify as…',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...genders.map((gender) {
          final isSelected = selectedGender == gender['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedGender = gender['label'] as String);
                widget.onSelected(gender['label'] as String);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(gender['icon'] as IconData, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      gender['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onBack,
          child: const Text('Back', style: TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}

class GradientThumbShape extends SliderComponentShape {
  final double thumbRadius;
  const GradientThumbShape({this.thumbRadius = 14.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(thumbRadius);

  @override
  void paint(
      PaintingContext context, Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;
    final Paint gradientPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)])
          .createShader(Rect.fromCircle(center: center, radius: thumbRadius))
      ..style = PaintingStyle.fill;
    final Paint whitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, gradientPaint);
    canvas.drawCircle(center, thumbRadius - 4, whitePaint);
  }
}

class _BodyStatsStep extends StatefulWidget {
  final Function(Map<String, double>) onSaved;
  const _BodyStatsStep({required this.onSaved});
  @override
  State<_BodyStatsStep> createState() => _BodyStatsStepState();
}

class _BodyStatsStepState extends State<_BodyStatsStep> {
  double age = 25;
  double heightVal = 170;
  double weightVal = 70;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Tell us a bit about your body',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildCustomSlider(
          label: 'Age', value: age, min: 18, max: 65, unit: '',
          onChanged: (val) { setState(() => age = val); _saveData(); },
        ),
        const SizedBox(height: 24),
        _buildCustomSlider(
          label: 'Height', value: heightVal, min: 140, max: 220, unit: '',
          onChanged: (val) { setState(() => heightVal = val); _saveData(); },
        ),
        const SizedBox(height: 24),
        _buildCustomSlider(
          label: 'Weight', value: weightVal, min: 40, max: 150, unit: ' kg',
          onChanged: (val) { setState(() => weightVal = val); _saveData(); },
        ),
      ],
    );
  }

  void _saveData() {
    widget.onSaved({'age': age, 'height': heightVal, 'weight': weightVal});
  }

  Widget _buildCustomSlider({
    required String label, required double value, required double min,
    required double max, required String unit, required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toInt()}$unit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: const Color(0xFF22E1A0),
            inactiveTrackColor: Colors.grey.shade200,
            thumbShape: const GradientThumbShape(thumbRadius: 14),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              Text('${max.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainGoalStep extends StatefulWidget {
  // 👇 Changed from List<String> to String
  final Function(String) onSaved;

  const _MainGoalStep({required this.onSaved});

  @override
  State<_MainGoalStep> createState() => _MainGoalStepState();
}

class _MainGoalStepState extends State<_MainGoalStep> {
  // 👇 Now just tracks one single choice
  String? selectedGoal;

  final List<Map<String, dynamic>> goals = [
    {'label': 'Fat Loss', 'icon': Icons.local_fire_department_outlined},
    {'label': 'Muscle Gain', 'icon': Icons.fitness_center},
    {'label': 'Strength', 'icon': Icons.bolt_outlined},
    {'label': 'General Health', 'icon': Icons.favorite_border},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "What's your main goal?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          // 👇 Updated the subtitle text to match the new logic
          'Select the one that matters most to you',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...goals.map((goal) {
          final label = goal['label'] as String;
          // 👇 Simply checks if this item matches the single selected goal
          final isSelected = selectedGoal == label;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedGoal = label; // Sets the new choice
                });
                widget.onSaved(selectedGoal!); // Sends back just the String
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)) : null,
                      ),
                      child: Icon(
                        goal['icon'] as IconData,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _PrecisionStep extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;
  const _PrecisionStep({required this.onSaved});
  @override
  State<_PrecisionStep> createState() => _PrecisionStepState();
}

class _PrecisionStepState extends State<_PrecisionStep> {
  String? selectedBodyType;
  bool showAdvancedNumbers = false;
  double bodyFat = 20;
  String? selectedMuscleMass;
  final List<Map<String, dynamic>> bodyTypes = [
    {'label': 'Lean / Athletic', 'icon': Icons.monitor_heart_outlined},
    {'label': 'Average', 'icon': Icons.person_outline},
    {'label': 'Soft', 'icon': Icons.account_circle_outlined},
    {'label': 'Overfat', 'icon': Icons.group_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Want us to be more precise?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'This helps us personalize better',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...bodyTypes.map((type) {
          final isSelected = selectedBodyType == type['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedBodyType = type['label'] as String);
                _saveData();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)) : null,
                      ),
                      child: Icon(
                        type['icon'] as IconData,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: () => setState(() => showAdvancedNumbers = !showAdvancedNumbers),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              showAdvancedNumbers ? '- Hide' : '+ I know my numbers',
              style: TextStyle(
                color: showAdvancedNumbers ? Colors.grey.shade500 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (showAdvancedNumbers) ...[
          const SizedBox(height: 32),
          _buildCustomSlider(
            label: 'Body Fat %', value: bodyFat, min: 5, max: 50, unit: ' %',
            onChanged: (val) { setState(() => bodyFat = val); _saveData(); },
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Muscle Mass', style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              Row(
                children: ['Low', 'Medium', 'High'].map((level) {
                  final isSelected = selectedMuscleMass == level;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: level != 'High' ? 8.0 : 0,
                        left: level != 'Low' ? 8.0 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () { setState(() => selectedMuscleMass = level); _saveData(); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF22E1A0).withOpacity(0.05) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF22E1A0) : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF00C853) : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _saveData() {
    widget.onSaved({
      'bodyType': selectedBodyType,
      'bodyFat': showAdvancedNumbers ? bodyFat : null,
      'muscleMass': showAdvancedNumbers ? selectedMuscleMass : null,
    });
  }

  Widget _buildCustomSlider({
    required String label, required double value, required double min,
    required double max, required String unit, required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toInt()}$unit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: const Color(0xFF22E1A0),
            inactiveTrackColor: Colors.grey.shade200,
            thumbShape: const GradientThumbShape(thumbRadius: 14),
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              Text('${max.toInt()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FitnessLevelStep extends StatefulWidget {
  final Function(String) onSaved;
  const _FitnessLevelStep({required this.onSaved});
  @override
  State<_FitnessLevelStep> createState() => _FitnessLevelStepState();
}

class _FitnessLevelStepState extends State<_FitnessLevelStep> {
  String? selectedLevel;
  final List<Map<String, dynamic>> levels = [
    {'title': 'Beginner', 'subtitle': 'New to fitness', 'icon': Icons.show_chart},
    {'title': 'Intermediate', 'subtitle': 'Regular workouts', 'icon': Icons.trending_up},
    {'title': 'Advanced', 'subtitle': 'Experienced athlete', 'icon': Icons.bolt_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "How would you describe your fitness level?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...levels.map((level) {
          final isSelected = selectedLevel == level['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedLevel = level['title'] as String);
                widget.onSaved(selectedLevel!);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)) : null,
                      ),
                      child: Icon(
                        level['icon'] as IconData,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level['subtitle'] as String,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _TrainingPreferenceStep extends StatefulWidget {
  // 👇 1. Changed to Map<String, dynamic> so it can hold both int and String!
  final Function(Map<String, dynamic>) onSaved;

  const _TrainingPreferenceStep({required this.onSaved});

  @override
  State<_TrainingPreferenceStep> createState() => _TrainingPreferenceStepState();
}

class _TrainingPreferenceStepState extends State<_TrainingPreferenceStep> {
  // 👇 2. Changed to an int
  int? selectedDuration;
  String? selectedIntensity;

  // 👇 3. Updated the list to be actual numbers
  final List<int> durations = [30, 45, 60];

  final List<Map<String, dynamic>> intensities = [
    {'label': 'Beginner', 'icon': Icons.show_chart},
    {'label': 'Advanced', 'icon': Icons.local_fire_department_outlined},
  ];

  // Helper function to save data whenever an option is tapped
  void _saveData() {
    if (selectedDuration != null && selectedIntensity != null) {
      widget.onSaved({
        'duration': selectedDuration, // This sends an int!
        'intensity': selectedIntensity, // This sends a String!
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "How do you prefer to train?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        const Text('Duration', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...durations.map((duration) => _buildOptionCard(
          // 👇 4. Convert the int back to a String just for the UI display
          label: '$duration min',
          icon: Icons.access_time,
          isSelected: selectedDuration == duration,
          onTap: () {
            setState(() => selectedDuration = duration);
            _saveData();
          },
        )).toList(),
        const SizedBox(height: 16),
        const Text('Intensity', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...intensities.map((intensity) => _buildOptionCard(
          label: intensity['label'] as String,
          icon: intensity['icon'] as IconData,
          isSelected: selectedIntensity == intensity['label'],
          onTap: () {
            setState(() => selectedIntensity = intensity['label'] as String);
            _saveData();
          },
        )).toList(),
      ],
    );
  }


  Widget _buildOptionCard({
    required String label, required IconData icon, required bool isSelected, required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected ? Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)) : null,
                ),
                child: Icon(icon, color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade700, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutTimeStep extends StatefulWidget {
  final Function(String) onSaved;
  const _WorkoutTimeStep({required this.onSaved});
  @override
  State<_WorkoutTimeStep> createState() => _WorkoutTimeStepState();
}

class _WorkoutTimeStepState extends State<_WorkoutTimeStep> {
  String? selectedTime;
  final List<Map<String, dynamic>> times = [
    {'label': 'Morning', 'icon': Icons.wb_twilight},
    {'label': 'Afternoon', 'icon': Icons.light_mode_outlined},
    {'label': 'Evening', 'icon': Icons.brightness_3_outlined},
    {'label': 'Night', 'icon': Icons.dark_mode_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "When do you usually work out?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...times.map((time) {
          final isSelected = selectedTime == time['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedTime = time['label'] as String);
                widget.onSaved(selectedTime!);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF22E1A0).withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF22E1A0) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF1E88E5)])
                            : null,
                        color: isSelected ? null : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(time['icon'] as IconData, color: isSelected ? Colors.white : Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      time['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF22E1A0) : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF22E1A0), size: 24),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _DietPreferenceStep extends StatefulWidget {
  final Function(String) onSaved;
  const _DietPreferenceStep({required this.onSaved});
  @override
  State<_DietPreferenceStep> createState() => _DietPreferenceStepState();
}

class _DietPreferenceStepState extends State<_DietPreferenceStep> {
  String? selectedDiet;
  final List<Map<String, dynamic>> diets = [
    {'label': 'NONE', 'icon': Icons.restaurant},
    {'label': 'VEGETARIAN', 'icon': Icons.soup_kitchen_outlined},
    {'label': 'VEGAN', 'icon': Icons.eco_outlined},
    {'label': 'KETO', 'icon': Icons.set_meal_outlined},
    {'label': 'PALEO', 'icon': Icons.kebab_dining},
    {'label': 'HALAL', 'icon': Icons.verified_outlined},
    {'label': 'GLUTEN_FREE', 'icon': Icons.grass_outlined},
    {'label': 'LACTOSE_FREE', 'icon': Icons.local_drink_outlined},
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "How do you usually eat?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...diets.map((diet) {
          final isSelected = selectedDiet == diet['label'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedDiet = diet['label'] as String);
                widget.onSaved(selectedDiet!);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)) : null,
                      ),
                      child: Icon(diet['icon'] as IconData, color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      diet['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}



class _InjuryStep extends StatefulWidget {
  // Changed to pass a Map so we can send all the new data back to your model!
  final Function(Map<String, dynamic>?) onSaved;

  const _InjuryStep({required this.onSaved});

  @override
  State<_InjuryStep> createState() => _InjuryStepState();
}

class _InjuryStepState extends State<_InjuryStep> {
  bool? hasInjury;
  Set<String> selectedAreas = {};
  DateTime? startDate;
  DateTime? endDate;
  bool? stillFeelIt;

  final List<String> areas = ['Knee', 'Shoulder', 'Lower Back', 'Wrist', 'Ankle'];

  // Helper function to trigger the callback with the current state
  void _updateModel() {
    if (hasInjury == false) {
      widget.onSaved({'hasInjury': false});
    } else {
      widget.onSaved({
        'hasInjury': true,
        'areas': selectedAreas.toList(),
        'startDate': startDate,
        'endDate': endDate,
        'stillFeelIt': stillFeelIt,
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2979FF), // matching your app's blue
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      _updateModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrapped in SingleChildScrollView so it doesn't overflow when expanded
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Any physical injuries?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'This helps us keep your workout safe.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // 1. Do you have an injury?
          Row(
            children: [
              Expanded(child: _buildToggleBtn('No, I\'m good', hasInjury == false, () {
                setState(() => hasInjury = false);
                _updateModel();
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildToggleBtn('Yes, I do', hasInjury == true, () {
                setState(() => hasInjury = true);
                _updateModel();
              })),
            ],
          ),

          // Show the rest ONLY if they answered "Yes"
          if (hasInjury == true) ...[
            const SizedBox(height: 32),
            const Text(
              'Which areas?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Replaced the huge list with ChoiceChips to save space!
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: areas.map((area) {
                final isSelected = selectedAreas.contains(area);
                return ChoiceChip(
                  label: Text(area),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2979FF).withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      isSelected ? selectedAreas.remove(area) : selectedAreas.add(area);
                    });
                    _updateModel();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            const Text(
              'When did it happen?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildDatePickerBtn(
              label: startDate == null ? 'Select Start Date' : '${startDate!.year}-${startDate!.month}-${startDate!.day}',
              onTap: () => _pickDate(true),
            ),

            const SizedBox(height: 32),
            const Text(
              'Do you still feel pain or limitation?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildToggleBtn('Yes, still active', stillFeelIt == true, () {
                  setState(() {
                    stillFeelIt = true;
                    endDate = null; // Clear end date if it's still active
                  });
                  _updateModel();
                })),
                const SizedBox(width: 16),
                Expanded(child: _buildToggleBtn('No, fully healed', stillFeelIt == false, () {
                  setState(() => stillFeelIt = false);
                  _updateModel();
                })),
              ],
            ),

            // Only ask for End Date if they are fully healed
            if (stillFeelIt == false) ...[
              const SizedBox(height: 32),
              const Text(
                'When did it fully heal?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildDatePickerBtn(
                label: endDate == null ? 'Select End Date' : '${endDate!.year}-${endDate!.month}-${endDate!.day}',
                onTap: () => _pickDate(false),
              ),
            ]
          ],
        ],
      ),
    );
  }

  // --- Helper Widgets to keep your code clean! ---

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerBtn({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }
}
class _MedicationStep extends StatefulWidget {
  final Function(Map<String, dynamic>?) onSaved;

  const _MedicationStep({required this.onSaved});

  @override
  State<_MedicationStep> createState() => _MedicationStepState();
}

class _MedicationStepState extends State<_MedicationStep> {
  bool? takesMedication;
  String medicationName = '';
  String medicationReason = '';

  // Helper function to bundle the data and send it to the parent
  void _updateModel() {
    if (takesMedication == false) {
      widget.onSaved({'takesMedication': false});
    } else if (takesMedication == true) {
      widget.onSaved({
        'takesMedication': true,
        'medicationName': medicationName,
        'reason': medicationReason,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Do you take any medications?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'This helps us tailor your fitness plan safely.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // 1. The Yes/No Toggle
          Row(
            children: [
              Expanded(child: _buildToggleBtn('No, I don\'t', takesMedication == false, () {
                setState(() => takesMedication = false);
                _updateModel();
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildToggleBtn('Yes, I do', takesMedication == true, () {
                setState(() => takesMedication = true);
                _updateModel();
              })),
            ],
          ),

          // 2. The Text Fields (Only show if they say Yes!)
          if (takesMedication == true) ...[
            const SizedBox(height: 32),
            const Text(
              'What is the name of the medication?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'e.g., Albuterol Inhaler',
              onChanged: (val) {
                medicationName = val;
                _updateModel();
              },
            ),

            const SizedBox(height: 24),
            const Text(
              'What do you take it for?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'e.g., Asthma',
              onChanged: (val) {
                medicationReason = val;
                _updateModel();
              },
            ),
          ],
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required Function(String) onChanged}) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
        ),
      ),
    );
  }
}

class _AllergyStep extends StatefulWidget {
  final Function(Map<String, dynamic>?) onSaved;

  const _AllergyStep({required this.onSaved});

  @override
  State<_AllergyStep> createState() => _AllergyStepState();
}

class _AllergyStepState extends State<_AllergyStep> {
  bool? hasAllergies;
  String allergyDetails = '';

  // Helper function to bundle the data
  void _updateModel() {
    if (hasAllergies == false) {
      widget.onSaved({'hasAllergies': false});
    } else if (hasAllergies == true) {
      widget.onSaved({
        'hasAllergies': true,
        'allergies': allergyDetails,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Any food or environmental allergies?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'This keeps your nutrition plans safe.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // 1. The Yes/No Toggle
          Row(
            children: [
              Expanded(child: _buildToggleBtn('No, none', hasAllergies == false, () {
                setState(() => hasAllergies = false);
                _updateModel();
              })),
              const SizedBox(width: 16),
              Expanded(child: _buildToggleBtn('Yes, I do', hasAllergies == true, () {
                setState(() => hasAllergies = true);
                _updateModel();
              })),
            ],
          ),

          // 2. The Text Field (Only show if they say Yes!)
          if (hasAllergies == true) ...[
            const SizedBox(height: 32),
            const Text(
              'Please list your allergies:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) {
                allergyDetails = val;
                _updateModel();
              },
              maxLines: 3, // Makes the box a bit taller for lists!
              decoration: InputDecoration(
                hintText: 'e.g., Peanuts, Shellfish, Pollen...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Helper Widget ---
  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2979FF).withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2979FF) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2979FF) : Colors.black87,
          ),
        ),
      ),
    );
  }
}
class _SummaryStep extends StatelessWidget {
  final UserProfileModel data;
  const _SummaryStep({required this.data});

  @override
  Widget build(BuildContext context) {
    // --- Basic & Fitness Data ---
    final age = data.age?.toInt() ?? 25;
    final height = data.height?.toInt() ?? 170;
    final weight = data.weight?.toInt() ?? 70;
    final gender = (data.gender ?? 'Not specified').toLowerCase();

    final goalsStr = (data.mainGoals ?? 'Health').toLowerCase();
    final level = (data.fitnessLevel ?? 'beginner').toLowerCase();

    final duration = data.duration ?? '60 minutes';
    final intensity = (data.intensity ?? 'low intensity').toLowerCase();
    final time = (data.workoutTime ?? 'morning').toLowerCase();
    final diet = (data.diet ?? 'Not specified').toLowerCase();

    // --- 🩺 NEW: Health & Medical Data Logic ---

    // 1. Format Injuries
    String injuryStr = 'None';
    if (data.injuryDetails?['hasInjury'] == true) {
      // Grab the areas and join them with a comma
      final areas = (data.injuryDetails?['areas'] as List<dynamic>?)?.join(', ') ?? 'Unknown area';
      // Add a tag so we know if it still hurts!
      final active = data.injuryDetails?['stillFeelIt'] == true ? ' (Active)' : ' (Healed)';
      injuryStr = '$areas$active';
    }

    // 2. Format Medications
    String medStr = 'None';
    if (data.medicationDetails?['takesMedication'] == true) {
      final name = data.medicationDetails?['medicationName'] ?? 'Unknown';
      final reason = data.medicationDetails?['reason'] ?? 'Unknown';
      medStr = '$name (for $reason)';
    }

    // 3. Format Allergies
    String allergyStr = 'None';
    if (data.allergyDetails?['hasAllergies'] == true) {
      allergyStr = data.allergyDetails?['allergies'] ?? 'Unknown';
    }

    // --- UI Build ---
    return SingleChildScrollView( // Added this so it scrolls nicely on smaller screens!
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF22E1A0), Color(0xFF1E88E5)]),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            "Here's your  profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Review your personalized settings',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Original Cards
          _buildSummaryCard(title: 'Body Basics', content: '$age years • $height cm • $weight kg • $gender'),
          _buildSummaryCard(title: 'Fitness', content: 'Goal: $goalsStr • Level: $level'),
          _buildSummaryCard(title: 'Preferences', content: '$duration • $intensity • $time'),
          _buildSummaryCard(title: 'Nutrition', content: diet),

          // New Health Cards! 💊
          _buildSummaryCard(title: 'Injuries', content: injuryStr),
          _buildSummaryCard(title: 'Medications', content: medStr),
          _buildSummaryCard(title: 'Allergies', content: allergyStr),

          const SizedBox(height: 20), // Extra padding at the bottom
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}

// ─────────── The Data Model ───────────
// 🌟 I added this right to the bottom so it works instantly!
// You can cut this out and put it in a separate `user_profile_model.dart` file later!

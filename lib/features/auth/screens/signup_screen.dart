import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../onboarding/screens/profile_setup.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Logic: Controllers to capture your input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Logic: Function to send data to Rola's backend
  Future<void> sendRegistration() async {
    final url = Uri.parse("http://10.0.2.2:8081/user/register");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "firstName": nameController.text.split(' ').first,
            "lastName": nameController.text.contains(' ') ? nameController.text.split(' ').last : "User",
            "email": emailController.text.trim(),
            "password": passwordController.text,
            "country": "Egypt",
            "role": "User"
          }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Failed. Check Docker.")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Top Card Placeholder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Create Your WellU Account',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Sign up to personalize your workouts,\nnutrition, and wellness guidance',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),

              const _FieldLabel(text: 'Full Name'),
              _InputField(
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                controller: nameController,
              ),

              const SizedBox(height: 20),

              const _FieldLabel(text: 'Email Address'),
              _InputField(
                hint: 'your.email@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),

              const SizedBox(height: 20),

              const _FieldLabel(text: 'Password'),
              _InputField(
                hint: 'Create a strong password',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 20),

              const _FieldLabel(text: 'Confirm Password'),
              _InputField(
                hint: 'Re-enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: confirmPasswordController,
              ),

              const SizedBox(height: 30),

              // Sign Up Button with Gradient and Logic
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF2979FF)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () => sendRegistration(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or')),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),
              _SocialButton(text: 'Continue with Google', icon: Icons.g_mobiledata_rounded),
              const SizedBox(height: 16),
              _SocialButton(text: 'Continue with Apple', icon: Icons.apple),

              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────── Helper Widgets ───────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF2979FF), width: 2),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.text, required this.icon});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black87),
        label: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
import 'package:e_come_seller_1/Pages/home_page.dart';
import 'package:e_come_seller_1/Services/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../utils/color.dart';
import '../widgets/back_btn.dart';
import '../widgets/custome_btn.dart';
import '../widgets/custome_toast.dart';
import '../widgets/email_form.dart';
import '../widgets/fancy_text.dart';
import '../widgets/fancybtn.dart';
import '../widgets/password_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  
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
    // Get the AuthController instance using Provider
    final authProvider = Provider.of<AuthController>(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: const FancyBackButton(),
        backgroundColor: Colors.transparent
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.scaffold.withOpacity(0.9),
              AppColors.scaffold,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Animation with subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/animations/sells.json', 
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Title
                  const CustomText(
                    text: 'Create Account',
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  const CustomText(
                    text: 'Enter your details to get started',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 32),
                  
                  // Name field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: EmailTextField(
                        controller: nameController, 
                        hintText: "Full Name",
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: EmailTextField(
                        controller: emailController, 
                        hintText: "Email Address",
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PasswordTextField(controller: passwordController),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password field with card effect
                  Card(
                    elevation: 2,
                    color: AppColors.scaffold.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PasswordTextField(
                        controller: confirmPasswordController,
                       
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms and conditions checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.scaffold.withOpacity(0.3),
                    ),
                    child: _buildTermsAndConditions(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Display error message if any
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // SignUp button with improved style
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: authProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : FancyButton(
                        text: 'Sign Up',
                        onPressed: () => _handleSignUp(authProvider, context),
                      ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Divider with text
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomText(
                          text: 'Or sign up with',
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),
                  
                  // Social login options with improved spacing and effects
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CircularImageButton(
                            imagePath: 'assets/images/google.png',
                            onPressed: () {
                              // Implement Google sign up
                              _handleSocialSignUp('google', context);
                            },
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Facebook
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: CircularImageButton(
                            imagePath: 'assets/images/facebook.png',
                            onPressed: () {
                              // Implement Facebook sign up
                              _handleSocialSignUp('facebook', context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Already have an account
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.scaffold.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomText(
                          text: 'Already have an account?',
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate back to login page
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const CustomText(
                            text: 'Login',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Terms and conditions checkbox
  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Theme(
          data: ThemeData(
            checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              fillColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' and ',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Handle main signup process
  Future<void> _handleSignUp(AuthController authProvider, BuildContext context) async {
    // Validate inputs
    if (!_validateInputs(context)) {
      return;
    }
    
    // Check terms agreement
    if (!_agreedToTerms) {
     CustomToast.showFailureToast(message: 'Please agree to the terms and conditions');
      return;
    }
    
    // Proceed with sColor.fromARGB(255, 133, 122, 122)g AuthController
    final success = await authProvider.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    
    if (success && mounted) {
      // Show success message
    
          CustomToast.showSuccessToast(message: 'Account created successfully!');
      
      
      // Navigation will be handled by the listener in main.dart
      // For example: Navigator.pushReplacementNamed(context, '/home');
    }
     nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    Navigator.push(context, MaterialPageRoute(builder: (_)=>HomePage()));
  }
  
  // Handle social media signup
  void _handleSocialSignUp(String provider, BuildContext context) {
    // Show a message that social login is not yet implemented
    // This would be replaced with actual social auth logic
  CustomToast.showFailureToast(message:  'Social login is not yet implemented');
    
    // Future implementation would call methods in AuthController:
    // For example: authProvider.signInWithGoogle();
  }

  // Validate all inputs
  bool _validateInputs(BuildContext context) {
    // Check for empty fields
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
    CustomToast.showSuccessToast(message:  'we will make this soon<>');
      return false;
    }
    
    // Validate email format using regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
     
        CustomToast.showFailureToast(message: 'Please enter a valid email address');
      
     

      return false;
      
    }
    
    // Check password length
    if (passwordController.text.length < 6) {
      CustomToast.showFailureToast(message: 'Password must be at least 6 characters long');
      return false;
    }
    
    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      
        CustomToast.showFailureToast(message: 'Passwords do not match');
      
      return false;
    }
    
    return true;
  }
}
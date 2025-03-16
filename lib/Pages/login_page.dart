import 'package:e_come_seller_1/Pages/singup_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Services/auth_services.dart';
import '../utils/color.dart';
import '../widgets/custome_btn.dart';
import '../widgets/custome_toast.dart';
import '../widgets/email_form.dart';
import '../widgets/fancy_text.dart';
import '../widgets/fancybtn.dart';
import '../widgets/password_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the AuthController instance using Provider
    final authProvider = Provider.of<AuthController>(context);
    
    return SafeArea(
      child: Scaffold(
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
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Title
                    const CustomText(
                      text: 'Welcome Back',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const CustomText(
                      text: 'Sign in to continue',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 32),
                    
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
                          prefixIcon: const Icon(Icons.email, color: AppColors.primary),
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
                    
                    // Forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const CustomText(
                            text: 'FORGOT PASSWORD',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
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
                    
                    // Login button with improved style
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
                          text: 'Login',
                          onPressed: () => _handleLogin(authProvider, context),
                        ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider with text
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.grey, thickness: 0.5),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: CustomText(
                            text: 'Or login with',
                            fontSize: 16,
                            color: Colors.grey,
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
                              onPressed: () => _handleSocialLogin('google', context),
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
                              onPressed: () => _handleSocialLogin('facebook', context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Don't have an account
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.scaffold.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomText(
                            text: "Don't have an Account?",
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: const CustomText(
                              text: 'SignUp',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle login process
  Future<void> _handleLogin(AuthController authProvider, BuildContext context) async {
    // Validate inputs
    if (!_validateInputs(context)) {
      return;
    }
    
    // Proceed with login using AuthController
    final success = await authProvider.loginUser(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    
    if (success && mounted) {
      // Show success message
      CustomToast.showSuccessToast(message: 'Login successful!');
      
      // Clear text fields
      emailController.clear();
      passwordController.clear();
      
      // Navigate to home page
     
       Navigator.pushNamed(context, '/HomePage');
    }
  }
  
  // Handle social media login
  void _handleSocialLogin(String provider, BuildContext context) {
    // Show a message that social login is not yet implemented
    CustomToast.showFailureToast(message: 'Social login is not yet implemented');
    
    // Future implementation would call methods in AuthController:
    // For example: authProvider.signInWithGoogle();
  }

  // Validate all inputs
  bool _validateInputs(BuildContext context) {
    // Check for empty fields
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      CustomToast.showFailureToast(message: 'Please fill in all fields');
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
    
    return true;
  }
}
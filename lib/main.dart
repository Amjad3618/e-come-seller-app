import 'package:e_come_seller_1/Pages/login_page.dart';
import 'package:e_come_seller_1/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your AuthProvider
import 'utils/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        // Add other providers as needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.scaffold,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: AppColors.scaffold),
            bodyMedium: TextStyle(color: AppColors.scaffold),
            titleLarge: TextStyle(color: AppColors.scaffold),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
          ),
        ),
        home: LoginPage(),
      ),
    );
  }
}
import 'package:e_come_seller_1/Pages/categorie_page.dart';
import 'package:e_come_seller_1/Pages/home_page.dart';
import 'package:e_come_seller_1/Services/auth_services.dart';
import 'package:e_come_seller_1/provider/admin_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Helper/ui_helper.dart';
import 'Pages/product_page.dart';
import 'Pages/promo_page.dart';
import 'utils/color.dart';
import 'view_model.dart/category_view_model.dart';
import 'view_model.dart/product_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => CategoryViewModel()),
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ), // Auth provider
        ChangeNotifierProvider(create: (context) => ProductViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: UIHelper(), // Automatically navigate based on login state
      routes: {
        "/CategoriePage": (context) => CategoryPage(),
        "/HomePage": (context) => HomePage(),
        "/ProductPage": (context) => ProductPage(),
        '/promos': (context) => PromoBannerPage(),
      },
    );
  }
}

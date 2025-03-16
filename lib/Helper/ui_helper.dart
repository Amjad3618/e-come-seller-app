import 'package:e_come_seller_1/Pages/home_page.dart';
import 'package:e_come_seller_1/Pages/login_page.dart';
import 'package:e_come_seller_1/Services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UIHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    
    // Check if user is logged in
    if (authController.isUserLoggedIn()) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}







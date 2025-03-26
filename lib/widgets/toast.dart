import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class CustomToast2 {
  static void showSuccess(String message, BuildContext context) {
    Flushbar(
      message: message,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      icon: Icon(Icons.done_outline_outlined, color: Colors.white),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void showError(String message, BuildContext context) {
    Flushbar(
      message: message,
       padding: const EdgeInsets.only( left: 15, right: 15, top: 10, bottom: 10),
      icon: Icon(Icons.error, color: Colors.white),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.BOTTOM,
    ).show(context);
  }
}

// Define a navigator key to be used for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
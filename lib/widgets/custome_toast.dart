import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  // Success toast with green background
  static void showSuccessToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Failure toast with red background
  static void showFailureToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Info toast with blue background
  static void showInfoToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Warning toast with amber/orange background
  static void showWarningToast({
    required String message,
    Duration duration = const Duration(seconds: 2),
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: Colors.amber,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
import 'package:flutter/material.dart';

class PromoBannePage extends StatefulWidget {
  const PromoBannePage({super.key});

  @override
  State<PromoBannePage> createState() => _PromoBannePageState();
}

class _PromoBannePageState extends State<PromoBannePage> {
   bool _isInitialized = false;
  bool _isPromo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments != null && arguments is Map<String, dynamic>) {

          _isPromo = arguments['promo'] ?? true;
        }
        print("promo $_isPromo");
        _isInitialized = true;
        print("is initialized $_isInitialized");
        setState(() {  
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text(_isPromo?"Promos":"Banners"),),
    );
  }
}
import 'package:flutter/material.dart';

class PromoBannerPage extends StatefulWidget {
  const PromoBannerPage({super.key});

  @override
  State<PromoBannerPage> createState() => _PromoBannerPageState();
}

class _PromoBannerPageState extends State<PromoBannerPage> {
  bool _isInitialized = false;
  bool _isPromo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        if (arguments != null && arguments is Map<String, dynamic>) {
          setState(() {
            _isPromo = arguments['promo'] ?? true;
            _isInitialized = true; // Move this inside setState
          });
        }
        print("promo $_isPromo");
        print("is initialized $_isInitialized");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isPromo ? "Promos" : "Banners")),
      body: Center(
        child: Text(_isPromo ? "Promo Page" : "Banner Page", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

import 'package:flutter/material.dart';


class FancyBackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color secondaryColor;

  // ignore: use_super_parameters
  const FancyBackButton({
    Key? key,
    this.onPressed,
    this.primaryColor = const Color(0xFF5E35B1),
    this.secondaryColor = const Color(0xFF9575CD),
  }) : super(key: key);

  @override
  State<FancyBackButton> createState() => _FancyBackButtonState();
}

class _FancyBackButtonState extends State<FancyBackButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 90,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [widget.primaryColor, widget.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.4),
                  spreadRadius: _isPressed ? 1 : 2,
                  blurRadius: _isPressed ? 4 : 8,
                  offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: (_) {
                  setState(() {
                    _isPressed = true;
                  });
                  _animationController.forward();
                },
                onTapUp: (_) {
                  setState(() {
                    _isPressed = false;
                  });
                  _animationController.reverse();
                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  } else {
                  Navigator.pop(context);
                  }
                },
                onTapCancel: () {
                  setState(() {
                    _isPressed = false;
                  });
                  _animationController.reverse();
                },
                borderRadius: BorderRadius.circular(22),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
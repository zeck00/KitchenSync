// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart'; // For AnimationController, Tween, etc.
import 'package:kitchensync/styles/AppColors.dart'; // Replace with the correct path to your AppColors
import 'package:kitchensync/styles/AppFonts.dart'; // Replace with the correct path to your AppFonts
import 'package:kitchensync/styles/size_config.dart'; // Assuming you have a SizeConfig setup for responsive sizing

// If you have a separate package or file for the SizeConfig, make sure to import it here as well.

class RippleButton extends StatefulWidget {
  const RippleButton({
    super.key,
    required this.onTap, // Require the callback in the constructor
  });
  final VoidCallback onTap; // Add a callback property

  @override
  _RippleButtonState createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double _rippleRadius = 0;
  double _rippleStartX = 0;
  double _rippleStartY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Other initialization code
  }

  void _startRipple(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPos = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _rippleRadius = 0;
      _rippleStartX = localPos.dx;
      _rippleStartY = localPos.dy;
    });

    double maxRadius = renderBox.size.longestSide * 1.05;
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Define the animation before you call addListener on it
    Animation<double> animation =
        Tween(begin: 0.0, end: maxRadius).animate(controller);

    // Now you can add the listener to the animation
    animation.addListener(() {
      setState(() {
        _rippleRadius = animation.value;
      });
    });

    controller.forward().then((_) {
      controller.dispose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(propWidth(17))),
      color: AppColors.primary, // button's background color
      child: InkWell(
        onTap: widget.onTap, // button's tap handler
        onTapDown: _startRipple, // Trigger ripple effect on tap
        child: Container(
          width: propWidth(90),
          height: propHeight(50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(propWidth(17)),
          ),
          child: Center(
            child: CustomPaint(
              painter: RippleEffectPainter(
                startX: _rippleStartX,
                startY: _rippleStartY,
                rippleRadius: _rippleRadius,
                color: Colors.black.withAlpha(50),
              ),
              child: Text(
                'Login',
                style: AppFonts.login,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RippleEffectPainter extends CustomPainter {
  final double startX;
  final double startY;
  final double rippleRadius;
  final Color color;

  RippleEffectPainter({
    required this.startX,
    required this.startY,
    required this.rippleRadius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(startX, startY), rippleRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

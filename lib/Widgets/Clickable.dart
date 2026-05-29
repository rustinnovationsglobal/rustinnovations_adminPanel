import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double borderRadius;
  final MouseCursor cursor; // Add this

  const Clickable({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius = 8,
    this.cursor = SystemMouseCursors.click, // Default to hand cursor
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor, // Apply the cursor here
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}
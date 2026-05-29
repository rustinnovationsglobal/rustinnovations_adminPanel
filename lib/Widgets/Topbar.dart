import 'package:flutter/material.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';

class Topbar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final dynamic title;

  const Topbar({
    super.key,
    required this.onProfileTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F111A), // Dark topbar background
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              headline(
                text: "$title",
                fontsize: 20,
                textAlign: TextAlign.start,
                color: MyColors.PRIMARY_COLOR,
              ),
            ],
          ),
          // Profile Icon wrapped in Clickable
          Clickable(
            onTap: onProfileTap,
            borderRadius: 100, // Circular click area
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2F3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

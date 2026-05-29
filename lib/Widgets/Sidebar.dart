import 'package:flutter/material.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:svg_flutter/svg_flutter.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuItemTap;
  final bool isMobile;
  final bool isTablet;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuItemTap,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Employees",
        "icon": Icons.assignment_ind_outlined,
        "activeIcon": Icons.assignment_ind
      },
      {
        "title": "Articles",
        "icon": Icons.history_edu_outlined,
        "activeIcon": Icons.history_edu
      },
    ];

    return Container(
      width: isMobile ? 70 : (isTablet ? 220 : 260),
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F111A), // Dark navy-black matching the screenshot
        border: Border(right: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Column(
        children: [
          // Logo / Brand
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: isMobile ? Alignment.center : Alignment.centerLeft,
            child: isMobile
                ? Icon(Icons.grid_view_rounded,
                    size: 32, color: MyColors.PRIMARY_COLOR)
                : Row(
                    children: [
                      SvgPicture.asset('lib/assets/images/logo.svg', width: 50, height: 50, color: Colors.white,),
                      Expanded(
                        child: headline(
                          text: "RUSTINNOVATIONS",
                          fontsize: 16,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 10),
          // Menu Items
          ...List.generate(menuItems.length, (index) {
            final isSelected = selectedIndex == index;
            return _buildMenuItem(
              icon: isSelected
                  ? menuItems[index]["activeIcon"]
                  : menuItems[index]["icon"],
              title: menuItems[index]["title"],
              isSelected: isSelected,
              isMobile: isMobile,
              onTap: () => onMenuItemTap(index),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return Clickable(
      onTap: onTap,
      borderRadius: 0,
      cursor: SystemMouseCursors.click, // Add this line
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C1F2E) : Colors.transparent,
          border: isSelected
              ? Border(
              left: BorderSide(color: MyColors.PRIMARY_COLOR, width: 4))
              : null,
        ),
        child: isMobile
            ? Center(
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white60,
            size: 24,
          ),
        )
            : Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 22,
            ),
            const SizedBox(width: 16),
            paragraph(
              text: title,
              fontsize: 15,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}

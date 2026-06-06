import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Topbar extends StatelessWidget {
  final dynamic title;

  const Topbar({
    super.key,
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
          _showUserState(context),        ],
      ),
    );
  }


  Widget _showUserState(BuildContext context) {

    final user =
        Supabase.instance.client.auth.currentUser;

    return PopupMenuButton<String>(

      color: const Color(0xFF2C2F3A),

      offset: const Offset(0, 50),

      tooltip: 'Account',

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

      onSelected: (value) async {

        if (value == 'logout') {

          await Supabase.instance.client
              .auth
              .signOut();

          if (context.mounted) {
            context.go('/login');
          }
        }
      },

      itemBuilder: (context) => [

        PopupMenuItem<String>(

          enabled: false,

          child: Row(
            children: [

              const Icon(
                Icons.email,
                color: Colors.white,
                size: 18,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: paragraph(
                  text: "${user!.email}", fontsize: 12
                ),
              ),
            ],
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem<String>(

          value: 'logout',

          child: Row(
            children: [

              Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),

              SizedBox(width: 10),

              Text(
                'Sign Out',

                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
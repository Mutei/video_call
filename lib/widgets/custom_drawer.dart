import 'package:flutter/material.dart';

import '../constant/colors.dart';

import '../main.dart';

import '../resources/auth_methods.dart';

import 'drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerItem(
              text: "Logout",
              icon: const Icon(Icons.logout, color: kPrimaryColor),
              onTap: () async {
                await AuthMethods().signOut(context);
              },
              hint: '',
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_call/constant/colors.dart';
import 'package:video_call/constant/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: kPrimaryColor),
      ),
      centerTitle: centerTitle,
      iconTheme: kIconTheme,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:video_call/widgets/custom_app_bar.dart';

import '../widgets/custom_drawer.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: "Main Screen",
      ),
      drawer: CustomDrawer(),
    );
  }
}

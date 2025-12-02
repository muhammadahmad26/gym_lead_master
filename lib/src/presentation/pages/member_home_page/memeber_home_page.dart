import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/common/home_body.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';

class MemeberHomePage extends StatefulWidget {
  const MemeberHomePage({super.key});

  @override
  State<MemeberHomePage> createState() => _MemeberHomePageState();
}

class _MemeberHomePageState extends State<MemeberHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeBody(isAdmin: false),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemSelected: (p0) {},
        selectedIndex: DateTime.april,
      ),
    );
  }
}

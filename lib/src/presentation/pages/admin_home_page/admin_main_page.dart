import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_home_page/Admin_body.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';

class adminHomePage extends StatefulWidget {
  const adminHomePage({super.key});

  @override
  State<adminHomePage> createState() => _adminHomePageState();
}

class _adminHomePageState extends State<adminHomePage> {
  int seletedIndex = 0;

  void handelIndex(int index) {
    setState(() {
      seletedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdminBody(),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemSelected: (index) {
          setState(() {
            seletedIndex = index;
          });
        },
        selectedIndex: seletedIndex,
      ),
    );
  }
}

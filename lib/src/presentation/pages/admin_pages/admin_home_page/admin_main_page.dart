import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/admin_message_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/payment_page/admin_pyment_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/admin_profile_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/home_body.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';

class adminHomePage extends StatefulWidget {
  const adminHomePage({super.key});

  @override
  State<adminHomePage> createState() => _adminHomePageState();
}

class _adminHomePageState extends State<adminHomePage> {
  int seletedIndex = 0;
  final List<Widget> pages = [
    HomeBody(isAdmin: true),
    AdminPymentPage(),
    AdminMessageScreen(),
    AdminProfilePage(),
  ];

  void handelIndex(int index) {
    setState(() {
      seletedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[seletedIndex],
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

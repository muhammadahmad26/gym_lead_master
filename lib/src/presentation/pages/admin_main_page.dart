import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/Admin_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';

class adminHomePage extends StatefulWidget {

  const adminHomePage({super.key});

  @override
  State<adminHomePage> createState() => _adminHomePageState();
}

class _adminHomePageState extends State<adminHomePage> {
  int seletedIndex = 0;

  void handelIndex(int index){
    setState(() {
      seletedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdminScreen(),
      bottomNavigationBar: CustomBottomNavigationBar(onItemSelected: handelIndex,selectedIndex: seletedIndex,),
    );
  }
}

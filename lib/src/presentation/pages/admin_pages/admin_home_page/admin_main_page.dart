import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/gym_member_page.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/payment_page/admin_pyment_page.dart';
import 'package:gym_lead_master/src/presentation/pages/common/home_body.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/message_page/admin_message_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/profile_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class adminHomePage extends StatefulWidget {
  const adminHomePage({super.key});

  @override
  State<adminHomePage> createState() => _adminHomePageState();
}

class _adminHomePageState extends State<adminHomePage> {
  int seletedIndex = 0;
  String _gymId = "loading";

  @override
  void initState() {
    super.initState();
    _loadGymId();
  }

  Future<void> _loadGymId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedGymId = prefs.getString('gymId');

    if (savedGymId != null) {
      setState(() => _gymId = savedGymId);
    } else {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        var doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          String dbGymId = doc.data()!['gymId'];
          await prefs.setString('gymId', dbGymId);
          setState(() => _gymId = dbGymId);
        }
      }
    }
  }

  void handelIndex(int index) {
    setState(() {
      seletedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Scaffold(
        body:
            [
              HomeBody(isAdmin: true, gymId: _gymId),
              const AdminPymentPage(),
              const AdminMessageScreen(),
              const ProfileScreen(isAdmin: true),
            ][seletedIndex],
        bottomNavigationBar: CustomBottomNavigationBar(
          isAdmin: true,
          onItemSelected: (index) {
            setState(() {
              seletedIndex = index;
            });
          },
          selectedIndex: seletedIndex,
          // UPDATED: Navigate to Gym Members Page
          onCenterButtonTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GymMembersPage()),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart';
import 'package:gym_lead_master/src/presentation/pages/common/home_body.dart';
import 'package:gym_lead_master/src/presentation/pages/common/custom_bottom_navigation_bar.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/profile_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_chat_page/member_massage_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/member_pages/member_payment_page/member_payment_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MemeberHomePage extends StatefulWidget {
  const MemeberHomePage({super.key});

  @override
  State<MemeberHomePage> createState() => _MemeberHomePageState();
}

class _MemeberHomePageState extends State<MemeberHomePage> {
  int _currentIndex = 0;
  String _gymId = "loading";
  bool _isCheckedInToday = false;
  bool _isCheckingIn = false;
  String _membershipStatus = 'not_paid';

  final DatabaseService _dbService = DatabaseService();

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
      _checkMemberStatus();
    } else {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          var doc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
          if (doc.exists) {
            String dbGymId = doc.data()!['gymId'];
            await prefs.setString('gymId', dbGymId);
            setState(() => _gymId = dbGymId);
            _checkMemberStatus();
          }
        } catch (e) {
          debugPrint("Error fetching Gym ID: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Couldn't load your gym info: $e")),
            );
          }
        }
      }
    }
  }


  Future<void> _checkMemberStatus() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot memberDoc =
          await FirebaseFirestore.instance
              .collection('gyms')
              .doc(_gymId)
              .collection('members')
              .doc(uid)
              .get();

      if (memberDoc.exists) {
        var data = memberDoc.data() as Map<String, dynamic>;

        // CHECK 1: Already checked in today?
        Timestamp? lastCheckIn = data['checkInTime'];
        bool isCheckedIn = false;

        if (lastCheckIn != null) {
          DateTime lastCheckInDate = lastCheckIn.toDate();
          String lastCheckInDay = DateFormat(
            'yyyy-MM-dd',
          ).format(lastCheckInDate);
          String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
          if (lastCheckInDay == todayKey) {
            isCheckedIn = true;
          }
        }

        // CHECK 2: Membership status
        String status = data['membershipStatus'] ?? 'not_paid';

        if (mounted) {
          setState(() {
            _isCheckedInToday = isCheckedIn;
            _membershipStatus = status;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking member status: $e");
    }
  }

 
  void _showAlreadyCheckedInDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: AppResponsive.iconSize(context, 28),
                ),
                SizedBox(width: AppResponsive.padding(context, 10)),
                Flexible(
                  child: Text(
                    "Already Checked In",
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available,
                  size: AppResponsive.iconSize(context, 60),
                  color: Colors.green[200],
                ),
                SizedBox(height: AppResponsive.padding(context, 12)),
                Text(
                  "Today's attendance has already been recorded.",
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppResponsive.padding(context, 8)),
                Text(
                  "You can check in again tomorrow.",
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  
  void _showPaymentRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.block,
                  color: Colors.red[700],
                  size: AppResponsive.iconSize(context, 28),
                ),
                SizedBox(width: AppResponsive.padding(context, 10)),
                Flexible(
                  child: Text(
                    "Access Denied",
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: AppResponsive.iconSize(context, 60),
                  color: Colors.red[200],
                ),
                SizedBox(height: AppResponsive.padding(context, 12)),
                Text(
                  "Your payment is not paid.",
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.DarkBlueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppResponsive.padding(context, 8)),
                Text(
                  "Please pay your membership fee first to access the gym and check in.",
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                  icon: Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: AppResponsive.iconSize(context, 20),
                  ),
                  label: Text(
                    "Go to Payments",
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppResponsive.padding(context, 12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppResponsive.padding(context, 8)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: AppResponsive.padding(context, 12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: AppResponsive.textStyle(context, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  
  void _showCheckInDialog() {
    if (_gymId == "loading") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Loading Gym Data...")));
      return;
    }

    if (_membershipStatus != 'active') {
      _showPaymentRequiredDialog();
      return;
    }

    if (_isCheckedInToday) {
      _showAlreadyCheckedInDialog();
      return;
    }

    Map<String, bool> selectedExercises = {
      "Chest": false,
      "Leg": false,
      "Triceps": false,
      "Biceps": false,
      "Cardio": false,
      "Weight loss": false,
    };

    bool isDialogSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isDialogSaving,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: AppColors.blueColor,
                        size: AppResponsive.iconSize(context, 24),
                      ),
                      SizedBox(width: AppResponsive.padding(context, 10)),
                      Flexible(
                        child: Text(
                          "Today's Check-In",
                          style: AppResponsive.textStyle(
                            context,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, EEEE').format(DateTime.now()),
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: AppResponsive.padding(context, 12)),
                      Text(
                        "Select your exercises for today:",
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppResponsive.padding(context, 8)),
                      ...selectedExercises.keys.map((exercise) {
                        return CheckboxListTile(
                          title: Text(
                            exercise,
                            style: AppResponsive.textStyle(
                              context,
                              fontSize: 14,
                            ),
                          ),
                          value: selectedExercises[exercise],
                          activeColor: AppColors.blueColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          onChanged:
                              isDialogSaving
                                  ? null
                                  : (val) {
                                    setDialogState(
                                      () => selectedExercises[exercise] = val!,
                                    );
                                  },
                        );
                      }),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isDialogSaving ? null : () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDialogSaving ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          isDialogSaving
                              ? null
                              : () async {
                                bool hasSelection = selectedExercises.values
                                    .any((val) => val == true);
                                if (!hasSelection) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select at least one exercise",
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() => isDialogSaving = true);
                                setState(() => _isCheckingIn = true);

                                try {
                                  String result = await _dbService
                                      .performCheckIn(
                                        gymId: _gymId,
                                        selectedExercises: selectedExercises,
                                      );

                                  if (result == "already_checked_in") {
                                    if (mounted) {
                                      setState(() {
                                        _isCheckedInToday = true;
                                        _isCheckingIn = false;
                                      });
                                    }
                                    Navigator.pop(context);
                                    _showAlreadyCheckedInDialog();
                                  } else if (result == "success") {
                                    if (mounted) {
                                      setState(() {
                                        _isCheckedInToday = true;
                                        _isCheckingIn = false;
                                      });
                                    }
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Checked In Successfully! ✓",
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setDialogState(() => isDialogSaving = false);
                                  if (mounted) {
                                    setState(() => _isCheckingIn = false);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Check-in failed: $e"),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                      icon:
                          isDialogSaving
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check_circle, size: 20),
                      label: Text(
                        isDialogSaving ? "Saving..." : "Save",
                        style: AppResponsive.textStyle(
                          context,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.padding(context, 20),
                          vertical: AppResponsive.padding(context, 10),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body:
          [
            HomeBody(isAdmin: false, gymId: _gymId),
            const MemberPaymentScreen(),
            const MemberMessageScreen(),
            const ProfileScreen(isAdmin: false),
          ][_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        isAdmin: true,
        onCenterButtonTap: _isCheckingIn ? null : _showCheckInDialog,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedIndex: _currentIndex,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
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
          print("Error fetching Gym ID: $e");
        }
      }
    }
  }

  // ==========================================
  // UPDATED: Check both check-in time AND membership status
  // ==========================================
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
      print("Error checking member status: $e");
    }
  }

  // ==========================================
  // REWRITTEN: Check-In with 3 guards
  // ==========================================
  void _showCheckInDialog() {
    if (_gymId == "loading") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Loading Gym Data...")));
      return;
    }

    // GUARD 1: Payment not active
    if (_membershipStatus != 'active') {
      _showPaymentRequiredDialog();
      return;
    }

    // GUARD 2: Already checked in today
    if (_isCheckedInToday) {
      _showAlreadyCheckedInDialog();
      return;
    }

    // GUARD 3: Normal exercise selection
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
                      const Icon(
                        Icons.fitness_center,
                        color: AppColors.blueColor,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Today's Check-In",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, EEEE').format(DateTime.now()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Select your exercises for today:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedExercises.keys.map((exercise) {
                        return CheckboxListTile(
                          title: Text(exercise),
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
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  // ==========================================
  // Payment Required Dialog
  // ==========================================
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
                Icon(Icons.block, color: Colors.red[700], size: 28),
                const SizedBox(width: 10),
                const Text("Access Denied"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment_outlined, size: 60, color: Colors.red[200]),
                const SizedBox(height: 12),
                const Text(
                  "Your payment is not paid.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.DarkBlueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Please pay your membership fee first to access the gym and check in.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              // Go to Payments Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to Payments tab
                    setState(() => _currentIndex = 1);
                  },
                  icon: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    "Go to Payments",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
    );
  }

  // ==========================================
  // Already Checked In Dialog
  // ==========================================
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
                Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                const SizedBox(width: 10),
                const Text("Already Checked In"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available, size: 60, color: Colors.green[200]),
                const SizedBox(height: 12),
                const Text(
                  "Today's attendance has already been recorded.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "You can check in again tomorrow.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
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

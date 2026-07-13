import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/notification_bell.dart';
import 'package:gym_lead_master/src/data/gym_members_data.dart';
import 'package:gym_lead_master/src/presentation/pages/common/detail_live_member/exercise_card_group.dart';
import 'package:gym_lead_master/src/presentation/pages/common/detail_live_member/live_total_members_number.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key, required this.isAdmin, required this.gymId});

  final bool isAdmin;
  final String gymId;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    if (widget.gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pro Fitness Gym",
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.mediumBlue,
        elevation: 0,
        actions: [
          if (!widget.isAdmin)
            NotificationBell(isAdmin: false, gymId: widget.gymId),
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(
                Icons.notifications_active_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.adminNotificationsPage);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackGroundPage(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _dbService.getGymStatsStream(widget.gymId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildContent(0, 0, 0, 0, 0, 0, 0);
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;

            return _buildContent(
              data['totalLiveMembers'] ?? 0,
              data['chest'] ?? 0,
              data['leg'] ?? 0,
              data['triceps'] ?? 0,
              data['biceps'] ?? 0,
              data['cardio'] ?? 0,
              data['weightLoss'] ?? 0,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    int total,
    int chest,
    int leg,
    int tri,
    int bi,
    int cardio,
    int weight,
  ) {
    final GymMembersData gymMembers = GymMembersData(
      totalMembers: total.toString(),
      membersDoingBicepsExercise: bi.toString(),
      membersDoingCardioExercise: cardio.toString(),
      membersDoingChestExercise: chest.toString(),
      membersDoingLegExercise: leg.toString(),
      membersDoingTricepsExercise: tri.toString(),
      membersDoingWeightLossExercise: weight.toString(),
    );

    final listImageAddress = [
      "assets/images/chest_home.png",
      "assets/images/leg_home.png",
      "assets/images/triceps_home.png",
      "assets/images/chest_home.png",
      "assets/images/cardio_home.png",
      "assets/images/weightloss_home.png",
    ];
    final listExerciseNames = [
      "Chest",
      "Leg",
      "Triceps",
      "Biceps",
      "Cardio",
      "Weight loss",
    ];

    return Column(
      children: [
        const Spacer(),

        // Logo
        FractionallySizedBox(
          widthFactor: 0.2,
          child: Image.asset(AppImages.appLogoIcon, fit: BoxFit.contain),
        ),
        const SizedBox(height: 10),

        const Spacer(flex: 1),
        LiveTotalMembersNumber(gymMembers: gymMembers, fontSize: 30),
        const SizedBox(height: 5),
        const Text(
          "Live Gym Members",
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        ExerciseCardsGroup(
          fontSize: 20,
          listImageAddress: listImageAddress,
          listExerciseNames: listExerciseNames,
          gymMembers: gymMembers,
        ),
        const Spacer(),

        // Same button as before — navigates to Active Member List
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.checkInPage);
            },
            text: "Check In",
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

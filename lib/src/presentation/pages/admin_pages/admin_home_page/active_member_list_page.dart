import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/data/memeber_dummy_data/dummy_member.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/member_list_veiw.dart';

class ActiveMemberListPage extends StatelessWidget {
  const ActiveMemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackGroundPage(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.2,
                    child: Image.asset(
                      AppImages.appLogoIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: const Text(
                      "Pro Fitness Gym",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Active Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: MemberListView(members: MembersDummyData.members),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

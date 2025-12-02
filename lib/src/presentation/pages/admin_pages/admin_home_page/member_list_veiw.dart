import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/data/model/member_model.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/member_list_tile.dart';

class MemberListView extends StatelessWidget {
  const MemberListView({super.key, required this.members});

  final List<MemberModel> members;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: MemberListTile(member: members[index]),
        );
      },
    );
  }
}
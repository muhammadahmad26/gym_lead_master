import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/admin_home_page/data/model/member_model.dart';

class MemberListTile extends StatelessWidget {
  const MemberListTile({super.key, required this.member});

  final MemberModel member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        child: Image.asset(member.imagePath, fit: BoxFit.contain),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(member.workout),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 17.0,
            color: Color.fromARGB(255, 29, 29, 29),
          ),
          const SizedBox(width: 4.0),
          Text(
            member.time,
            style: const TextStyle(color: Color.fromARGB(255, 68, 67, 67)),
          ),
        ],
      ),
    );
  }
}

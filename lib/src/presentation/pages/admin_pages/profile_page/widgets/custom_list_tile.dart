import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_padding.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/presentation/pages/admin_pages/profile_page/data/model/list_items_model.dart';

class CustomListTile extends StatelessWidget {
  final ListItem item;
  final VoidCallback onTap;

  const CustomListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppPaddings.medium, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(item.icon, color: AppColors.primary),
        title: Text(item.title, style: AppTextStyles.bodyLarge),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
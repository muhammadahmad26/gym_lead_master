import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationDetailScreen extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.LightGrey,
      appBar: AppBar(
        title: Text(
          notification.type.label,
          style: AppResponsive.textStyle(context, fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppResponsive.padding(context, 16)),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(AppResponsive.padding(context, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Icon + Title + Time)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppResponsive.padding(context, 10)),
                      decoration: BoxDecoration(
                        color: notification.type.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(notification.type.icon, color: notification.type.color, size: AppResponsive.iconSize(context, 30)),
                    ),
                    SizedBox(width: AppResponsive.padding(context, 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: AppResponsive.textStyle(context, fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.DarkBlueGrey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            notification.createdAt != null ? timeago.format(notification.createdAt!) : "Just now",
                            style: AppResponsive.textStyle(context, fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Divider(height: AppResponsive.padding(context, 30)),
                
                // Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppResponsive.padding(context, 12), vertical: AppResponsive.padding(context, 6)),
                  decoration: BoxDecoration(
                    color: notification.type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notification.type.label,
                    style: AppResponsive.textStyle(context, fontSize: 12, fontWeight: FontWeight.w600, color: notification.type.color),
                  ),
                ),
                
                SizedBox(height: AppResponsive.padding(context, 20)),
                
                // Full Message Body
                Text(
                  "Message",
                  style: AppResponsive.textStyle(context, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                SizedBox(height: AppResponsive.padding(context, 8)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppResponsive.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    notification.message,
                    style: AppResponsive.textStyle(context, fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
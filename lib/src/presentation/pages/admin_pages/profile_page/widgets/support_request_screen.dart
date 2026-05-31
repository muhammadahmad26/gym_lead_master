import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class SupportRequestsScreen extends StatelessWidget {
  const SupportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Support Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('support_requests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "No support requests yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var data = requests[index].data() as Map<String, dynamic>;
              String id = requests[index].id;
              String status = data['status'] ?? 'pending';
              String subject = data['subject'] ?? 'No Subject';
              String message = data['message'] ?? '';
              String name = data['name'] ?? 'Unknown';
              String email = data['email'] ?? '';
              DateTime? createdAt =
                  data['createdAt'] != null
                      ? (data['createdAt'] as Timestamp).toDate()
                      : null;

              Color statusColor =
                  status == 'pending'
                      ? Colors.orange
                      : status == 'resolved'
                      ? Colors.green
                      : Colors.grey;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeago.format(createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 'pending')
                            TextButton.icon(
                              onPressed: () => _markResolved(context, id),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text("Resolve"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                            ),
                          TextButton.icon(
                            onPressed: () => _deleteRequest(context, id),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text("Delete"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markResolved(BuildContext context, String id) async {
    await FirebaseFirestore.instance
        .collection('support_requests')
        .doc(id)
        .update({'status': 'resolved'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Marked as resolved ✓"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteRequest(BuildContext context, String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Request?"),
            content: const Text("This cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('support_requests')
          .doc(id)
          .delete();
    }
  }
}

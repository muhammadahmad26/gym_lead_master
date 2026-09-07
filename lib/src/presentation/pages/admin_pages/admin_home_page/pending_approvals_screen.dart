import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:intl/intl.dart';

class PendingApprovalsScreen extends StatefulWidget {
  final String gymId;
  const PendingApprovalsScreen({super.key, required this.gymId});

  @override
  State<PendingApprovalsScreen> createState() =>
      _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? _processingId;

  Future<void> _approve(String memberId, String name) async {
    setState(() => _processingId = memberId);
    try {
      await _dbService.approveMemberSignup(widget.gymId, memberId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name approved — they can now log in."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't approve: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _reject(String memberId, String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Reject Signup?"),
            content: Text(
              "$name's signup will be rejected and all their data permanently deleted. This cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Reject & Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _processingId = memberId);
    try {
      await _dbService.deleteMemberCompletely(widget.gymId, memberId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name's signup was rejected."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't reject: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Widget _buildAvatar(String? base64Image) {
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          backgroundImage: MemoryImage(base64Decode(base64Image)),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pending Approvals",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getPendingApprovalMembers(widget.gymId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_reg_outlined,
                    size: 70,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No pending signups",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          var members = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: members.length,
            itemBuilder: (context, index) {
              var data = members[index].data() as Map<String, dynamic>;
              String memberId = members[index].id;
              String name = data['name'] ?? 'Unknown';
              String email = data['email'] ?? '';
              String location = data['location'] ?? '';
              String role = data['role'] ?? 'member';
              bool isProcessing = _processingId == memberId;

              String joinDateStr = "";
              if (data['joinDate'] != null) {
                joinDateStr = DateFormat(
                  'dd MMM yyyy',
                ).format((data['joinDate'] as Timestamp).toDate());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildAvatar(data['profileImageBase64']),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (location.isNotEmpty)
                                  Text(
                                    location,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.warningOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (joinDateStr.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Signed up: $joinDateStr",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (isProcessing)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _reject(memberId, name),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Reject",
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _approve(memberId, name),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  "Approve",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
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
}

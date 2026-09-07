import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/membership_plan_model.dart';
import 'package:gym_lead_master/src/data/models/payment_model.dart';
import 'package:gym_lead_master/src/data/models/transaction_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdminPymentPage extends StatefulWidget {
  const AdminPymentPage({super.key});

  @override
  State<AdminPymentPage> createState() => _AdminPymentPageState();
}

class _AdminPymentPageState extends State<AdminPymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _dbService = DatabaseService();
  String _gymId = "loading";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadGymId();
  }

  Future<void> _loadGymId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedGymId = prefs.getString('gymId');
    if (savedGymId != null) {
      setState(() => _gymId = savedGymId);
    } else {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        var doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          String dbGymId = doc.data()!['gymId'];
          await prefs.setString('gymId', dbGymId);
          setState(() => _gymId = dbGymId);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gymId == "loading") {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.LightGrey,
      appBar: AppBar(
        title: const Text(
          "Payment Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blueColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Not Paid"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Failed"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.DarkBlueGrey,
        onPressed: () => _showSettingsBottomSheet(),
        child: const Icon(Icons.settings, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentList(null),
          _buildPaymentList('not_paid'),
          _buildPaymentList('pending'),
          _buildPaymentList('approved'),
          _buildPaymentList('failed'),
        ],
      ),
    );
  }

  // ==========================================
  // PAYMENT LIST (Fixed sorting)
  // ==========================================
  Widget _buildPaymentList(String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getAllPayments(_gymId, statusFilter: statusFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint("Admin Payment List Error: ${snapshot.error}");
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No ${statusFilter ?? ''} payments found",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        // Sort client-side by createdAt
        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var aData = a.data() as Map<String, dynamic>;
          var bData = b.data() as Map<String, dynamic>;
          Timestamp? aTime = aData['createdAt'] as Timestamp?;
          Timestamp? bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var txn = TransactionModel.fromFirestore(docs[index]);
            return _buildTransactionCard(txn);
          },
        );
      },
    );
  }

  // ==========================================
  // TRANSACTION CARD
  // ==========================================
  Widget _buildTransactionCard(TransactionModel txn) {
    Color statusColor = txn.status.color;

    String dateStr =
        txn.submittedAt != null
            ? DateFormat('dd MMM yyyy, hh:mm a').format(txn.submittedAt!)
            : "Not submitted";

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    txn.memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    txn.status.label,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              txn.memberEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(),

            // Details
            Text(
              "Plan: ${txn.planName} | Amount: \$${txn.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),

            if (txn.status != TransactionStatus.notPaid) ...[
              Text(
                "Method: ${txn.paymentMethodLabel}",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "Account: ${txn.accountTitle} - ${txn.accountNumber}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                "Date: $dateStr",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],

            if (txn.status == TransactionStatus.notPaid)
              const Text(
                "Awaiting member payment selection.",
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),

            if (txn.status == TransactionStatus.failed &&
                txn.rejectionReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Rejection: ${txn.rejectionReason}",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            //  Action Buttons for PENDING
            if (txn.status == TransactionStatus.pending) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showScreenshotDialog(txn.screenshotUrl),
                      icon: const Icon(Icons.image, size: 18),
                      label: const Text("View Proof"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.DarkBlueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approvePayment(txn.id, txn.memberId),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectPayment(txn.id, txn.memberId),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // APPROVE / REJECT LOGIC
  // ==========================================
  Future<void> _approvePayment(String paymentId, String memberId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Approve Payment?"),
            content: const Text(
              "This will activate the member's membership. Are you sure?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  "Approve",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await _dbService.approvePayment(_gymId, paymentId, memberId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Approved!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectPayment(String paymentId, String memberId) async {
    TextEditingController reasonCtrl = TextEditingController();

    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reject Payment?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "This will mark the payment as failed. The member can try again.",
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: "Rejection Reason (optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  "Reject",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await _dbService.rejectPayment(
        _gymId,
        paymentId,
        memberId,
        reason: reasonCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Rejected ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==========================================
  //  SCREENSHOT DIALOG
  // ==========================================

  void _showScreenshotDialog(String imageUrl) {
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No screenshot uploaded"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if it's a URL (Cloudinary) or old Base64
    bool isUrl = imageUrl.startsWith('http');

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.DarkBlueGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Payment Proof",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.65,
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[100],
                        // Ternary Operator: Show Network Image for URL, Memory Image for Base64
                        child:
                            isUrl
                                ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Failed to load image",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                : Image.memory(
                                  base64Decode(
                                    imageUrl,
                                  ), // Fallback for old base64
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        "Invalid image data",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.zoom_out_map, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "Pinch to zoom in/out",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ==========================================
  // SETTINGS BOTTOM SHEET
  // ==========================================
  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DefaultTabController(
            length: 2,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: "Payment Methods"),
                      Tab(text: "Membership Plans"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPaymentMethodsTab(),
                        _buildMembershipPlansTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPaymentMethodsTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _dbService.getPaymentMethodsList(_gymId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No payment methods added yet"),
                );
              }
              var docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var method = PaymentMethodModel.fromFirestore(docs[index]);
                  return ListTile(
                    leading: Icon(method.icon, color: AppColors.blueColor),
                    title: Text(method.typeLabel),
                    subtitle: Text(
                      "${method.accountTitle} - ${method.accountNumber}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Delete?"),
                                content: Text(
                                  "Delete ${method.typeLabel} method?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          _dbService.deletePaymentMethod(_gymId, method.id);
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddPaymentMethodDialog(),
          icon: const Icon(Icons.add,color: AppColors.whiteColor),
          label: const Text(
            "Add Method",
            style: TextStyle(color: AppColors.whiteColor),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueColor),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMembershipPlansTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _dbService.getMembershipPlans(_gymId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No plans added yet"));
              }
              var docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var plan = MembershipPlanModel.fromFirestore(docs[index]);
                  return ListTile(
                    leading: const Icon(
                      Icons.card_membership,
                      color: AppColors.BrightBlue,
                    ),
                    title: Text(plan.planName),
                    subtitle: Text(plan.displayPrice),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Delete?"),
                                content: Text("Delete ${plan.planName}?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          _dbService.deleteMembershipPlan(_gymId, plan.id);
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddPlanDialog(),
          icon: const Icon(Icons.add,color: AppColors.whiteColor,),
          label: const Text("Add Plan",style: TextStyle(color: AppColors.whiteColor),),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueColor),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showAddPaymentMethodDialog() {
    String type = 'jazzcash';
    TextEditingController titleCtrl = TextEditingController();
    TextEditingController numCtrl = TextEditingController();
    TextEditingController bankCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Payment Method"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: type,
                        items:
                            ['jazzcash', 'easypaisa', 'bank']
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.toUpperCase()),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => type = val!),
                        decoration: const InputDecoration(labelText: "Type"),
                      ),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: "Account Title",
                        ),
                      ),
                      TextField(
                        controller: numCtrl,
                        decoration: const InputDecoration(
                          labelText: "Account Number / Mobile",
                        ),
                      ),
                      if (type == 'bank')
                        TextField(
                          controller: bankCtrl,
                          decoration: const InputDecoration(
                            labelText: "Bank Name",
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty ||
                            numCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _dbService.addPaymentMethod(_gymId, {
                          'type': type,
                          'accountTitle': titleCtrl.text.trim(),
                          'accountNumber': numCtrl.text.trim(),
                          'bankName': bankCtrl.text.trim(),
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showAddPlanDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController priceCtrl = TextEditingController();
    String duration = 'Monthly';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text("Add Membership Plan"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Plan Name",
                        ),
                      ),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Price"),
                      ),
                      DropdownButtonFormField<String>(
                        value: duration,
                        items:
                            ['Monthly', 'Quarterly', 'Yearly']
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => duration = val!),
                        decoration: const InputDecoration(
                          labelText: "Duration",
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty ||
                            priceCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _dbService.addMembershipPlan(_gymId, {
                          'planName': nameCtrl.text.trim(),
                          'price': double.tryParse(priceCtrl.text) ?? 0.0,
                          'duration': duration,
                          'features': [],
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
          ),
    );
  }
}

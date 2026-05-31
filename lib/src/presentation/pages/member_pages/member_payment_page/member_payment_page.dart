import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gym_lead_master/services/database_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/membership_plan_model.dart';
import 'package:gym_lead_master/src/data/models/payment_model.dart';
import 'package:gym_lead_master/src/data/models/transaction_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MemberPaymentScreen extends StatefulWidget {
  const MemberPaymentScreen({super.key});

  @override
  State<MemberPaymentScreen> createState() => _MemberPaymentScreenState();
}

class _MemberPaymentScreenState extends State<MemberPaymentScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  String _gymId = "loading";
  String _memberId = "";

  // Image
  Uint8List? _imageBytes;
  bool _isUploading = false;
  String _loadingMessage = "";
  double _uploadProgress = 0.0; // NEW: Track upload progress

  // Selections
  String? _selectedPlanId;
  String? _selectedPlanName;
  double _selectedPlanPrice = 0.0;
  String _selectedPlanDuration = "";

  String? _selectedMethodId;
  String? _selectedMethodType;
  String? _selectedMethodLabel;
  String? _selectedAccountTitle;
  String? _selectedAccountNumber;

  late TabController _historyTabController;
  bool _hasPendingPayment = false;

  @override
  void initState() {
    super.initState();
    _historyTabController = TabController(length: 5, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _memberId = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('gymId');
    if (savedId != null) {
      setState(() => _gymId = savedId);
    } else {
      var doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_memberId)
              .get();
      if (doc.exists) {
        String dbGymId = doc.data()!['gymId'];
        await prefs.setString('gymId', dbGymId);
        setState(() => _gymId = dbGymId);
      }
    }
  }

  @override
  void dispose() {
    _historyTabController.dispose();
    super.dispose();
  }

  // ==========================================
  // FIXED: Image Picker with STRONG compression
  // ==========================================
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Max width 800px
        maxHeight: 800, // Max height 800px
        imageQuality: 40, // 40% quality (was 50)
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        print(
          "Image picked: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(1)} KB)",
        );

        // Validate size: Max 500KB
        if (bytes.length > 500000) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Image too large! Max 500KB allowed. Please pick a smaller image.",
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      print("Image pick error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==========================================
  // COMPLETELY FIXED: Submit Payment with Timeout + Progress
  // ==========================================
  // ==========================================
  // FIXED: Submit Payment using BASE64 (No Storage Needed)
  // ==========================================
  Future<void> _submitPayment() async {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a plan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload payment screenshot"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _loadingMessage = "Processing payment...";
      _uploadProgress = 0.0;
    });

    try {
      // STEP 1: Find NOT_PAID transaction
      print("STEP 1: Finding NOT_PAID transaction...");
      DocumentReference? notPaidRef = await _dbService
          .findOrCreateNotPaidTransaction(_gymId, _memberId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Finding payment record timed out');
            },
          );

      if (notPaidRef == null) {
        setState(() {
          _isUploading = false;
          _loadingMessage = "";
          _hasPendingPayment = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You already have a pending payment. Please wait for admin verification.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // STEP 2: Convert Image to Base64 (Just like Profile Image!)
      setState(() {
        _loadingMessage = "Saving payment proof...";
        _uploadProgress = 0.5;
      });

      print("STEP 2: Converting image to Base64...");
      String screenshotBase64 = base64Encode(_imageBytes!);
      print("Base64 length: ${screenshotBase64.length} chars");

      // STEP 3: Update payment in Firestore
      setState(() {
        _loadingMessage = "Finalizing...";
        _uploadProgress = 0.8;
      });

      print("STEP 3: Updating payment doc to PENDING...");

      String result = await _dbService
          .submitPayment(
            gymId: _gymId,
            paymentDocRef: notPaidRef,
            planId: _selectedPlanId!,
            planName: _selectedPlanName!,
            amount: _selectedPlanPrice,
            duration: _selectedPlanDuration,
            paymentMethodId: _selectedMethodId!,
            paymentMethodType: _selectedMethodType!,
            paymentMethodLabel: _selectedMethodLabel!,
            accountTitle: _selectedAccountTitle!,
            accountNumber: _selectedAccountNumber!,
            screenshotBase64: screenshotBase64, // Send Base64 instead of URL
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Saving payment details timed out');
            },
          );

      if (result == "success") {
        print("STEP 4: Payment submitted successfully!");
        setState(() {
          _imageBytes = null;
          _selectedPlanId = null;
          _selectedMethodId = null;
          _selectedPlanPrice = 0.0;
          _selectedPlanName = null;
          _selectedPlanDuration = "";
          _selectedMethodType = null;
          _selectedMethodLabel = null;
          _selectedAccountTitle = null;
          _selectedAccountNumber = null;
          _isUploading = false;
          _loadingMessage = "";
          _uploadProgress = 1.0;
          _hasPendingPayment = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Submitted Successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on TimeoutException catch (e) {
      print("TIMEOUT: $e");
      setState(() {
        _isUploading = false;
        _loadingMessage = "";
        _uploadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Timed out. Check internet and try again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print("GENERAL ERROR: $e");
      setState(() {
        _isUploading = false;
        _loadingMessage = "";
        _uploadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
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
          "Payments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blueColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentStatusCard(),
            const SizedBox(height: 16),
            if (_hasPendingPayment)
              _buildPendingMessage()
            else ...[
              _buildPlanSelection(),
              const SizedBox(height: 16),
              _buildPaymentMethodSelection(),
              const SizedBox(height: 16),
              _buildScreenshotUpload(),
              const SizedBox(height: 24),
              _isUploading ? _buildLoadingButton() : _buildPayNowButton(),
            ],
            const SizedBox(height: 24),
            _buildTransactionHistory(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STATUS CARD
  // ==========================================
  Widget _buildCurrentStatusCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getMemberPaymentHistory(_gymId, _memberId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          print("Status Card Error: ${snapshot.error}");
          return Card(
            color: Colors.red[50],
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            color: Colors.grey[400],
            margin: const EdgeInsets.all(12),
            child: const ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text(
                "No payment record found",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Make your first payment below",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var aData = a.data() as Map<String, dynamic>;
          var bData = b.data() as Map<String, dynamic>;
          Timestamp? aTime = aData['createdAt'] as Timestamp?;
          Timestamp? bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        var latestTxn = TransactionModel.fromFirestore(docs.first);

        if (latestTxn.status == TransactionStatus.pending &&
            !_hasPendingPayment) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasPendingPayment = true);
          });
        } else if (latestTxn.status != TransactionStatus.pending &&
            _hasPendingPayment) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasPendingPayment = false);
          });
        }

        Color cardColor = latestTxn.status.color;
        String msg = "No active membership. Please pay below.";
        IconData icon = Icons.info;
        String subtitle = "";

        if (latestTxn.status == TransactionStatus.pending) {
          msg = "Payment submitted. Awaiting admin verification.";
          icon = Icons.hourglass_empty;
          subtitle = "Plan: ${latestTxn.planName}";
        } else if (latestTxn.status == TransactionStatus.approved) {
          msg = "Membership Active!";
          icon = Icons.check_circle;
          subtitle = "Plan: ${latestTxn.planName}";
        } else if (latestTxn.status == TransactionStatus.failed) {
          msg = "Payment rejected. Please try again.";
          icon = Icons.error;
          subtitle =
              latestTxn.rejectionReason.isNotEmpty
                  ? "Reason: ${latestTxn.rejectionReason}"
                  : "";
        }

        return Card(
          color: cardColor,
          margin: const EdgeInsets.all(12),
          child: ListTile(
            leading: Icon(icon, color: Colors.white, size: 30),
            title: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle:
                subtitle.isNotEmpty
                    ? Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70),
                    )
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildPendingMessage() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.hourglass_empty, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              "Payment Under Review",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your payment has been submitted and is waiting for admin verification. You will be notified once approved.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PLAN SELECTION
  // ==========================================
  Widget _buildPlanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "STEP 1: Select Plan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.DarkBlueGrey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: StreamBuilder<QuerySnapshot>(
            stream: _dbService.getMembershipPlans(_gymId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No plans available.\nAsk admin to create plans.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              var plans =
                  snapshot.data!.docs
                      .map((doc) => MembershipPlanModel.fromFirestore(doc))
                      .toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  var plan = plans[index];
                  bool isSelected = _selectedPlanId == plan.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlanId = plan.id;
                        _selectedPlanName = plan.planName;
                        _selectedPlanPrice = plan.price;
                        _selectedPlanDuration = plan.duration;
                      });
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.blueColor.withOpacity(0.1)
                                : Colors.white,
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.blueColor
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.planName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.blueColor
                                        : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              "\$${plan.price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.blueColor
                                        : Colors.black,
                              ),
                            ),
                            Text(
                              plan.duration,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PAYMENT METHOD SELECTION
  // ==========================================
  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "STEP 2: Select Payment Method",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.DarkBlueGrey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: _dbService.getPaymentMethodsList(_gymId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No payment methods added by Admin yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            var methods =
                snapshot.data!.docs
                    .map((doc) => PaymentMethodModel.fromFirestore(doc))
                    .toList();

            return Column(
              children:
                  methods.map((method) {
                    bool isSelected = _selectedMethodId == method.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMethodId = method.id;
                          _selectedMethodType = method.typeLabel;
                          _selectedMethodLabel = method.displayName;
                          _selectedAccountTitle = method.accountTitle;
                          _selectedAccountNumber = method.accountNumber;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.blueColor.withOpacity(0.1)
                                  : Colors.white,
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.blueColor
                                    : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              method.icon,
                              color:
                                  isSelected
                                      ? AppColors.blueColor
                                      : Colors.grey,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.typeLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    method.accountTitle,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    method.accountNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.blueColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // SCREENSHOT UPLOAD
  // ==========================================
  Widget _buildScreenshotUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "STEP 3: Upload Payment Screenshot",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.DarkBlueGrey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
            ),
            child:
                _imageBytes != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed:
                                  _isUploading
                                      ? null
                                      : () =>
                                          setState(() => _imageBytes = null),
                            ),
                          ),
                        ),
                      ],
                    )
                    : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to upload screenshot"),
                          SizedBox(height: 4),
                          Text(
                            "(Max 500KB)",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PAY NOW BUTTON
  // ==========================================
  Widget _buildPayNowButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "PAY NOW \$${_selectedPlanPrice.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LOADING BUTTON with Progress Bar
  // ==========================================
  Widget _buildLoadingButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.blueColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Message
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.blueColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    _loadingMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TRANSACTION HISTORY
  // ==========================================
  Widget _buildTransactionHistory() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            "Transaction History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.DarkBlueGrey,
            ),
          ),
        ),
        TabBar(
          controller: _historyTabController,
          isScrollable: true,
          labelColor: AppColors.blueColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Not Paid"),
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Failed"),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _historyTabController,
            children: [
              _buildHistoryList(null),
              _buildHistoryList('not_paid'),
              _buildHistoryList('pending'),
              _buildHistoryList('approved'),
              _buildHistoryList('failed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(String? statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: _dbService.getMemberPaymentHistory(_gymId, _memberId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("History Error: ${snapshot.error}");
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var aData = a.data() as Map<String, dynamic>;
          var bData = b.data() as Map<String, dynamic>;
          Timestamp? aTime = aData['createdAt'] as Timestamp?;
          Timestamp? bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        var transactions =
            docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();

        if (statusFilter != null) {
          transactions =
              transactions
                  .where((txn) => txn.status.firebaseValue == statusFilter)
                  .toList();
        }

        if (transactions.isEmpty) {
          return Center(
            child: Text(
              "No ${statusFilter ?? ''} transactions",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var txn = transactions[index];
            Color statusColor = txn.status.color;

            String dateStr = "Not submitted";
            if (txn.submittedAt != null) {
              dateStr = DateFormat('dd MMM yyyy').format(txn.submittedAt!);
            } else if (txn.createdAt != null) {
              dateStr =
                  "Created: ${DateFormat('dd MMM yyyy').format(txn.createdAt!)}";
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    txn.status == TransactionStatus.approved
                        ? Icons.check_circle
                        : txn.status == TransactionStatus.failed
                        ? Icons.cancel
                        : txn.status == TransactionStatus.pending
                        ? Icons.hourglass_empty
                        : Icons.payment,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  txn.planName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  txn.status != TransactionStatus.notPaid
                      ? "${txn.paymentMethodType} | $dateStr"
                      : dateStr,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
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
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

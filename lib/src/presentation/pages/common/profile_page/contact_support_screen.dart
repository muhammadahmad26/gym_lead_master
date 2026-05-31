import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;
  Uint8List? _screenshotBytes;
  String _screenshotName = "";

  final String _supportEmail = "gymleadmaster.support@gmail.com";
  final String _supportPhone = "+92 303 8933646";
  final String _whatsappNumber = "923038933646";

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _screenshotBytes = bytes;
        _screenshotName = image.name;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Save report to Firestore (PRIMARY — this always works)
      String base64Image = "";
      if (_screenshotBytes != null) {
        base64Image = base64Encode(_screenshotBytes!);
      }

      await FirebaseFirestore.instance.collection('support_requests').add({
        'userId': user.uid,
        'name': user.displayName ?? "User",
        'email': user.email ?? "",
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'screenshotBase64': base64Image,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Try to open email app with mailto: (OPTIONAL)
      _tryOpenEmailApp();

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Report submitted successfully! We will review it soon."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Open email app using mailto: (works on all platforms)
  void _tryOpenEmailApp() async {
    try {
      String subject = Uri.encodeComponent(
          "Support: ${_subjectController.text.trim()}");
      String body = Uri.encodeComponent(
          "Hello Support Team,\n\n"
              "${_messageController.text.trim()}\n\n"
              "--------------------\n"
              "User Details:\n"
              "Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'N/A'}\n"
              "Email: ${FirebaseAuth.instance.currentUser?.email ?? 'N/A'}\n"
              "--------------------");

      final Uri emailUri = Uri.parse(
          'mailto:$_supportEmail?subject=$subject&body=$body');

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
      // If can't launch, that's OK — report is already saved in Firestore
    } catch (e) {
      print("⚠️ Could not open email app: $e");
      // Don't show error — report is already saved in Firestore
    }
  }

  // ==========================================
  // PHONE & WHATSAPP LAUNCHERS
  // ==========================================
  Future<void> _launchCaller() async {
    try {
      final Uri telUri = Uri(scheme: 'tel', path: _supportPhone);
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        _showNotSupportedDialog("Phone Call",
            "This device does not support making phone calls directly.");
      }
    } catch (e) {
      _showNotSupportedDialog("Phone Call", "Could not open the phone dialer.");
    }
  }

  Future<void> _launchWhatsApp() async {
    try {
      String message = "Hello Gym Lead Master Support, I need help with:";
      final Uri whatsappUri = Uri.parse(
        "https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showNotSupportedDialog("WhatsApp",
            "Could not open WhatsApp. Please ensure it is installed.");
      }
    } catch (e) {
      _showNotSupportedDialog("WhatsApp",
          "An error occurred while opening WhatsApp.");
    }
  }

  void _showNotSupportedDialog(String feature, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Text("$feature Not Supported"),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // UI BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.headset_mic, size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Gym Lead Master Support',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We are here to help you',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Cards
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _launchCaller,
                          child: _buildContactCard(
                            Icons.phone_outlined,
                            "Phone",
                            _supportPhone,
                            theme,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _launchWhatsApp,
                          child: _buildContactCard(
                            Icons.chat_outlined,
                            "WhatsApp",
                            "Chat Now",
                            theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          Icons.email_outlined,
                          "Email",
                          _supportEmail,
                          theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactCard(
                          Icons.access_time,
                          "Timing",
                          "Mon-Sat (9AM-8PM)",
                          theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Report Form Header
                  Text(
                    'Report a Problem',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _subjectController,
                          validator: (v) =>
                              v!.isEmpty ? "Subject required" : null,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            prefixIcon: const Icon(Icons.subject),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          validator: (v) =>
                              v!.isEmpty ? "Description required" : null,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Issue Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Screenshot Upload
                        OutlinedButton.icon(
                          onPressed: _pickScreenshot,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            _screenshotBytes == null
                                ? 'Attach Screenshot'
                                : _screenshotName,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        if (_screenshotBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _screenshotBytes!,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _screenshotBytes = null;
                                          _screenshotName = "";
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submitRequest,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Report',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Info text
                        Text(
                          "Your report will be saved and reviewed by our team. You can also email us directly at $_supportEmail",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String subtitle,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
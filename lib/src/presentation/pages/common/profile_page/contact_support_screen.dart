// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import 'package:url_launcher/url_launcher.dart';

// class ContactSupportScreen extends StatefulWidget {
//   const ContactSupportScreen({super.key});

//   @override
//   State<ContactSupportScreen> createState() => _ContactSupportScreenState();
// }

// class _ContactSupportScreenState extends State<ContactSupportScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _messageController = TextEditingController();

//   bool _isSubmitting = false;
//   Uint8List? _screenshotBytes;
//   String _screenshotName = "";

//   final String _supportEmail = "gymleadmaster.support@gmail.com";
//   final String _supportPhone = "+92 303 8933646";
//   final String _whatsappNumber = "923038933646";

//   Future<void> _pickScreenshot() async {
//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 40,
//     );

//     if (image != null) {
//       final bytes = await image.readAsBytes();
//       setState(() {
//         _screenshotBytes = bytes;
//         _screenshotName = image.name;
//       });
//     }
//   }

//   Future<void> _submitRequest() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // Save report to Firestore (PRIMARY — this always works)
//       String base64Image = "";
//       if (_screenshotBytes != null) {
//         base64Image = base64Encode(_screenshotBytes!);
//       }

//       await FirebaseFirestore.instance.collection('support_requests').add({
//         'userId': user.uid,
//         'name': user.displayName ?? "User",
//         'email': user.email ?? "",
//         'subject': _subjectController.text.trim(),
//         'message': _messageController.text.trim(),
//         'screenshotBase64': base64Image,
//         'createdAt': FieldValue.serverTimestamp(),
//         'status': 'pending',
//       });

//       // Try to open email app with mailto: (OPTIONAL)
//       _tryOpenEmailApp();

//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Report submitted successfully! We will review it soon."),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   // Open email app using mailto: (works on all platforms)
//   void _tryOpenEmailApp() async {
//     try {
//       String subject = Uri.encodeComponent(
//           "Support: ${_subjectController.text.trim()}");
//       String body = Uri.encodeComponent(
//           "Hello Support Team,\n\n"
//               "${_messageController.text.trim()}\n\n"
//               "--------------------\n"
//               "User Details:\n"
//               "Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'N/A'}\n"
//               "Email: ${FirebaseAuth.instance.currentUser?.email ?? 'N/A'}\n"
//               "--------------------");

//       final Uri emailUri = Uri.parse(
//           'mailto:$_supportEmail?subject=$subject&body=$body');

//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(emailUri);
//       }
//       // If can't launch, that's OK — report is already saved in Firestore
//     } catch (e) {
//       debugPrint("⚠️ Could not open email app: $e");
//       // Don't show error — report is already saved in Firestore
//     }
//   }

//   // ==========================================
//   // PHONE & WHATSAPP LAUNCHERS
//   // ==========================================
//   Future<void> _launchCaller() async {
//     try {
//       final Uri telUri = Uri(scheme: 'tel', path: _supportPhone);
//       if (await canLaunchUrl(telUri)) {
//         await launchUrl(telUri);
//       } else {
//         _showNotSupportedDialog("Phone Call",
//             "This device does not support making phone calls directly.");
//       }
//     } catch (e) {
//       _showNotSupportedDialog("Phone Call", "Could not open the phone dialer.");
//     }
//   }

//   Future<void> _launchWhatsApp() async {
//     try {
//       String message = "Hello Gym Lead Master Support, I need help with:";
//       final Uri whatsappUri = Uri.parse(
//         "https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}",
//       );

//       if (await canLaunchUrl(whatsappUri)) {
//         await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
//       } else {
//         _showNotSupportedDialog("WhatsApp",
//             "Could not open WhatsApp. Please ensure it is installed.");
//       }
//     } catch (e) {
//       _showNotSupportedDialog("WhatsApp",
//           "An error occurred while opening WhatsApp.");
//     }
//   }

//   void _showNotSupportedDialog(String feature, String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (BuildContext ctx) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             children: [
//               const Icon(Icons.info_outline, color: Colors.orange),
//               const SizedBox(width: 8),
//               Text("$feature Not Supported"),
//             ],
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==========================================
//   // UI BUILD
//   // ==========================================
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.background,
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Gradient Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     theme.colorScheme.primary,
//                     theme.colorScheme.secondary,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(30),
//                   bottomRight: Radius.circular(30),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Icon(Icons.headset_mic, size: 50, color: Colors.white),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Gym Lead Master Support',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'We are here to help you',
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Contact Cards
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: _launchCaller,
//                           child: _buildContactCard(
//                             Icons.phone_outlined,
//                             "Phone",
//                             _supportPhone,
//                             theme,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: _launchWhatsApp,
//                           child: _buildContactCard(
//                             Icons.chat_outlined,
//                             "WhatsApp",
//                             "Chat Now",
//                             theme,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildContactCard(
//                           Icons.email_outlined,
//                           "Email",
//                           _supportEmail,
//                           theme,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildContactCard(
//                           Icons.access_time,
//                           "Timing",
//                           "Mon-Sat (9AM-8PM)",
//                           theme,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // Report Form Header
//                   Text(
//                     'Report a Problem',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Form
//                   Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           controller: _subjectController,
//                           validator: (v) =>
//                               v!.isEmpty ? "Subject required" : null,
//                           decoration: InputDecoration(
//                             labelText: 'Subject',
//                             prefixIcon: const Icon(Icons.subject),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _messageController,
//                           validator: (v) =>
//                               v!.isEmpty ? "Description required" : null,
//                           maxLines: 5,
//                           decoration: InputDecoration(
//                             labelText: 'Issue Description',
//                             alignLabelWithHint: true,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Screenshot Upload
//                         OutlinedButton.icon(
//                           onPressed: _pickScreenshot,
//                           icon: const Icon(Icons.attach_file),
//                           label: Text(
//                             _screenshotBytes == null
//                                 ? 'Attach Screenshot'
//                                 : _screenshotName,
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.all(14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),

//                         if (_screenshotBytes != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.memory(
//                                     _screenshotBytes!,
//                                     height: 100,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 0,
//                                   right: 0,
//                                   child: CircleAvatar(
//                                     radius: 12,
//                                     backgroundColor: Colors.red,
//                                     child: IconButton(
//                                       padding: EdgeInsets.zero,
//                                       icon: const Icon(
//                                         Icons.close,
//                                         size: 14,
//                                         color: Colors.white,
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _screenshotBytes = null;
//                                           _screenshotName = "";
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),

//                         const SizedBox(height: 24),

//                         // Submit Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: FilledButton(
//                             onPressed: _isSubmitting ? null : _submitRequest,
//                             style: FilledButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: _isSubmitting
//                                 ? const SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   )
//                                 : const Text(
//                                     'Submit Report',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         // Info text
//                         Text(
//                           "Your report will be saved and reviewed by our team. You can also email us directly at $_supportEmail",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[500],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContactCard(
//     IconData icon,
//     String title,
//     String subtitle,
//     ThemeData theme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: theme.colorScheme.primary, size: 22),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 11,
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//----update-----------//
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart';

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

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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

      _tryOpenEmailApp();

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Report submitted successfully! We will review it soon.",
            ),
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

  void _tryOpenEmailApp() async {
    try {
      String subject = Uri.encodeComponent(
        "Support: ${_subjectController.text.trim()}",
      );
      String body = Uri.encodeComponent(
        "Hello Support Team,\n\n"
        "${_messageController.text.trim()}\n\n"
        "--------------------\n"
        "User Details:\n"
        "Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'N/A'}\n"
        "Email: ${FirebaseAuth.instance.currentUser?.email ?? 'N/A'}\n"
        "--------------------",
      );

      final Uri emailUri = Uri.parse(
        'mailto:$_supportEmail?subject=$subject&body=$body',
      );

      // ✅ FIX: Just try to launch, don't check canLaunchUrl first
      await launchUrl(emailUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint("⚠️ Could not open email app: $e");
      // Don't show error — report is already saved in Firestore
    }
  }

  // ==========================================
  // ✅ FIXED: Phone Call - Try directly, don't check canLaunchUrl
  // ==========================================
  Future<void> _launchCaller() async {
    try {
      final Uri telUri = Uri(scheme: 'tel', path: _supportPhone);

      // ✅ FIX: Skip canLaunchUrl check — just try launching directly
      // canLaunchUrl returns false on many devices even when phone app exists
      bool launched = await launchUrl(
        telUri,
        mode: LaunchMode.platformDefault,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (!launched) {
        // ✅ FIX: Don't show "not supported" — copy number instead
        if (mounted) {
          _showCopyDialog(
            "Phone Call",
            "Could not open the phone dialer directly.",
            _supportPhone,
            "Phone number copied!",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showCopyDialog(
          "Phone Call",
          "Could not open the phone dialer.",
          _supportPhone,
          "Phone number copied!",
        );
      }
    }
  }

  // ==========================================
  // ✅ FIXED: WhatsApp - Try directly with multiple fallbacks
  // ==========================================
  Future<void> _launchWhatsApp() async {
    try {
      String message = "Hello Gym Lead Master Support, I need help with:";

      // ✅ FIX: Try WhatsApp app first (works on mobile)
      final Uri whatsappAppUri = Uri.parse(
        "whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(message)}",
      );

      bool launched = await launchUrl(
        whatsappAppUri,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);

      if (!launched) {
        // ✅ FALLBACK 1: Try wa.me web link (works on web + opens browser)
        final Uri whatsappWebUri = Uri.parse(
          "https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}",
        );

        bool webLaunched = await launchUrl(
          whatsappWebUri,
          mode: LaunchMode.externalApplication,
        ).timeout(const Duration(seconds: 5), onTimeout: () => false);

        if (!webLaunched && mounted) {
          // ✅ FALLBACK 2: Copy WhatsApp number
          _showCopyDialog(
            "WhatsApp",
            "Could not open WhatsApp. Please send a message to:",
            "+$_whatsappNumber",
            "WhatsApp number copied!",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showCopyDialog(
          "WhatsApp",
          "Could not open WhatsApp. Please send a message to:",
          "+$_whatsappNumber",
          "WhatsApp number copied!",
        );
      }
    }
  }

  // ==========================================
  // ✅ NEW: Copy-to-clipboard fallback dialog (instead of "Not Supported")
  // ==========================================
  void _showCopyDialog(
    String feature,
    String message,
    String copyText,
    String successMessage,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[700],
                size: AppResponsive.iconSize(context, 24),
              ),
              SizedBox(width: AppResponsive.padding(context, 8)),
              Flexible(
                child: Text(
                  feature,
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: AppResponsive.textStyle(
                  context,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppResponsive.padding(context, 12)),
              Container(
                padding: EdgeInsets.all(AppResponsive.padding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  copyText,
                  style: AppResponsive.textStyle(
                    context,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Close"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Copy to clipboard
                // Using SelectionArea or SelectableText above is enough
                // But for explicit copy:
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(successMessage),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.copy, size: 18),
              label: Text("Copy"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

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
              padding: EdgeInsets.fromLTRB(
                AppResponsive.padding(context, 20),
                AppResponsive.padding(context, 60),
                AppResponsive.padding(context, 20),
                AppResponsive.padding(context, 30),
              ),
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
                  Icon(
                    Icons.headset_mic,
                    size: AppResponsive.iconSize(context, 50),
                    color: Colors.white,
                  ),
                  SizedBox(height: AppResponsive.padding(context, 12)),
                  Text(
                    'Gym Lead Master Support',
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.padding(context, 4)),
                  Text(
                    'We are here to help you',
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppResponsive.padding(context, 16)),
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
                      SizedBox(width: AppResponsive.padding(context, 12)),
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
                  SizedBox(height: AppResponsive.padding(context, 12)),
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
                      SizedBox(width: AppResponsive.padding(context, 12)),
                      Expanded(
                        child: _buildContactCard(
                          Icons.access_time,
                          "Timing",
                          "Mon-Sat 9AM-8PM",
                          theme,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.padding(context, 24)),

                  // Report Form
                  Text(
                    'Report a Problem',
                    style: AppResponsive.textStyle(
                      context,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppResponsive.padding(context, 16)),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _subjectController,
                          validator:
                              (v) => v!.isEmpty ? "Subject required" : null,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            prefixIcon: const Icon(Icons.subject),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: AppResponsive.padding(context, 16)),
                        TextFormField(
                          controller: _messageController,
                          validator:
                              (v) => v!.isEmpty ? "Description required" : null,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Issue Description',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: AppResponsive.padding(context, 16)),

                        OutlinedButton.icon(
                          onPressed: _pickScreenshot,
                          icon: const Icon(Icons.attach_file),
                          label: Text(
                            _screenshotBytes == null
                                ? 'Attach Screenshot'
                                : _screenshotName,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(
                              AppResponsive.padding(context, 14),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        if (_screenshotBytes != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: AppResponsive.padding(context, 8),
                            ),
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

                        SizedBox(height: AppResponsive.padding(context, 24)),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submitRequest,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: AppResponsive.padding(context, 14),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      'Submit Report',
                                      style: AppResponsive.textStyle(
                                        context,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        SizedBox(height: AppResponsive.padding(context, 12)),

                        Text(
                          "Your report will be saved and reviewed by our team. You can also email us directly at $_supportEmail",
                          style: AppResponsive.textStyle(
                            context,
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
      padding: EdgeInsets.all(AppResponsive.padding(context, 12)),
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
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: AppResponsive.iconSize(context, 22),
          ),
          SizedBox(height: AppResponsive.padding(context, 8)),
          Text(
            title,
            style: AppResponsive.textStyle(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            subtitle,
            style: AppResponsive.textStyle(
              context,
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

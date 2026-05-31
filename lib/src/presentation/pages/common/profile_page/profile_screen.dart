import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/services/settings_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/term_and_conditions_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import New Professional Screens
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/help_faq_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/contact_support_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/about_app_screen.dart';


class ProfileScreen extends StatefulWidget {
  final bool isAdmin;
  const ProfileScreen({super.key, required this.isAdmin});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Map<String, String>? _userData;
  bool _isDarkMode = false;
  String _language = 'English';

  // Image state
  bool _isImageUploading = false;
  String _uploadStatus = "";
  String _profileImageBase64 = "";
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        var data = doc.data()!;
        String base64Image = data['profileImageBase64'] ?? "";

        setState(() {
          _userData = {
            'name': data['name'] ?? "User",
            'email': data['email'] ?? "",
            'role': data['role'] ?? "Member",
            'location': data['location'] ?? "",
            'gymId': data['gymId'] ?? "",
          };
          _profileImageBase64 = base64Image;

          if (base64Image.isNotEmpty) {
            try {
              _profileImageBytes = base64Decode(base64Image);
            } catch (e) {
              _profileImageBytes = null;
            }
          }

          _nameController.text = _userData!['name'] ?? "User";
          _emailController.text = _userData!['email'] ?? "email@example.com";
          _locationController.text = _userData!['location'] ?? "";
        });
      }
    } catch (e) {
      print("ERROR LOADING USER DATA: $e");
    }
  }

  Future<void> _loadSettings() async {
    bool isDark = await SettingsService().getThemeMode();
    String lang = await SettingsService().getLanguage();
    setState(() {
      _isDarkMode = isDark;
      _language = (lang == "ur") ? "Urdu" : "English";
    });
  }

  // ==================== IMAGE UPLOAD (Base64 in Firestore) ====================
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 60,
    );

    if (image == null) return;

    try {
      Uint8List bytes = await image.readAsBytes();

      if (bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to read image."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (bytes.length > 700000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image is too large. Max 700KB allowed."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _profileImageBytes = bytes;
        _isImageUploading = true;
        _uploadStatus = "Saving...";
      });

      String base64String = base64Encode(bytes);
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageBase64': base64String,
        'profileImage': "",
        'imageUrl': "",
      });

      if (!widget.isAdmin && _userData!['gymId']!.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('gyms')
              .doc(_userData!['gymId'])
              .collection('members')
              .doc(uid)
              .update({'profileImageBase64': base64String});
        } catch (e) {
          print("⚠️ Could not update gym members: $e");
        }
      }

      if (mounted) {
        setState(() {
          _profileImageBase64 = base64String;
          _isImageUploading = false;
          _uploadStatus = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile image updated! ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImageUploading = false;
          _uploadStatus = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Remove Image"),
            content: const Text(
              "Are you sure you want to remove your profile image?",
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
                  "Remove",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isImageUploading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageBase64': "",
        'profileImage': "",
        'imageUrl': "",
      });

      if (mounted) {
        setState(() {
          _profileImageBase64 = "";
          _profileImageBytes = null;
          _isImageUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image removed")));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImageUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // ==================== PROFILE UPDATES ====================
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
    });

    if (!widget.isAdmin && _userData!['gymId']!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('gyms')
            .doc(_userData!['gymId'])
            .collection('members')
            .doc(uid)
            .update({
              'name': _nameController.text.trim(),
              'location': _locationController.text.trim(),
            });
      } catch (e) {}
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));
    setState(() {
      _userData!['name'] = _nameController.text;
      _userData!['location'] = _locationController.text;
    });
  }

  Future<void> _updateEmail() async {
    if (_emailController.text.trim().isEmpty) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'email': _emailController.text.trim()});
        setState(() => _userData!['email'] = _emailController.text.trim());
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Email Updated")));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error updating email")));
    }
  }

  Future<void> _updateLocation() async {
    if (_locationController.text.trim().isEmpty) return;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'location': _locationController.text.trim(),
    });

    if (!widget.isAdmin && _userData!['gymId']!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('gyms')
            .doc(_userData!['gymId'])
            .collection('members')
            .doc(uid)
            .update({'location': _locationController.text.trim()});
      } catch (e) {}
    }

    setState(() => _userData!['location'] = _locationController.text);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Location Updated")));
  }

  Future<void> _changePassword() async {
    if (_currentPassController.text.isEmpty || _newPassController.text.isEmpty)
      return;
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
    try {
      final cred = FirebaseAuth.instance.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: cred.email!,
        password: _currentPassController.text.trim(),
      );
      await cred.reauthenticateWithCredential(credential);
      await cred.updatePassword(_newPassController.text.trim());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Updated Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current Password is incorrect")),
      );
    }
  }

  // ==================== LOGOUT ====================
  Future<void> _logout() async {
    bool? confirmLogout = await _showLogoutConfirmationDialog();
    if (confirmLogout != true) return;
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          // padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 40),

              // ==================== PROFILE HEADER ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blueColor, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isImageUploading ? null : _pickAndUploadImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(child: _buildProfileImage()),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child:
                                  _isImageUploading
                                      ? Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: AppColors.blueColor,
                                          ),
                                        ),
                                      )
                                      : Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.blueColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isImageUploading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _uploadStatus,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _userData!['name'] ?? "User",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        _userData!['email'] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    if (_userData!['location']!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _userData!['location']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          (_userData!['role'] ?? "").toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== PROFILE SETTINGS ====================
              _buildSectionHeader("Profile Settings"),
              Card(
                child: Column(
                  children: [
                    _buildTile(
                      Icons.edit,
                      "Edit Profile",
                      () => _showEditProfileDialog(),
                    ),
                    _buildTile(
                      Icons.email,
                      "Update Email",
                      () => _showEditEmailDialog(),
                    ),
                    _buildTile(
                      Icons.location_on,
                      "Update Location",
                      () => _showEditLocationDialog(),
                    ),
                    if (_profileImageBytes != null)
                      _buildTile(
                        Icons.delete_outline,
                        "Remove Profile Image",
                        _removeImage,
                        color: Colors.red,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== SECURITY SETTINGS ====================
              _buildSectionHeader("Security Settings"),
              Card(
                child: _buildTile(
                  Icons.lock,
                  "Change Password",
                  () => _showChangePasswordDialog(),
                ),
              ),

              const SizedBox(height: 20),

              // ==================== SUPPORT (CONNECTED TO NEW SCREENS) ====================
              _buildSectionHeader("Support"),
              Card(
                child: Column(
                  children: [
                    _buildTile(Icons.help_center, "Help & FAQ", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpFaqScreen(),
                        ),
                      );
                    }),
                    _buildTile(Icons.contact_support, "Contact Support", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactSupportScreen(),
                        ),
                      );
                    }),
                    _buildTile(Icons.info, "About App", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutAppScreen(),
                        ),
                      );
                    }),
                    _buildTile(Icons.description, "Terms & Conditions", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================== LOGOUT ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _logout,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PROFILE IMAGE WIDGET ====================
  Widget _buildProfileImage() {
    if (_profileImageBytes != null && _profileImageBytes!.isNotEmpty) {
      return Image.memory(
        _profileImageBytes!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
    );
  }

  // ==================== HELPERS ====================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
      child: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(color: Colors.black54),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.DarkBlueGrey),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.Lightertext),
      onTap: onTap,
    );
  }

  // ==================== DIALOGS ====================
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Profile"),
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    controller: _nameController,
                    label: "Full Name",
                    icon_asset: AppImages.userIcon,
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: _locationController,
                    label: "Location",
                    icon_asset: AppImages.locationIcon,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showEditEmailDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Update Email"),
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextFormField(
                controller: _emailController,
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                icon_asset: AppImages.emailIcon,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _updateEmail,
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showEditLocationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Update Location"),
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextFormField(
                controller: _locationController,
                label: "Location",
                icon_asset: AppImages.locationIcon,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _updateLocation,
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PasswordField(
                    label: "Current Password",
                    controller: _currentPassController,
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),
                  PasswordField(
                    label: "New Password",
                    controller: _newPassController,
                    validator: (val) => val!.length < 6 ? "Too short" : null,
                  ),
                  const SizedBox(height: 10),
                  PasswordField(
                    label: "Confirm Password",
                    controller: _confirmPassController,
                    validator:
                        (val) =>
                            val != _newPassController.text ? "No match" : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }
}

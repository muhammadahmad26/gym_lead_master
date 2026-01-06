import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/constants/app_text_size.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';

import 'data/services/super_admin_service.dart';

class SuperAdminAddAdminPage extends StatefulWidget {
  const SuperAdminAddAdminPage({super.key});

  @override
  State<SuperAdminAddAdminPage> createState() => _SuperAdminAddAdminPageState();
}

class _SuperAdminAddAdminPageState extends State<SuperAdminAddAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final SuperAdminService _superAdminService = SuperAdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _gymNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final superAdmin = _auth.currentUser;
      if (superAdmin == null) {
        throw Exception('Not authenticated');
      }

      await _superAdminService.createAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        gymName: _gymNameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        createdBy: superAdmin.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin created successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gymNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    final sizedBoxCustom = SizedBox(height: height * 0.015);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackGroundPage(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  Text(
                    'Create New Gym Admin',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  Container(
                    padding: EdgeInsets.all(width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Profile Picture Placeholder
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.BrightBlue.withOpacity(0.3),
                                child: const Icon(
                                  Icons.person_add,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.BrightBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        // Name
                        CustomTextFormField(
                          controller: _nameController,
                          label: "Admin Name",
                          icon_asset: AppImages.userIcon,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        sizedBoxCustom,

                        // Email
                        CustomTextFormField(
                          controller: _emailController,
                          label: "Email",
                          icon_asset: AppImages.emailIcon,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => EmailValidator.validator(value),
                        ),
                        sizedBoxCustom,

                        // Password
                        PasswordField(
                          controller: _passwordController,
                          label: "Password",
                          validator: (value) => PasswordValidator.validator(value),
                        ),
                        sizedBoxCustom,

                        // Confirm Password
                        PasswordField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        sizedBoxCustom,

                        // Gym Name
                        CustomTextFormField(
                          controller: _gymNameController,
                          label: "Gym Name",
                          icon_asset: AppImages.addUser,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Gym name is required';
                            }
                            return null;
                          },
                        ),
                        sizedBoxCustom,

                        // Phone
                        CustomTextFormField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon_asset: AppImages.addUser,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        ),
                        sizedBoxCustom,

                        // Location
                        CustomTextFormField(
                          controller: _locationController,
                          label: "Location",
                          icon_asset: AppImages.locationIcon,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Location is required';
                            }
                            return null;
                          },
                        ),
                        sizedBoxCustom,

                        // Submit Button
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : AppButton(
                                text: "Create Admin",
                                onPressed: _createAdmin,
                              ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

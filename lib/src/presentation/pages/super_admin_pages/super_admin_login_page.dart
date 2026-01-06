import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';

import 'data/services/super_admin_service.dart';

class SuperAdminLoginPage extends StatefulWidget {
  const SuperAdminLoginPage({super.key});

  @override
  State<SuperAdminLoginPage> createState() => _SuperAdminLoginPageState();
}

class _SuperAdminLoginPageState extends State<SuperAdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final SuperAdminService _superAdminService = SuperAdminService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminUser = await _superAdminService.loginAsSuperAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
      );

      if (adminUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/super_admin_dashboard',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome, Super Admin!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: AppColors.accent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    final sizedBoxCustom = SizedBox(height: height * 0.02);

    return Scaffold(
      body: AppBackGroundPage(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              children: [
                SizedBox(height: height * 0.05),
                Image.asset(
                  AppImages.appLogoIcon,
                  height: height * 0.2,
                  width: width * 0.4,
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 104, 119, 126).withOpacity(0.2),
                        const Color.fromARGB(255, 176, 196, 222).withOpacity(0.2),
                        const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                        const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Super Admin Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.DarkBlueGrey,
                          ),
                        ),
                        SizedBox(height: height * 0.05),

                        CustomTextFormField(
                          controller: _emailController,
                          validator: (value) => EmailValidator.validator(value),
                          keyboardType: TextInputType.emailAddress,
                          icon_asset: AppImages.emailIcon,
                          label: "Email", 
                          obsecuretext: true,
                        ),
                        sizedBoxCustom,

                        PasswordField(
                          controller: _passwordController,
                          label: "Password",
                          validator: (value) => PasswordValidator.validator(value),
                        ),
                        sizedBoxCustom,

                        CustomTextFormField(
                          controller: _secretKeyController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Secret key is required';
                            }
                            return null;
                          },
                          icon_asset: AppImages.keyIcon,
                          label: "Secret Key",
                          obsecuretext: true,
                        ),
                        sizedBoxCustom,

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Back',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blueAccent.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        sizedBoxCustom,
                        _isLoading
                            ? const CircularProgressIndicator()
                            : AppButton(
                                text: "Login as Super Admin",
                                onPressed: () => _login(context),
                              ),
                      ],
                    ),
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

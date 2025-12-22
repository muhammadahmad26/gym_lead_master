import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Failed to send password reset email.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forget Password',
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.mediumBlue,
      ),
      body: AppBackGroundPage(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email to reset your password:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.Lightertext,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: emailController,
                  validator: (value) => EmailValidator.validator(value),
                  keyboardType: TextInputType.emailAddress,
                  icon_asset: AppImages.emailIcon,
                  label: "Email",
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColor,
                        strokeWidth: 2,
                      ),
                    )
                    : Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _sendPasswordResetEmail();
                          }
                        },
                        child: const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            color: AppColors.Lightertext,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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

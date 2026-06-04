import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart'; // ✅ Import
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/presentation/pages/common/forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.recognizer,
    required this.route,
    required this.expectedRole, 
  });

  final String route;
  final GestureRecognizer? recognizer;
  final String expectedRole;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _autoValidate = false;

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    setState(() => isLoading = true);
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        String userRole = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'member';

        if (widget.expectedRole == 'admin') {
          if (userRole != 'admin') {
            await FirebaseAuth.instance.signOut();
            throw Exception("Access Denied! This account is not registered as an Admin.");
          }
        } else {
          if (userRole == 'admin') {
            await FirebaseAuth.instance.signOut();
            throw Exception("Access Denied! Admins cannot login on Member side.");
          }
        }
      } else {
        await FirebaseAuth.instance.signOut();
        throw Exception("User data not found in database.");
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, widget.route, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else {
        message = e.message ?? 'Login failed.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),
                  Image.asset(AppImages.appLogoIcon, height: height * 0.15, width: width * 0.35),
                  SizedBox(height: height * 0.01),
                  Container(
                    padding: EdgeInsets.all(width * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF68777C).withOpacity(0.2),
                          const Color(0xFFB0C4DE).withOpacity(0.2),
                          const Color(0xFFFFFFFF).withOpacity(0.2),
                          const Color(0xFFFFFFFF).withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          // ✅ Responsive Title
                          Text(
                            'LogIn',
                            style: AppResponsive.textStyle(
                              context,
                              fontSize: 26, // Base size, auto scales down on small screens
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: AppResponsive.padding(context, 20)), // ✅ Responsive Spacing
                          CustomTextFormField(
                            controller: _emailController,
                            validator: (value) => EmailValidator.validator(value),
                            keyboardType: TextInputType.emailAddress,
                            icon_asset: AppImages.emailIcon,
                            label: "Email",
                          ),
                          SizedBox(height: AppResponsive.padding(context, 10)),
                          PasswordField(
                            controller: _passwordController,
                            label: "Password",
                            validator: (value) => PasswordValidator.validator(value),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage()));
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppResponsive.textStyle(
                                  context,
                                  fontSize: 12, // ✅ Responsive
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppResponsive.padding(context, 10)),
                          isLoading
                              ? const CircularProgressIndicator()
                              : AppButton(text: "LogIn", onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _login(context);
                                  } else {
                                    setState(() => _autoValidate = true);
                                  }
                                }),
                          SizedBox(height: AppResponsive.padding(context, 8)),
                          // ✅ Responsive Bottom Text
                          FittedBox( // Prevents overflow on small screens
                            child: Padding(
                              padding: EdgeInsets.only(left: width * 0.1),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppResponsive.textStyle(context, fontSize: 13, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: AppResponsive.textStyle(
                                        context,
                                        fontSize: 15,
                                        color: Colors.blueAccent.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: widget.recognizer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
      ],
    );
  }
}
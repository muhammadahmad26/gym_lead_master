import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.recognizer,
    required this.route,
    required this.expectedRole, 
  });

  final String route;
  final GestureRecognizer? recognizer;
  final String expectedRole; // 'admin' or 'member'

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // Auto-validate state
  bool _autoValidate = false;

  Future<void> _login(BuildContext context) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidate = true; // If validation fails, turn on auto-validate
      });
      return;
    }

    setState(() {
      isLoading = true;
    });
    try {
      // 1. Firebase Authentication
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Fetch User Role from Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .get();

      if (userDoc.exists) {
        String userRole =
            userDoc.data() is Map<String, dynamic>
                ? (userDoc.data() as Map<String, dynamic>)['role'] ?? 'member'
                : 'member';

        // 3. Verify Role
        if (widget.expectedRole == 'admin') {
          if (userRole != 'admin') {
            await FirebaseAuth.instance.signOut();
            throw Exception(
              "Access Denied! This account is not registered as an Admin.",
            );
          }
        } else {
          if (userRole == 'admin') {
            await FirebaseAuth.instance.signOut();
            throw Exception(
              "Access Denied! Admins cannot login on Member side.",
            );
          }

          // 4. Members need admin approval before they can log in. The
          // approval status lives on the member record (gyms/{gymId}/
          // members/{uid}) — that's the doc an admin can actually write
          // to (see firestore.rules), so it's the source of truth here.
          String? memberGymId =
              (userDoc.data() as Map<String, dynamic>)['gymId'];
          if (memberGymId != null) {
            DocumentSnapshot memberDoc =
                await FirebaseFirestore.instance
                    .collection('gyms')
                    .doc(memberGymId)
                    .collection('members')
                    .doc(credential.user!.uid)
                    .get();

            if (!memberDoc.exists) {
              await FirebaseAuth.instance.signOut();
              throw Exception(
                "Your account was not found. It may have been removed by your gym admin.",
              );
            }

            String approvalStatus =
                (memberDoc.data() as Map<String, dynamic>?)?['approvalStatus'] ??
                'approved'; // legacy members created before this feature
            if (approvalStatus == 'pending') {
              await FirebaseAuth.instance.signOut();
              throw Exception(
                "Your signup is still pending admin approval. Please wait for approval before logging in.",
              );
            }
          }
        }
      } else {
        await FirebaseAuth.instance.signOut();
        throw Exception("User data not found in database.");
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          widget.route,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = e.message ?? 'Login failed. Please try again.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    final SizedBox sizedBoxCustom = SizedBox(height: height * 0.02);

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
                          const Color.fromARGB(
                            255,
                            104,
                            119,
                            126,
                          ).withOpacity(0.2),
                          const Color.fromARGB(
                            255,
                            176,
                            196,
                            222,
                          ).withOpacity(0.2),
                          const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.2),
                          const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.2),
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
                      // Autovalidate mode added
                      autovalidateMode:
                          _autoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Text(
                            'LogIn',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          CustomTextFormField(
                            controller: _emailController,
                            validator:
                                (value) => EmailValidator.validator(value),
                            keyboardType: TextInputType.emailAddress,
                            icon_asset: AppImages.emailIcon,
                            label: "Email",
                          ),
                          sizedBoxCustom,
                          PasswordField(
                            controller: _passwordController,
                            label: "Password",
                            validator:
                                (value) => PasswordValidator.validator(value),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgetPasswordPage,
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFF1976D2),
                                  color: Colors.blueAccent.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          sizedBoxCustom,
                          isLoading
                              ? const CircularProgressIndicator()
                              : AppButton(
                                text: "LogIn",
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _login(context);
                                  } else {
                                    // If validation fails, turn on auto-validate
                                    setState(() {
                                      _autoValidate = true;
                                    });
                                  }
                                },
                              ),
                          SizedBox(height: height * 0.01),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Colors.blueAccent.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    recognizer: widget.recognizer,
                                  ),
                                ],
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

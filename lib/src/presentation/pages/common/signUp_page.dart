import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class SignUpPage extends StatefulWidget {
  final String recognizer;
  final String route;
  const SignUpPage({super.key, required this.recognizer, required this.route});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  Future<void> _signUp(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseAuth.instance.signOut();

      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.route,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else {
        message = e.message ?? 'Sign up failed. Please try again.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Size(:width, :height) = MediaQuery.sizeOf(context);
    final SizedBox customSizeBoxed = SizedBox(height: height * 0.02);
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
                    width: width * 0.4,
                    height: height * 0.2,
                  ),
                  SizedBox(height: height * 0.01),

                  Container(
                    margin: EdgeInsets.only(bottom: height * 0.05),
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.03,
                    ),
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
                      child: Column(
                        children: [
                          Text(
                            'Sign Up',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.03),
                          const CustomTextFormField(
                            label: "Name",
                            icon_asset: AppImages.weightLiftingIcon,
                            keyboardType: TextInputType.name,
                            // controller: TextEditingController(),
                          ),
                          customSizeBoxed,
                          CustomTextFormField(
                            validator:
                                (value) => EmailValidator.validator(value),
                            controller: _emailController,

                            icon_asset: AppImages.emailIcon,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          customSizeBoxed,
                          PasswordField(
                            label: "password",
                            validator:
                                (value) => PasswordValidator.validator(value),
                            controller: _passwordController,
                          ),
                          customSizeBoxed,
                          PasswordField(
                            controller: _confirmPasswordController,
                            validator:
                                (Value) =>
                                    Value != _passwordController.text
                                        ? "Passwords do not match"
                                        : null,
                            label: "Confirm Password",
                          ),
                          customSizeBoxed,

                          const CustomTextFormField(
                            label: "Location",
                            icon_asset: AppImages.locationIcon,
                          ),
                          customSizeBoxed,
                          isLoading
                              ? const CircularProgressIndicator()
                              : AppButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _signUp(context);
                                  }
                                },
                                text: 'Sign Up',
                              ),
                          customSizeBoxed,

                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: Colors.blueAccent.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              widget.recognizer,
                                              (route) =>
                                                  route.settings.name ==
                                                  AppRoutes.initialPage,
                                            );
                                          },
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

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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(AppImages.appLogoIcon, width: 100, height: 100),
            customSizeBoxed,
            const CustomTextFormField(
              label: "Name",
              icon_asset: AppImages.weightLiftingIcon,
              keyboardType: TextInputType.name,
              // controller: TextEditingController(),
            ),
            customSizeBoxed,
            CustomTextFormField(
              validator: (value) => EmailValidator.validator(value),
              controller: _emailController,

              icon_asset: AppImages.emailIcon,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            customSizeBoxed,
            PasswordField(
              label: "password",
              validator: (value) => PasswordValidator.validator(value),
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

            customSizeBoxed,
            const CustomTextFormField(
              label: "Location",
              icon_asset: AppImages.locationIcon,
            ),
            customSizeBoxed,
            AppButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signUp(context);
                }
              },
              text: 'Sign Up',
            ),
            customSizeBoxed,
            // SizedBox(height: height * 0.01),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
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
    );
  }
}

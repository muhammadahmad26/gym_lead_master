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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.recognizer, required this.route});
  final String route;
  final GestureRecognizer? recognizer;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  Future<void> _login(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.route,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = e.message ?? 'Login failed. Please try again.';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    final SizedBox sizedBoxCustom = SizedBox(height: height * 0.02);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(AppImages.appLogoIcon, height: 100, width: 100),
            sizedBoxCustom,
            CustomTextFormField(
              controller: _emailController,
              validator: (value) => EmailValidator.validator(value),
              keyboardType: TextInputType.emailAddress,
              icon_asset: AppImages.emailIcon,
              label: "Email",
            ),
            sizedBoxCustom,
            PasswordField(
              controller: _passwordController,
              label: "Password",
              validator: (value) => PasswordValidator.validator(value),
            ),
            sizedBoxCustom,
            AppButton(
              text: "LogIn",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _login(context);
                }
              },
            ),
            SizedBox(height: height * 0.01),
            Padding(
              padding: const EdgeInsets.only(left: 75),
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
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
    );
  }
}

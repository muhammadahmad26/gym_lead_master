import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/customTextFormField.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  LoginPage({super.key});

  static const appLogoIcon = 'assets/images/app_main_logo.png';
  static const emailIcon = 'assets/images/email.png';
  static const keyIcon = 'assets/images/key.png';
  static const userIcon = 'assets/images/user.png';
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    final SizedBox sizedBoxCustom = SizedBox(height: height * 0.02);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(appLogoIcon, height: 100, width: 100),
            sizedBoxCustom,
            CustomTextFormField(
              controller: _emailController,
              validator: (value) => EmailValidator.validator(value),
              keyboardType: TextInputType.emailAddress,
              icon_asset: emailIcon,
              label: "Email",
            ),
            sizedBoxCustom,
            PasswordField(),
            sizedBoxCustom,
            AppButton(
              text: "LogIn",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, AppRoutes.logIn);
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
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, AppRoutes.logIn);
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

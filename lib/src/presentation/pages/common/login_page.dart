import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key,required this.recognizer});
  final GestureRecognizer recognizer;
  final _formKey = GlobalKey<FormState>();
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
            PasswordField(label: "Password"),
            sizedBoxCustom,
            AppButton(
              text: "LogIn",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, AppRoutes.adminHomePage);
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
                      recognizer:recognizer
                          // TapGestureRecognizer()
                          //   ..onTap = () {
                          //     Navigator.pushNamed(
                          //       context,
                          //       AppRoutes.gymAdminSignUpPage,
                          //     );
                          //   },
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

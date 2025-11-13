import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/customTextFormField.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var Size(:width, :height) = MediaQuery.sizeOf(context);
    final SizedBox customSizeBoxed = SizedBox(height: height * 0.02);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(
              AppImages.appLogoIcon,
              width: 100,
              height: 100,
            ),
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
            const PasswordField(label: "password"),
            customSizeBoxed,
            const PasswordField(label: "Confirm Password"),
            customSizeBoxed,
            const CustomTextFormField(
              label: "Time Of Gym",
              icon_asset: AppImages.clockIcon,
            ),
            customSizeBoxed,
            const CustomTextFormField(
              label: "Location",
              icon_asset: AppImages.locationIcon,
            ),
            customSizeBoxed,
            AppButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, AppRoutes.initialPage);
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

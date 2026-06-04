import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/auth_service.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart'; // ✅ Import
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/utils/password_validator.dart';
import 'package:gym_lead_master/src/core/widgets/app_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';
import 'package:gym_lead_master/src/core/widgets/passwordField.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class SignUpPage extends StatefulWidget {
  final String recognizer;
  final String route;
  final bool isAdmin;

  const SignUpPage({
    super.key,
    required this.recognizer,
    required this.route,
    this.isAdmin = false,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _gymIdController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedRole = 'Gym Member';
  bool isLoading = false;
  bool _autoValidate = false;
  final AuthService _authService = AuthService();

  Future<void> _signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    setState(() => isLoading = true);

    String? error;
    if (widget.isAdmin) {
      error = await _authService.signUpAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        gymId: _gymIdController.text.trim(),
        location: _locationController.text.trim(),
      );
    } else {
      error = await _authService.signUpMember(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        gymId: _gymIdController.text.trim(),
        role: _selectedRole,
        location: _locationController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        widget.route,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gymIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Size(:width, :height) = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: AppBackGroundPage(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.04),
                    Image.asset(
                      AppImages.appLogoIcon,
                      height: height * 0.12,
                      width: width * 0.25,
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: EdgeInsets.all(width * 0.04),
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
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
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
                        autovalidateMode:
                            _autoValidate
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            Text(
                              widget.isAdmin
                                  ? 'Admin Sign Up'
                                  : 'Member Sign Up',
                              style: AppResponsive.textStyle(
                                context,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ), // ✅ Responsive
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 16),
                            ),
                            CustomTextFormField(
                              label: "Name",
                              controller: _nameController,
                              icon_asset: AppImages.userIcon,
                              validator:
                                  (val) => val!.isEmpty ? "Required" : null,
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),
                            CustomTextFormField(
                              controller: _emailController,
                              validator: EmailValidator.validator,
                              icon_asset: AppImages.emailIcon,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),
                            PasswordField(
                              controller: _passwordController,
                              label: "Password",
                              validator: PasswordValidator.validator,
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),
                            PasswordField(
                              controller: _confirmPasswordController,
                              validator:
                                  (val) =>
                                      val != _passwordController.text
                                          ? "Passwords do not match"
                                          : null,
                              label: "Confirm Password",
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),
                            CustomTextFormField(
                              controller: _gymIdController,
                              label:
                                  widget.isAdmin
                                      ? "Create Unique Gym ID"
                                      : "Enter Gym ID",
                              icon_asset: AppImages.userIcon,
                              validator:
                                  (val) => val!.isEmpty ? "Required" : null,
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),
                            CustomTextFormField(
                              controller: _locationController,
                              label: "Location",
                              icon_asset: AppImages.locationIcon,
                              validator:
                                  (val) => val!.isEmpty ? "Required" : null,
                            ),
                            SizedBox(
                              height: AppResponsive.padding(context, 10),
                            ),

                            if (!widget.isAdmin)
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                items:
                                    ['Gym Member', 'Trainer'].map((role) {
                                      return DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          role,
                                          style: AppResponsive.textStyle(
                                            context,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (val) =>
                                        setState(() => _selectedRole = val!),
                                decoration: InputDecoration(
                                  labelText: "Role",
                                  labelStyle: AppResponsive.textStyle(
                                    context,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: AppResponsive.padding(
                                      context,
                                      14,
                                    ),
                                  ), // ✅ Responsive
                                ),
                              ),
                            if (!widget.isAdmin)
                              SizedBox(
                                height: AppResponsive.padding(context, 10),
                              ),

                            isLoading
                                ? const CircularProgressIndicator()
                                : AppButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _signUp(context);
                                    } else {
                                      setState(() => _autoValidate = true);
                                    }
                                  },
                                  text: 'Sign Up',
                                ),
                            SizedBox(height: AppResponsive.padding(context, 8)),

                            // ✅ Responsive Bottom Text
                            FittedBox(
                              child: Padding(
                                padding: EdgeInsets.only(left: width * 0.1),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: AppResponsive.textStyle(
                                      context,
                                      fontSize: 13,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Sign In",
                                        style: AppResponsive.textStyle(
                                          context,
                                          fontSize: 15,
                                          color: Colors.blueAccent.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.pushNamedAndRemoveUntil(
                                                  context,
                                                  widget.route,
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
        ),
      ],
    );
  }
}

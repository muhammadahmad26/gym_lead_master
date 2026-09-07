import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_lead_master/services/auth_service.dart';
import 'package:gym_lead_master/src/core/constants/app_bg_page.dart';
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
    final SizedBox sizedBoxCustom = SizedBox(height: height * 0.02);

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
                    SizedBox(height: height * 0.05),

                    // SAME AS LOGIN: App Logo at top
                    Image.asset(
                      AppImages.appLogoIcon,
                      height: height * 0.15,
                      width: width * 0.30,
                    ),
                    SizedBox(height: height * 0.02),

                    // SAME AS LOGIN: Professional container with gradient, border, shadow
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
                            // SAME AS LOGIN: Title
                            Text(
                              widget.isAdmin
                                  ? 'Admin Sign Up'
                                  : 'Member Sign Up',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: height * 0.03),

                            // Name
                            CustomTextFormField(
                              label: "Name",
                              controller: _nameController,
                              icon_asset: AppImages.userIcon,
                              validator:
                                  (val) => val!.isEmpty ? "Required" : null,
                            ),
                            sizedBoxCustom,

                            // Email
                            CustomTextFormField(
                              controller: _emailController,
                              validator: EmailValidator.validator,
                              icon_asset: AppImages.emailIcon,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            sizedBoxCustom,

                            // Password
                            PasswordField(
                              controller: _passwordController,
                              label: "Password",
                              validator: PasswordValidator.validator,
                            ),
                            sizedBoxCustom,

                            // Confirm Password
                            PasswordField(
                              controller: _confirmPasswordController,
                              validator:
                                  (val) =>
                                      val != _passwordController.text
                                          ? "Passwords do not match"
                                          : null,
                              label: "Confirm Password",
                            ),
                            sizedBoxCustom,

                            // Gym ID
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
                            sizedBoxCustom,

                            // Location
                            CustomTextFormField(
                              controller: _locationController,
                              label: "Location",
                              icon_asset: AppImages.locationIcon,
                              validator:
                                  (val) => val!.isEmpty ? "Required" : null,
                            ),
                            sizedBoxCustom,

                            // Role (Member only)
                            if (!widget.isAdmin)
                              _RoleDropdown(
                                initialRole: _selectedRole,
                                onChanged: (val) => _selectedRole = val,
                              ),

                            if (!widget.isAdmin) sizedBoxCustom,

                            // AS LOGIN: Button or Loading
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

                            SizedBox(height: height * 0.01),

                            // AS LOGIN: Sign In link
                            //  Navigate to Login page instead of pop
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(
                                        color: Colors.blueAccent.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              //  Navigate to login page properly
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                widget
                                                    .route, // This IS the login route
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
        ),
      ],
    );
  }
}


class _RoleDropdown extends StatefulWidget {
  final String initialRole;
  final ValueChanged<String> onChanged;

  const _RoleDropdown({required this.initialRole, required this.onChanged});

  @override
  State<_RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<_RoleDropdown> {
  late String _selectedRole = widget.initialRole;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items:
          ['Gym Member', 'Trainer'].map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
      onChanged: (val) {
        setState(() => _selectedRole = val!);
        widget.onChanged(val!);
      },
      decoration: InputDecoration(
        labelText: "Role",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}

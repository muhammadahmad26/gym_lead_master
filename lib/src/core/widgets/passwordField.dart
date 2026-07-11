import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';

import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const PasswordField({super.key, required this.label, this.controller,this.validator});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
 

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: widget.controller,
      icon_asset: AppImages.keyIcon,
      label: widget.label,
      obsecuretext: _obscureText,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

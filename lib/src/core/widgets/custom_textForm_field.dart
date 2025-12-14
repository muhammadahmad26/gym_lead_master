import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? icon_asset;
  final Widget? prefixIconWidget;
  final String label;
  final bool obsecuretext;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    this.icon_asset,
    this.prefixIconWidget,
    required this.label,
    this.obsecuretext = false,
    this.controller,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : assert(
         icon_asset != null || prefixIconWidget != null,
         'Either iconAsset or prefixIconWidget must be provided',
       );

  @override
  Widget build(BuildContext context) {
    var Size(:width, :height) = MediaQuery.sizeOf(context);
    return SizedBox(
      width: width * 0.9,
      height: height * 0.07,
      child: TextFormField(
        controller: controller,
        obscureText: obsecuretext,
        keyboardType: keyboardType,
        validator: validator,
        // onChanged: (value) => ,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          label: FittedBox(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          errorMaxLines: 2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
          prefixIcon:
              prefixIconWidget ??
              (icon_asset != null
                  ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(icon_asset!, fit: BoxFit.cover),
                  )
                  : null),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
      ),
    );
  }
}

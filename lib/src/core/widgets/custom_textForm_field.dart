import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/utils/app_responsive.dart'; 

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
    var Size(:width) = MediaQuery.sizeOf(context);
    return SizedBox(
      width: width * 0.9,
      child: TextFormField(
        controller: controller,
        obscureText: obsecuretext,
        keyboardType: keyboardType,
        validator: validator,
        style: AppResponsive.textStyle(context, fontSize: 14), 
        decoration: InputDecoration(
          isDense: true,
          label: FittedBox( // Label ab kabhi cut nahi hoga
            child: Text(
              label,
              style: AppResponsive.textStyle(context, fontSize: 14, color: Colors.black54),
            ),
          ),
          errorMaxLines: 2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorStyle: AppResponsive.textStyle(context, fontSize: 10, color: Colors.red),
          prefixIcon: prefixIconWidget ?? (icon_asset != null
              ? Padding(
                  padding: EdgeInsets.all(AppResponsive.padding(context, 10)), // Responsive
                  child: Image.asset(icon_asset!, fit: BoxFit.cover),
                )
              : null),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            vertical: AppResponsive.padding(context, 14), // Responsive
            horizontal: AppResponsive.padding(context, 12), // Responsive
          ),
        ),
      ),
    );
  }
}
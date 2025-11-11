import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String icon;
  final String label;
  final bool obsecuretext;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  const CustomTextFormField({
    super.key,
    required this.icon,
    required this.label,
    this.obsecuretext = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    var Size(:width, :height) = MediaQuery.sizeOf(context);
    return SizedBox(
      width: width * 0.8,
      height: height * 0.07,
      child: Material(
        color: Colors.amber[200],
        borderRadius: BorderRadius.circular(15),
        child: TextFormField(
          controller: controller,
          obscureText: obsecuretext,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            label: FittedBox(child: Text(label)),
            prefixIcon: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.03),
                  child: Image.asset(icon, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

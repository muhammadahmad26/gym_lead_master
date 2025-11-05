import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    return Material(
      color: AppColors.themeBlueColor,
      borderRadius: BorderRadius.all(Radius.circular(14)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: width * 0.80,
          height: height * 0.06,
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  text,
                  style: GoogleFonts.lexendDeca(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/widgets/customTextFormField.dart';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  LoginPage({super.key});

  static const appLogoIcon = 'assets/images/app_main_logo.png';
  static const emailIcon = 'assets/images/email.png';
  static const keyIcon = 'assets/images/key.png';
  static const userIcon = 'assets/images/user.png';

  @override
  Widget build(BuildContext context) {
    final Size(:width, :height) = MediaQuery.sizeOf(context);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset(appLogoIcon,height: 100,width: 100,),
            SizedBox(height: height * 0.03,),
            CustomTextFormField(icon: userIcon , label: "Admin Name")
            
          ],
        )),
    );
  }
}

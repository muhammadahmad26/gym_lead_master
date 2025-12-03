import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';
import 'package:gym_lead_master/src/core/utils/email_validator.dart';
import 'package:gym_lead_master/src/core/widgets/bottom_navigationbar_clipper.dart';
import 'package:gym_lead_master/src/core/widgets/build_bottom_navigation_button.dart';
import 'package:gym_lead_master/src/core/widgets/custom_textForm_field.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final bool isAdmin;
  final Function(int) onItemSelected;
  CustomBottomNavigationBar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    this.isAdmin = false,
  });
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add member '),
          content: SingleChildScrollView(
            child: Form(
              key: globalKey,
              child: ListBody(
                children: <Widget>[
                  const SizedBox(height: 5),
                  CustomTextFormField(
                    icon_asset: AppImages.emailIcon,
                    label: 'Email',
                    validator: (value) => EmailValidator.validator(value),
                  ),
                  const SizedBox(height: 5),
                  const CustomTextFormField(
                    icon_asset: AppImages.userIcon,
                    label: 'Name',
                  ),
                  //button
                  const SizedBox(height: 5),
                  const CustomTextFormField(
                    icon_asset: AppImages.genderIcon,
                    label: 'Gender',
                  ),
                  //button
                  const SizedBox(height: 5),
                  const CustomTextFormField(
                    icon_asset: AppImages.feeIcon,
                    label: 'fee',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (globalKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteColor,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 70,
              child: ClipPath(
                clipper: BottomNavigationbarClipper(),
                child: Container(
                  color: AppColors.navBarColor,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: BuildBottomNavigationButton(
                            selectedIndex: selectedIndex,
                            onItemSelected: onItemSelected,
                            index: 0,
                            icon: Icons.home_outlined,
                            label: "Home",
                            defaultColor: AppColors.grayColor,
                            selectedColor: AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: BuildBottomNavigationButton(
                            selectedIndex: selectedIndex,
                            onItemSelected: onItemSelected,
                            index: 1,
                            icon: Icons.payment_outlined,
                            label: 'Pyments',
                            defaultColor: AppColors.grayColor,
                            selectedColor: AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: BuildBottomNavigationButton(
                            selectedIndex: selectedIndex,
                            onItemSelected: onItemSelected,

                            index: 2,
                            icon: Icons.message_outlined,
                            label: 'Message',
                            defaultColor: AppColors.grayColor,
                            selectedColor: AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: BuildBottomNavigationButton(
                            selectedIndex: selectedIndex,
                            onItemSelected: onItemSelected,
                            index: 3,
                            icon: Icons.person_outline,
                            label: "Profile",
                            defaultColor: AppColors.grayColor,
                            selectedColor: AppColors.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isAdmin)
            Positioned(
              bottom: 50,
              child: GestureDetector(
                onTap: () {
                  _showMyDialog(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 122, 130, 155),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(AppImages.addUser),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/widgets/bottom_navigationbar_clipper.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  const CustomBottomNavigationBar({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color defaultColor,
    Color selectedColor,
  ) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : defaultColor,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : defaultColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
            // top: 0,
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
                          child: _buildNavItem(
                            0,
                            Icons.home_outlined,
                            "Home",
                            AppColors.grayColor,
                            AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            1,
                            Icons.payment_outlined,
                            'Pyments',
                            AppColors.grayColor,
                            AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            2,
                            Icons.message_outlined,
                            'Message',
                            AppColors.grayColor,
                            AppColors.blueColor,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            3,
                            Icons.person_outline,
                            "Profile",
                            AppColors.grayColor,
                            AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
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

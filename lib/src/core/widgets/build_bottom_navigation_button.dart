import 'package:flutter/material.dart';

class BuildBottomNavigationButton extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final Color defaultColor;
  final Color selectedColor;
  final int selectedIndex;
  final Function(int) onItemSelected;
  const BuildBottomNavigationButton({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.index,
    required this.icon,
    required this.label,
    required this.defaultColor,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
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
}

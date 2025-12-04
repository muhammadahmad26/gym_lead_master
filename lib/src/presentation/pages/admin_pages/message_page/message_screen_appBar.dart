import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/core/constants/app_images.dart';

class MessageScreenBar extends StatelessWidget {
  const MessageScreenBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 58, 67, 94),
      title: Padding(
        padding: EdgeInsets.only(top: 5),
        child: Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "J",
                    style: TextStyle(
                      color: Color(0xFFFFEB3B),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "Y",
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "M",
                    style: TextStyle(
                      color: Color(0xFF80FFB0),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: " Messages",
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, size: 28, color: AppColors.whiteColor),
            ),
            SizedBox(width: 15),
            CircleAvatar(
              radius: 25,
              child: Image.asset(AppImages.userIcon, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }
}

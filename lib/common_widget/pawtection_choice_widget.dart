import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class PawtectionChoiceWidget extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onpressed;
  const PawtectionChoiceWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onpressed();
      },
      child: Container(
        width: 90,
        height: 82,
        decoration: BoxDecoration(),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional(1, 1),
              child: Container(
                width: 85,
                height: 68,
                decoration: BoxDecoration(
                  color: TColor.mediumTaupe,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TColor.white,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(-1, -1),
              child: Image.asset(icon, width: 40, height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class RoundButton extends StatelessWidget {
  final VoidCallback onpressed;
  final String title;
  const RoundButton({super.key, required this.title, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.columbiaBlue,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: TColor.black,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: MaterialButton(
          onPressed: onpressed,
          height: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textColor: TColor.black,

          minWidth: double.maxFinite,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 32,
              fontFamily: "ComicNeue",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

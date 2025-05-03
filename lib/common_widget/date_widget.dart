import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class DateWidget extends StatelessWidget {
  final String date;
  final String day;
  const DateWidget({super.key, required this.date, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 57,
      height: 80,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: TextStyle(
              fontFamily: "ComicNeue",
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(day, style: TextStyle(fontFamily: "ComicNeue", fontSize: 12)),
        ],
      ),
    );
  }
}

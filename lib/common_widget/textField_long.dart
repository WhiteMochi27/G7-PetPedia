import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class TextfieldLong extends StatelessWidget {
  final IconData icon;
  final String name;
  const TextfieldLong({super.key, required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: name,
          hintStyle: TextStyle(fontFamily: "ComicNeue", fontSize: 20),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TColor.black, width: 1),

            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TColor.black, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),

          filled: true,
          fillColor: TColor.white,
          prefixIcon: Icon(icon, size: 25, color: TColor.gray),
        ),
      ),
    );
  }
}

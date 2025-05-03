import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class PawtectionActivityWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String dateTime;
  final String location;
  final VoidCallback ontap;
  const PawtectionActivityWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          width: media.width,
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    icon,
                    color: TColor.black,
                    width: 32,
                    height: 32,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.schedule, size: 18),
                        SizedBox(width: 5),
                        Text(
                          dateTime,
                          style: TextStyle(
                            fontFamily: "ComicNeue",
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.map_outlined, size: 18),
                        SizedBox(width: 5),
                        Text(
                          location,
                          style: TextStyle(
                            fontFamily: "ComicNeue",
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

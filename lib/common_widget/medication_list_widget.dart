import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class MedicationListWidget extends StatelessWidget {
  final String icon;
  final String dose;
  final String name;
  final String time;
  final bool isChecked;
  final ValueChanged<bool?> onCheckboxChanged;

  const MedicationListWidget({
    super.key,
    required this.icon,
    required this.dose,
    required this.name,
    required this.time,
    required this.isChecked,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        width: media.width,
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Image.asset(icon, width: 30, height: 30),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dose,
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(Icons.notifications_none, size: 20),
                          SizedBox(width: 5),
                          Text(
                            time,
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Checkbox(
                value: isChecked,
                onChanged: onCheckboxChanged,
                side: BorderSide(width: 2, color: TColor.black),
                activeColor: TColor.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

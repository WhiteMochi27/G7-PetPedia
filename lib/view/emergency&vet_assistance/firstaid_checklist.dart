//Contributed by: Alicia Chua Xiu Wen
import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/database/database_handler.dart'; // adjust if needed

class FirstaidChecklist extends StatefulWidget {
  const FirstaidChecklist({super.key});

  @override
  State<FirstaidChecklist> createState() => _FirstaidChecklistState();
}

// Data model for first aid item
class FirstAidData {
  final int id;
  final String title;
  bool status;

  FirstAidData({required this.id, required this.title, required this.status});

  factory FirstAidData.fromMap(Map<String, dynamic> map) {
    return FirstAidData(
      id: map['firstaid_id'],
      title: map['firstaid_title'],
      status: map['firstaid_status'] == 1,
    );
  }
}

// UI component for checkbox
class FirstAidItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const FirstAidItem({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          side: BorderSide(width: 2, color: TColor.black),
          activeColor: TColor.gray,
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: "Fredoka",
              fontSize: 14,
              decoration:
                  value ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _FirstaidChecklistState extends State<FirstaidChecklist> {
  List<FirstAidData> _firstAidList = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<FirstAidData> _filteredFirstAidList = [];

  @override
  void initState() {
    super.initState();
    _loadFirstAidItems();
  }

  Future<void> _loadFirstAidItems() async {
    try {
      final db = await DatabaseHandler().database;

      // Check if the table exists
      var tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='firstaid'",
      );

      if (tables.isEmpty) {
        print("FIRSTAID TABLE DOES NOT EXIST!");
        setState(() {
          _isLoading = false;
          _firstAidList = [];
          _filteredFirstAidList = [];
        });
        return;
      }

      // Now it's safe to query the data
      final List<Map<String, dynamic>> result = await db.query('firstaid');

      final items = result.map((item) => FirstAidData.fromMap(item)).toList();

      setState(() {
        _firstAidList = items;
        _filteredFirstAidList = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading first aid items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFirstAidList = _firstAidList;
      });
      return;
    }

    List<FirstAidData> filtered =
        _firstAidList
            .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _filteredFirstAidList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header area with background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_content.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 36),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 0, 30),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 24),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              "assets/images/icon_back.png",
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                        Text(
                          "First-Aid Checklist",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Baloo",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search bar
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: TColor.white,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSearchResults,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search for a first aid item',
                        hintStyle: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: TColor.gray,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: TColor.gray,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        fillColor: TColor.white,
                        prefixIcon: Icon(Icons.search, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List area - this Expanded makes the ListView take the remaining space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        // Remove shrinkWrap: true to allow proper scrolling
                        padding: EdgeInsets.all(20),
                        itemCount: _filteredFirstAidList.length,
                        itemBuilder: (context, index) {
                          final item = _filteredFirstAidList[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: FirstAidItem(
                              label: item.title,
                              value: item.status,
                              onChanged: (bool? newValue) async {
                                setState(() {
                                  item.status = newValue ?? false;
                                });

                                final db = await DatabaseHandler().database;
                                await db.update(
                                  'firstaid',
                                  {'firstaid_status': item.status ? 1 : 0},
                                  where: 'firstaid_id = ?',
                                  whereArgs: [item.id],
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

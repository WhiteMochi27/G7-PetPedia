//Contributed by: Alicia Chua Xiu Wen
import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/database/database_handler.dart'; // Make sure this path is correct

class FurllergicView extends StatefulWidget {
  final int petId;

  const FurllergicView({super.key, required this.petId});

  @override
  State<FurllergicView> createState() => _FurllergicViewState();
}

class _FurllergicViewState extends State<FurllergicView> {
  final DatabaseHandler _databaseHandler = DatabaseHandler();
  List<Map<String, dynamic>> _allergicList = [];
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergicData();
  }

  Future<void> _loadAllergicData() async {
    setState(() {
      _isLoading = true;
    });

    final allergicData = await _databaseHandler.getAllergicsForPet(
      widget.petId,
    );

    setState(() {
      _allergicList = allergicData;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredAllergicList() {
    if (_searchQuery.isEmpty) {
      return _allergicList;
    }

    return _allergicList.where((allergic) {
      final allergyName = allergic['allergic_name'].toString().toLowerCase();
      final reaction = allergic['allergic_reaction'].toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();

      return allergyName.contains(searchLower) ||
          reaction.contains(searchLower);
    }).toList();
  }

  Future<void> _deleteAllergic(int allergicId) async {
    // Show confirmation dialog
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Confirm Deletion',
                  style: TextStyle(
                    fontFamily: "Baloo",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete this allergy record?',
                  style: TextStyle(fontFamily: "ComicNeue"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: TColor.gray)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: TColor.error),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      await _databaseHandler.deleteAllergic(allergicId);
      _loadAllergicData(); // Refresh the list
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Allergy record deleted')));
    }
  }

  Future<void> _showAddAllergicDialog() async {
    final TextEditingController _allergyNameController =
        TextEditingController();
    final TextEditingController _allergyReactionController =
        TextEditingController();
    DateTime _selectedDate = DateTime.now();

    // Change showDialog to showModalBottomSheet for better keyboard handling
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard resize
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            // Add this to ensure bottom inset is respected
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Allergy',
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Date picker field
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _selectedDate = picked;
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Onset Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.day.toString().padLeft(2, '0')}-"
                            "${_selectedDate.month.toString().padLeft(2, '0')}-"
                            "${_selectedDate.year}",
                            style: TextStyle(fontFamily: "ComicNeue"),
                          ),
                          Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Allergy name field
                  TextField(
                    controller: _allergyNameController,
                    decoration: InputDecoration(
                      labelText: 'Allergy Name',
                      hintText: 'e.g., Pollen, Dairy, etc.',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontFamily: "ComicNeue"),
                  ),
                  SizedBox(height: 16),
                  // Reaction field
                  TextField(
                    controller: _allergyReactionController,
                    decoration: InputDecoration(
                      labelText: 'Reaction',
                      hintText: 'e.g., Itching, sneezing, etc.',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontFamily: "ComicNeue"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: TColor.black),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          if (_allergyNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter an allergy name'),
                              ),
                            );
                            return;
                          }

                          final newAllergic = {
                            'pet_id': widget.petId,
                            'allergic_datetime':
                                "${_selectedDate.day.toString().padLeft(2, '0')}-"
                                "${_selectedDate.month.toString().padLeft(2, '0')}-"
                                "${_selectedDate.year}",
                            'allergic_name': _allergyNameController.text.trim(),
                            'allergic_reaction':
                                _allergyReactionController.text.trim(),
                          };

                          await _databaseHandler.insertAllergic(newAllergic);
                          Navigator.pop(context);
                          _loadAllergicData(); // Refresh the list
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Allergy added successfully'),
                            ),
                          );
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(color: TColor.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showEditAllergicDialog(Map<String, dynamic> allergic) async {
    final TextEditingController _allergyNameController = TextEditingController(
      text: allergic['allergic_name'],
    );
    final TextEditingController _allergyReactionController =
        TextEditingController(text: allergic['allergic_reaction']);

    // Parse the date string in format DD-MM-YYYY
    final dateParts = allergic['allergic_datetime'].split('-');
    DateTime _selectedDate = DateTime(
      int.parse(dateParts[2]), // Year
      int.parse(dateParts[1]), // Month
      int.parse(dateParts[0]), // Day
    );

    // Use showModalBottomSheet instead of showDialog
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Allergy',
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Date picker field
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _selectedDate = picked;
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Onset Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedDate.day.toString().padLeft(2, '0')}-"
                            "${_selectedDate.month.toString().padLeft(2, '0')}-"
                            "${_selectedDate.year}",
                            style: TextStyle(fontFamily: "ComicNeue"),
                          ),
                          Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Allergy name field
                  TextField(
                    controller: _allergyNameController,
                    decoration: InputDecoration(
                      labelText: 'Allergy Name',
                      hintText: 'e.g., Pollen, Dairy, etc.',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontFamily: "ComicNeue"),
                  ),
                  SizedBox(height: 16),
                  // Reaction field
                  TextField(
                    controller: _allergyReactionController,
                    decoration: InputDecoration(
                      labelText: 'Reaction',
                      hintText: 'e.g., Itching, sneezing, etc.',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontFamily: "ComicNeue"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: TColor.gray),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          if (_allergyNameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter an allergy name'),
                              ),
                            );
                            return;
                          }

                          final updatedAllergic = {
                            'pet_id': allergic['pet_id'],
                            'allergic_datetime':
                                "${_selectedDate.day.toString().padLeft(2, '0')}-"
                                "${_selectedDate.month.toString().padLeft(2, '0')}-"
                                "${_selectedDate.year}",
                            'allergic_name': _allergyNameController.text.trim(),
                            'allergic_reaction':
                                _allergyReactionController.text.trim(),
                          };

                          await _databaseHandler.updateAllergic(
                            updatedAllergic,
                            allergic['allergic_id'],
                          );
                          Navigator.pop(context);
                          _loadAllergicData(); // Refresh the list
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Allergy updated successfully'),
                            ),
                          );
                        },
                        child: Text(
                          'Update',
                          style: TextStyle(color: TColor.pinkFlare),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    TableRow buildHeaderRow(List<String> cells) => TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: TColor.gray, width: 1)),
      ),
      children:
          cells.map((cell) {
            final style = TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Fredoka One",
              fontSize: 14,
            );

            return Padding(
              padding: const EdgeInsets.all(10),
              child: Text(cell, style: style),
            );
          }).toList(),
    );

    TableRow buildDataRow(Map<String, dynamic> allergic) => TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: TColor.gray, width: 0.5)),
      ),
      children: [
        // Onset date
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            allergic['allergic_datetime'] ?? '',
            style: TextStyle(fontFamily: "ComicNeue", fontSize: 14),
          ),
        ),
        // Allergy name
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            allergic['allergic_name'] ?? '',
            style: TextStyle(fontFamily: "ComicNeue", fontSize: 14),
          ),
        ),
        // Actions + Reaction
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  allergic['allergic_reaction'] ?? '',
                  style: TextStyle(fontFamily: "ComicNeue", fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: TColor.jellyfish),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => _showEditAllergicDialog(allergic),
                  ),
                  SizedBox(width: 4),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: TColor.error),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => _deleteAllergic(allergic['allergic_id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
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
                          mainAxisSize: MainAxisSize.max,
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
                              "Fur-llergic",
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: "Baloo",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: AlignmentDirectional(0, -1),
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(width: media.width, height: 25),
                              Container(
                                width: media.width,
                                height:
                                    media.height -
                                    150, // Adjust for the app bar height
                                decoration: BoxDecoration(
                                  color: Color(0xFFFef7ff),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                alignment: AlignmentDirectional(-1, -1),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 60,
                                      ), // Space for search bar
                                      _isLoading
                                          ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                          : _getFilteredAllergicList().isEmpty
                                          ? Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 50),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.pets,
                                                    size: 60,
                                                    color: TColor.gray,
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    _searchQuery.isEmpty
                                                        ? "No allergies recorded yet."
                                                        : "No matching allergies found.",
                                                    style: TextStyle(
                                                      fontFamily: "ComicNeue",
                                                      fontSize: 16,
                                                      color: TColor.gray,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    _searchQuery.isEmpty
                                                        ? "Tap + to add your pet's allergies."
                                                        : "Try a different search term.",
                                                    style: TextStyle(
                                                      fontFamily: "ComicNeue",
                                                      fontSize: 14,
                                                      color: TColor.gray,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          : Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Table(
                                                columnWidths: const {
                                                  0: FlexColumnWidth(2), // Date
                                                  1: FlexColumnWidth(
                                                    2,
                                                  ), // Allergy name
                                                  2: FlexColumnWidth(
                                                    4,
                                                  ), // Reaction + actions
                                                },
                                                defaultVerticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                children: [
                                                  buildHeaderRow([
                                                    'Onset',
                                                    'Allergy',
                                                    'Reaction',
                                                  ]),
                                                  ..._getFilteredAllergicList()
                                                      .map(buildDataRow)
                                                      .toList(),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: media.width * 0.8,
                            height: 50,
                            decoration: BoxDecoration(
                              color: TColor.white,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x33000000),
                                  offset: Offset(0.0, 2.0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: TColor.black,
                                width: 0.3,
                              ),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: TColor.gray,
                                  size: 20,
                                ),
                                hintText: "Search by allergens or reaction",
                                hintStyle: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _showAddAllergicDialog,
              backgroundColor: TColor.pinkFlare,
              icon: Icon(Icons.add, color: TColor.black, size: 30),
              label: Text(
                "Add Allergies",
                style: TextStyle(
                  fontFamily: "ComicNeue",
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: TColor.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

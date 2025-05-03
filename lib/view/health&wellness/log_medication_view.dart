import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/database/database_handler.dart';

class MedicationListWidget extends StatelessWidget {
  final String dose;
  final String name;
  final String time;
  final int medicationId;
  final VoidCallback onDelete;

  const MedicationListWidget({
    super.key,
    required this.dose,
    required this.name,
    required this.time,
    required this.medicationId,
    required this.onDelete,
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
                    child: Image.asset(
                      "assets/images/icon_fursona.png",
                      width: 30,
                      height: 30,
                    ),
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
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: TColor.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogMedicationView extends StatefulWidget {
  final int petId;

  const LogMedicationView({super.key, required this.petId});

  @override
  State<LogMedicationView> createState() => _LogMedicationViewState();
}

class _LogMedicationViewState extends State<LogMedicationView> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> medications = await _dbHandler
        .getMedicationsForPet(widget.petId);

    setState(() {
      _medications = medications;
      _isLoading = false;
    });
  }

  // Helper function to get medications based on category
  List<Map<String, dynamic>> _getMedicationsByCategory(String category) {
    return _medications
        .where((med) => med['medication_cat'] == category)
        .toList();
  }

  // Delete medication
  Future<void> _deleteMedication(int medicationId) async {
    await _dbHandler.deleteMedication(medicationId);
    _loadMedications();
  }

  // Show dialog to add new medication
  void _showAddMedicationDialog() {
    String name = '';
    String dose = '';
    TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);
    String formattedTime = '08:00';
    String category = 'morning';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Medication',
                style: TextStyle(fontFamily: "FredokaOne", fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Medication Name',
                        hintText: 'Amoxicillin (250mg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Dosage Instructions',
                        hintText: '1 tablet, after meal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onChanged: (value) {
                        dose = value;
                      },
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                            formattedTime =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(color: TColor.gray),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Time: $formattedTime'),
                            Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      value: category,
                      items: [
                        DropdownMenuItem(
                          value: 'morning',
                          child: Text('Morning'),
                        ),
                        DropdownMenuItem(
                          value: 'afternoon',
                          child: Text('Afternoon'),
                        ),
                        DropdownMenuItem(value: 'night', child: Text('Night')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.orangePeel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text('Add'),
                  onPressed: () async {
                    try {
                      if (name.isNotEmpty && dose.isNotEmpty) {
                        Map<String, dynamic> medication = {
                          'pet_id': widget.petId,
                          'medication_name': name,
                          'medication_dose': dose,
                          'medication_datetime': formattedTime,
                          'medication_status':
                              0, // Kept for database compatibility
                          'medication_cat': category,
                        };

                        print("Adding medication: $medication"); // Debug print

                        int result = await _dbHandler.insertMedication(
                          medication,
                        );
                        print("Insert result: $result"); // Debug print

                        Navigator.of(context).pop();
                        _loadMedications();
                      } else {
                        // Show an error message if fields are empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: TColor.error,
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error adding medication: $e"); // Debug print
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error adding medication: $e'),
                          backgroundColor: TColor.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build medication section
  Widget _buildMedicationSection(
    String title,
    String category,
    String iconPath,
  ) {
    List<Map<String, dynamic>> medications = _getMedicationsByCategory(
      category,
    );

    if (medications.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, width: 45, height: 45, fit: BoxFit.cover),
              SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "ComicNeue",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...medications.map((medication) {
          return MedicationListWidget(
            dose: medication['medication_dose'],
            name: medication['medication_name'],
            time: medication['medication_datetime'],
            medicationId: medication['medication_id'],
            onDelete: () {
              _deleteMedication(medication['medication_id']);
            },
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // First layer: full-height background image

                  // Background image container
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/background_content.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Content
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header container
                        Container(
                          width: media.width,
                          decoration: BoxDecoration(
                            color: TColor.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: TColor.gray,
                                offset: Offset(10, 10),
                              ),
                            ],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 36, 20, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 24,
                                              ),
                                              child: Image.asset(
                                                "assets/images/icon_back.png",
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Log Medications",
                                            style: TextStyle(
                                              fontFamily: "FredokaOne",
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        15,
                                        15,
                                      ),
                                      child: GestureDetector(
                                        onTap: _showAddMedicationDialog,
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: TColor.lightBlueGray,
                                            borderRadius: BorderRadius.circular(
                                              19,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: TColor.black,
                                            size: 35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Medication content container - maintaining the background image
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - 150,
                          ),
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child:
                              _medications.isEmpty
                                  ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 50),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/images/2.png",
                                            width: 200,
                                            height: 200,
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            "No medications added yet",
                                            style: TextStyle(
                                              fontFamily: "ComicNeue",
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Add medications by tapping the + button",
                                            style: TextStyle(
                                              fontFamily: "ComicNeue",
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 40),
                                        ],
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children: [
                                      _buildMedicationSection(
                                        "Morning",
                                        "morning",
                                        "assets/images/log_morning.png",
                                      ),
                                      _buildMedicationSection(
                                        "Afternoon",
                                        "afternoon",
                                        "assets/images/log_afternoon.png",
                                      ),
                                      _buildMedicationSection(
                                        "Night",
                                        "night",
                                        "assets/images/log_morning.png", // Update with night icon when available
                                      ),
                                      SizedBox(height: 40),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

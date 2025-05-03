//Contributed by: Alicia Chua Xiu Wen
import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:intl/intl.dart';
import 'package:petpedia/database/database_handler.dart';

class AddReminderView extends StatefulWidget {
  final int petId; // Added parameter for pet ID

  const AddReminderView({Key? key, required this.petId}) : super(key: key);

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHandler _dbHandler = DatabaseHandler();

  // Form fields
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _activityNameController =
      TextEditingController(); // New controller for activity name
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(Duration(hours: 1));
  String _selectedCategory = 'Appointment'; // Default category
  List<String> _categories = [
    'Appointment',
    'Vaccination',
    'Deworming',
    'Grooming',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _categoryController.text = _selectedCategory;
    _updateDateTimeText();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _activityNameController.dispose(); // Dispose new controller
    _dateTimeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDateTimeText() {
    _dateTimeController.text = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(_selectedDateTime);
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updateDateTimeText();
        });
      }
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      // Create reminder map
      final Map<String, dynamic> reminder = {
        'pet_id': widget.petId,
        'reminder_datetime': _selectedDateTime.toIso8601String(),
        'reminder_location': _locationController.text,
        'reminder_cat': _selectedCategory,
        'reminder_desc': _descriptionController.text,
        'activity_name':
            _activityNameController.text, // Add activity name to the map
      };

      try {
        // Insert reminder into database
        final reminderId = await _dbHandler.insertReminder(reminder);

        if (reminderId > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reminder added successfully!')),
          );
          // Return true to indicate success
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add reminder. Please try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        "assets/images/icon_back.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add Reminder",
                          style: TextStyle(
                            fontFamily: "Baloo",
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          "Create a new reminder for your pet",
                          style: TextStyle(
                            fontFamily: "Fredoka",
                            fontSize: 14,
                            color: TColor.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Details',
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Activity Name - New field
                      TextFormField(
                        controller: _activityNameController,
                        decoration: InputDecoration(
                          labelText: 'Activity Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an activity name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        value: _selectedCategory,
                        items:
                            _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Date and Time
                      TextFormField(
                        controller: _dateTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Activity Date & Time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () => _selectDateTime(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select date and time';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saveReminder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.orangePeel,
                            foregroundColor: TColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save Reminder',
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Contributed by: Alicia Chua Xiu Wen
import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:intl/intl.dart';

class ReminderDetailsView extends StatefulWidget {
  final int reminderId;

  const ReminderDetailsView({Key? key, required this.reminderId})
    : super(key: key);

  @override
  State<ReminderDetailsView> createState() => _ReminderDetailsViewState();
}

class _ReminderDetailsViewState extends State<ReminderDetailsView> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  Map<String, dynamic>? _reminderData;
  bool _isLoading = true;
  bool _isEditing = false;

  // Controllers for editing
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String _selectedCategory = 'Appointment';

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
    _loadReminderData();
  }

  Future<void> _loadReminderData() async {
    try {
      // This method needs to be implemented in DatabaseHandler
      // It should fetch a reminder by ID
      Map<String, dynamic>? reminderData = await _dbHandler.getReminderById(
        widget.reminderId,
      );

      if (reminderData != null) {
        setState(() {
          _reminderData = reminderData;
          _isLoading = false;

          // Set initial values for controllers
          _activityNameController.text = reminderData['activity_name'] ?? '';
          _categoryController.text = reminderData['reminder_cat'] ?? '';
          _selectedCategory = reminderData['reminder_cat'] ?? 'Appointment';
          _locationController.text = reminderData['reminder_location'] ?? '';
          _descriptionController.text = reminderData['reminder_desc'] ?? '';

          // Parse the datetime
          try {
            _selectedDateTime = DateTime.parse(
              reminderData['reminder_datetime'],
            );
            _updateDateTimeText();
          } catch (e) {
            print('Error parsing date: $e');
          }
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Reminder not found')));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error loading reminder: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading reminder: $e')));
      Navigator.pop(context);
    }
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

  Future<void> _updateReminder() async {
    if (_reminderData == null) return;

    // Create updated reminder map
    final Map<String, dynamic> updatedReminder = {
      'pet_id': _reminderData!['pet_id'],
      'reminder_datetime': _selectedDateTime.toIso8601String(),
      'reminder_location': _locationController.text,
      'reminder_cat': _selectedCategory,
      'reminder_desc': _descriptionController.text,
      'activity_name': _activityNameController.text,
    };

    try {
      // Update reminder in database
      final result = await _dbHandler.updateReminder(
        updatedReminder,
        widget.reminderId,
      );

      if (result > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder updated successfully!')),
        );
        setState(() {
          _isEditing = false;
          _reminderData = {..._reminderData!, ...updatedReminder};
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update reminder')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deleteReminder() async {
    try {
      // Show confirmation dialog
      bool confirm =
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Delete Reminder'),
                  content: Text(
                    'Are you sure you want to delete this reminder?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (confirm) {
        final result = await _dbHandler.deleteReminder(widget.reminderId);

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reminder deleted successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete reminder')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 0, 0),
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
                  Text(
                    "Reminder Details",
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              _isEditing
                                  ? _buildEditingForm()
                                  : _buildViewingForm(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.gray,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: TColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _updateReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.orangePeel,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: TColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _deleteReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.error,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: TColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.orangePeel,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: TColor.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  List<Widget> _buildViewingForm() {
    return [
      // Display activity name section
      _buildInfoSection(
        'Activity Name',
        _reminderData?['activity_name'] ?? 'No activity name',
        Icons.pets,
      ),

      // Category
      _buildInfoSection(
        'Category',
        _reminderData?['reminder_cat'] ?? 'Unknown',
        Icons.category,
      ),

      // Date and Time
      _buildInfoSection(
        'Date & Time',
        _formatDateTime(_reminderData?['reminder_datetime'] ?? ''),
        Icons.calendar_today,
      ),

      // Location
      _buildInfoSection(
        'Location',
        _reminderData?['reminder_location'] ?? 'No location specified',
        Icons.location_on,
      ),

      // Description
      _buildInfoSection(
        'Description',
        _reminderData?['reminder_desc'] ?? 'No description',
        Icons.description,
      ),
    ];
  }

  List<Widget> _buildEditingForm() {
    return [
      // Activity Name - Edit field
      TextFormField(
        controller: _activityNameController,
        decoration: InputDecoration(
          labelText: 'Activity Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      ),
      SizedBox(height: 15),

      // Date and Time
      TextFormField(
        controller: _dateTimeController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Activity Date & Time',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.calendar_today),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        onTap: () => _selectDateTime(context),
      ),
      SizedBox(height: 15),

      // Location
      TextFormField(
        controller: _locationController,
        decoration: InputDecoration(
          labelText: 'Location (Optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.location_on),
        ),
      ),
      SizedBox(height: 15),

      // Description
      TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Description (Optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.description),
          alignLabelWithHint: true,
        ),
        maxLines: 3,
      ),
      SizedBox(height: 15),
    ];
  }

  Widget _buildInfoSection(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: "ComicNeue",
              fontSize: 14,
              color: TColor.gray,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: TColor.black, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: "ComicNeue",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr; // Return as is if parsing fails
    }
  }
}

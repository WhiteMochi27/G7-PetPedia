import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/common_widget/pawtection_activity_widget.dart';
import 'package:petpedia/common_widget/pawtection_choice_widget.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/view/health&wellness/add_reminder_view.dart';
import 'package:petpedia/view/health&wellness/furllergic_view.dart';
import 'package:petpedia/view/health&wellness/log_medication_view.dart';
import 'package:petpedia/view/health&wellness/reminder_details_view.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PawtectionView extends StatefulWidget {
  const PawtectionView({super.key});

  @override
  State<PawtectionView> createState() => _PawtectionViewState();
}

class _PawtectionViewState extends State<PawtectionView> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  int _currentPetId = 1; // Default to first pet
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _reminders = [];
  String _selectedFilter = "All"; // Track selected filter
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load pets and reminders data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Get all pets from pet_profile table
    final pets = await _dbHandler.getAllPetProfiles();

    setState(() {
      _pets = pets;
      _isLoading = false;
    });

    if (pets.isNotEmpty) {
      setState(() {
        _currentPetId =
            pets.first['pet_id']; // Use pet_id from pet_profile table
      });

      // Load reminders for current pet
      await _loadReminders();
    }
  }

  // Load reminders for current pet
  Future<void> _loadReminders() async {
    final reminders = await _dbHandler.getRemindersForPet(_currentPetId);
    setState(() {
      _reminders = reminders;
    });
  }

  // Switch to next pet
  void _switchPet() async {
    if (_pets.isEmpty) return;

    // Find index of current pet
    int currentIndex = _pets.indexWhere(
      (pet) => pet['pet_id'] == _currentPetId,
    );
    // Calculate next index (wrap around if at the end)
    int nextIndex = (currentIndex + 1) % _pets.length;

    setState(() {
      _currentPetId = _pets[nextIndex]['pet_id'];
    });

    // Load reminders for new pet
    await _loadReminders();
  }

  // Filter reminders by category
  List<Map<String, dynamic>> _getFilteredReminders() {
    if (_selectedFilter == "All") {
      return _reminders;
    } else {
      return _reminders
          .where((reminder) => reminder['reminder_cat'] == _selectedFilter)
          .toList();
    }
  }

  // Format datetime string from ISO format to readable format
  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return "${DateFormat('h:mm a').format(dateTime)}, ${DateFormat('d MMMM').format(dateTime)}";
    } catch (e) {
      return dateTimeStr; // Return as is if parsing fails
    }
  }

  // Get current pet name
  String _getCurrentPetName() {
    if (_pets.isEmpty) return "No Pet";

    final currentPet = _pets.firstWhere(
      (pet) => pet['pet_id'] == _currentPetId,
      orElse: () => {"name": "Unknown"},
    );

    return currentPet['name'] ?? "Unknown";
  }

  // Get current pet avatar URL
  String _getCurrentPetAvatarUrl() {
    if (_pets.isEmpty)
      return "assets/images/Pet profile pic/8.png"; // Default image

    final currentPet = _pets.firstWhere(
      (pet) => pet['pet_id'] == _currentPetId,
      orElse: () => {"avatar_url": "assets/images/Pet profile pic/8.png"},
    );

    return currentPet['avatar_url'] ?? "assets/images/Pet profile pic/8.png";
  }

  // Build the pet avatar widget
  Widget _buildPetAvatar() {
    String avatarUrl = _getCurrentPetAvatarUrl();

    // For debugging
    print("Pet avatar URL: $avatarUrl");

    // Check if the avatar URL is a file path or an asset path
    if (avatarUrl.startsWith('assets/')) {
      // It's an asset image
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset(
          avatarUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // It's a file path - could be absolute path or content:// URI
      final file = File(avatarUrl);
      try {
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.file(
              file,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image: $error");
                // Fallback to default image on error
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "assets/images/Pet profile pic/8.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          );
        } else {
          print("File does not exist: $avatarUrl");
          // Fallback to default image if file doesn't exist
          return ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              "assets/images/Pet profile pic/8.png",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (e) {
        print("Exception checking file: $e");
        // Fallback to default image if there's an exception
        return ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            "assets/images/Pet profile pic/8.png",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    // Show loading indicator while data is being fetched
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show empty state if no pets found
    if (_pets.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            // Full screen background with content
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_content.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                bottom:
                    false, // Important - don't add padding at bottom for safe area
                child: Column(
                  children: [
                    // Title - positioned at the very top with proper padding
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: PageTitle(
                        icon: "assets/images/icon_pawtection.png",
                        title: "Pawtection",
                        subtitle: 'Health & Wellness Tracking',
                      ),
                    ),

                    // Expanded to push content to center
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Empty state illustration
                            Image.asset(
                              "assets/images/Pet profile pic/8.png",
                              width: 180,
                              height: 180,
                            ),
                            SizedBox(height: 20),

                            // Message
                            Text(
                              "No Pets Found",
                              style: TextStyle(
                                fontFamily: "Baloo",
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                "Please add a pet first to use the Pawtection features",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  color: TColor.gray,
                                ),
                              ),
                            ),
                            SizedBox(height: 30),

                            // Button to go back
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.orangePeel,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                "Go Back & Add Pet",
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Space for the home button - IMPORTANT
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Home button positioned at the bottom
            Positioned(bottom: 0, left: 0, right: 0, child: const HomeButton()),
          ],
        ),
        // IMPORTANT: This ensures content goes behind the home button
        extendBody: true,
      );
    }

    // Show normal view if pets exist
    return Scaffold(
      // IMPORTANT: This ensures content goes behind the home button
      extendBody: true,
      body: Stack(
        children: [
          // Background container
          Container(
            // Make container full height to avoid white space
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_content.png'),
                fit: BoxFit.cover,
              ),
            ),
            // Use a Column with Expanded to ensure full height coverage
            child: Column(
              children: [
                // Use SafeArea for top content only
                SafeArea(
                  bottom: false, // Important: no bottom padding
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 0, 0),
                    child: PageTitle(
                      icon: "assets/images/icon_pawtection.png",
                      title: "Pawtection",
                      subtitle: 'Health & Wellness Tracking',
                    ),
                  ),
                ),

                // Pet profile section
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _switchPet,
                        child: Column(
                          children: [
                            _buildPetAvatar(),
                            SizedBox(height: 8),
                            Text(
                              _getCurrentPetName(),
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Tap to switch pet",
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 12,
                                color: TColor.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Use Expanded for the content to push it to fill remaining space
                Expanded(
                  child: SingleChildScrollView(
                    // No bottom padding needed since we want content to extend behind home button
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Features section
                        Container(
                          width: media.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            color: TColor.white,
                          ),
                          alignment: AlignmentDirectional(0, -1),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PawtectionChoiceWidget(
                                  icon: "assets/images/icon_add_reminder.png",
                                  title: "Add Reminder",
                                  onpressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddReminderView(
                                              petId: _currentPetId,
                                            ),
                                      ),
                                    );

                                    if (result == true) {
                                      _loadReminders();
                                    }
                                  },
                                ),
                                SizedBox(width: 15),
                                PawtectionChoiceWidget(
                                  icon: "assets/images/icon_furllergic.png",
                                  title: "Fur-llergic",
                                  onpressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FurllergicView(
                                              petId: _currentPetId,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 15),
                                PawtectionChoiceWidget(
                                  icon: "assets/images/icon_log_medication.png",
                                  title: "Log Medication",
                                  onpressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => LogMedicationView(
                                              petId: _currentPetId,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Activities section with pink background
                        Container(
                          width: media.width,
                          // Make sure this extends to the bottom of the screen by setting a minimum height
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEDED),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Upcoming Activities",
                                  style: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 20,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      spacing: 12,
                                      children: [
                                        _buildFilterChip("All"),
                                        _buildFilterChip("Appointment"),
                                        _buildFilterChip("Vaccination"),
                                        _buildFilterChip("Deworming"),
                                        _buildFilterChip("Grooming"),
                                        _buildFilterChip("Other"),
                                      ],
                                    ),
                                  ),
                                ),
                                // No reminders or reminder list
                                _getFilteredReminders().isEmpty
                                    ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 40,
                                              color: TColor.gray,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              "No reminders found",
                                              style: TextStyle(
                                                fontFamily: "ComicNeue",
                                                fontSize: 16,
                                                color: TColor.gray,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "Add a reminder to see it here",
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
                                    : Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children:
                                          _getFilteredReminders().map((
                                            reminder,
                                          ) {
                                            return PawtectionActivityWidget(
                                              ontap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ReminderDetailsView(
                                                          reminderId:
                                                              reminder['reminder_id'],
                                                        ),
                                                  ),
                                                ).then((_) => _loadReminders());
                                              },
                                              icon:
                                                  "assets/images/icon_fursona.png",
                                              title:
                                                  reminder['activity_name'] !=
                                                              null &&
                                                          reminder['activity_name']
                                                              .toString()
                                                              .isNotEmpty
                                                      ? reminder['activity_name']
                                                      : reminder['reminder_cat'],
                                              dateTime: _formatDateTime(
                                                reminder['reminder_datetime'],
                                              ),
                                              location:
                                                  reminder['reminder_location'] ??
                                                  'No location specified',
                                            );
                                          }).toList(),
                                    ),
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
          ),

          // Home button positioned at the bottom
          Positioned(bottom: 0, left: 0, right: 0, child: const HomeButton()),
        ],
      ),
    );
  }

  // Build filter chip widget
  Widget _buildFilterChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _selectedFilter == label ? TColor.orangePeel : TColor.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                _selectedFilter == label
                    ? TColor.orangePeel
                    : Colors.transparent,
            width: 1,
          ),
        ),
        alignment: AlignmentDirectional(0, 0),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: "ComicNeue",
            color: _selectedFilter == label ? Colors.white : TColor.black,
          ),
        ),
      ),
    );
  }
}

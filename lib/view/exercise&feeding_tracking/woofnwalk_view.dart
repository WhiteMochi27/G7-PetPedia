//Contributed by [Tok Saw Ping]
import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import "dart:math";
import 'package:petpedia/database/database_handler.dart';
import 'dart:io';

class Pet {
  final String name;
  final String imageUrl;
  final List<Activity> activities;
  final double currentDistance;
  final double distanceGoal;
  final int activeMinutes;
  final int activeGoal;
  final List<FeedingTime> feedingSchedule;
  final DietaryPreferences dietaryPreferences;

  final double foodConsumed;
  final double foodGoal;
  final double waterConsumed;
  final double waterGoal;

  Pet({
    required this.name, 
    required this.imageUrl,
    required this.activities,
    required this.currentDistance,
    required this.distanceGoal,
    required this.activeMinutes,
    required this.activeGoal,
    required this.feedingSchedule,
    required this.dietaryPreferences,
    this.foodConsumed = 0,
    this.foodGoal = 0.0,
    this.waterConsumed = 0,
    this.waterGoal = 0.0,
  });
}

class Activity {
  String name;
  int duration;
  TimeOfDay time;
  bool isCompleted;
  double distanceContribution = 0.0;
  int minutesContribution = 0;

  Activity({
    required this.name, 
    required this.duration, 
    required this.time, 
    this.isCompleted = false,
    this.distanceContribution = 0.0,
    this.minutesContribution = 0,
  });
}

class FeedingTime {
  final String mealName;
  final String time;
  bool isCompleted;
  final double portion;
  final double waterConsumed;

  FeedingTime({
    required this.mealName,
    required this.time,
    this.isCompleted = false,
    this.portion = 0.0,
    this.waterConsumed = 0.0,
  });
}

class DietaryPreferences {
  final String foodType;
  final String allergies;
  final String specialNotes;

  DietaryPreferences({
    required this.foodType,
    required this.allergies,
    required this.specialNotes,
  });
}

class WoofnwalkView extends StatefulWidget {
  const WoofnwalkView({super.key});

  @override
  State<WoofnwalkView> createState() => _WoofnwalkViewState();
}

class _WoofnwalkViewState extends State<WoofnwalkView> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Exercise', 'Feeding'];
  
  DateTime _selectedDate = DateTime.now();
  bool get _isToday => _selectedDate.year == DateTime.now().year && 
                        _selectedDate.month == DateTime.now().month && 
                        _selectedDate.day == DateTime.now().day;
  
  late List<Pet> _pets = [];
  bool _isLoading = true;
  List<int> _petIds = []; // Store database IDs for pets
  
  int _selectedPetIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  // FIXED: Safe getters that handle empty lists
  Pet? get currentPet => _pets.isNotEmpty ? _pets[_selectedPetIndex] : null;
  int get currentPetId => _petIds.isNotEmpty ? _petIds[_selectedPetIndex] : -1;

  Future<void> _loadPets() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    await DatabaseHandler().initializeSampleData();
    
    final pets = await DatabaseHandler().getPets();
    
    final db = await DatabaseHandler().database;
    
    // Changed from 'pets' to 'pet_profile' and 'id' to 'pet_id'
    final petMaps = await db.query('pet_profile');
    _petIds = petMaps.map<int>((map) => map['pet_id'] as int).toList();
    
    setState(() {
      _pets = pets;
      _isLoading = false;
    });
    
    if (_pets.isNotEmpty) {
      _loadActivitiesAndFeedings();
    }
  } catch (e) {
    print('Error loading pets: $e');
    setState(() {
      _isLoading = false;
    });
    
    // Show error to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load pets: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
  
  Future<void> _loadActivitiesAndFeedings() async {
    if (_pets.isEmpty) return;
  
    List<Pet> updatedPets = [];
    
    for (int i = 0; i < _pets.length; i++) {
      Pet pet = _pets[i];
      int petId = _petIds[i];
      
      // Get activities for the selected date
      List<Activity> activities = await DatabaseHandler().getActivitiesForPet(
        petId, 
        _selectedDate
      );
      
      // Get feeding schedule for the selected date
      List<FeedingTime> feedingSchedule = await DatabaseHandler().getFeedingScheduleForPet(
        petId,
        _selectedDate
      );
      
      // Calculate metrics specific to this date from the activities and feeding schedules
      double dateDistance = 0.0;
      int dateActiveMinutes = 0;
      double dateFoodConsumed = 0.0;
      double dateWaterConsumed = 0.0;
      
      // Sum up the metrics from completed activities for this date
      for (Activity activity in activities) {
        if (activity.isCompleted) {
          dateDistance += activity.distanceContribution;
          dateActiveMinutes += activity.minutesContribution;
        }
      }
      
      // Sum up the metrics from completed feedings for this date
      for (FeedingTime feeding in feedingSchedule) {
        if (feeding.isCompleted) {
          dateFoodConsumed += feeding.portion;
          dateWaterConsumed += feeding.waterConsumed;
        }
      }
      
      // Get the pet from the database to preserve global goals
      Pet? dbPet = await DatabaseHandler().getPet(petId);
      
      updatedPets.add(Pet(
        name: pet.name,
        imageUrl: pet.imageUrl,
        activities: activities,
        currentDistance: dateDistance, // Use date-specific distance
        distanceGoal: dbPet?.distanceGoal ?? pet.distanceGoal, // Preserve goal from DB
        activeMinutes: dateActiveMinutes, // Use date-specific active minutes
        activeGoal: dbPet?.activeGoal ?? pet.activeGoal, // Preserve goal from DB
        feedingSchedule: feedingSchedule,
        dietaryPreferences: pet.dietaryPreferences,
        foodConsumed: dateFoodConsumed, // Use date-specific food consumed
        foodGoal: dbPet?.foodGoal ?? pet.foodGoal, // Preserve goal from DB
        waterConsumed: dateWaterConsumed, // Use date-specific water consumed
        waterGoal: dbPet?.waterGoal ?? pet.waterGoal, // Preserve goal from DB
      ));
    }
    
    setState(() {
      _pets = updatedPets;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // FIXED: Handle empty pets list with improved UI
if (_pets.isEmpty) {
  return Scaffold(
    // IMPORTANT: This ensures content goes behind the home button
    extendBody: true,
    body: Stack(
      children: [
        // Full screen background with content
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_content.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            bottom: false, // Important - don't add padding at bottom for safe area
            child: Column(
              children: [
                // Title - positioned at the very top with proper padding
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: PageTitle(
                    icon: 'assets/images/icon_woofnwalk.png',
                    title: 'Woof & Walk',
                    subtitle: 'Exercise & Feeding Tracking',
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
                          "assets/images/Pet profile pic/8.png", // Default pet image
                          width: 180,
                          height: 180,
                        ),
                        const SizedBox(height: 20),

                        // Message
                        const Text(
                          "No Pets Found",
                          style: TextStyle(
                            fontFamily: "Baloo",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                          ),
                          child: Text(
                            "Please add a pet first to use the Woof & Walk features",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Button to go back
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Use appropriate theme color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
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
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Home button positioned at the bottom
        const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
      ],
    ),
  );
}
    
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              const PageTitle(
                icon: 'assets/images/icon_woofnwalk.png',
                title: 'Woof & Walk',
                subtitle: 'Exercise & Feeding Tracking',
              ),
              
              // Date Navigation Bar
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: _buildDateBar(),
              ),
    
              // Main content
              Positioned.fill(
                top: 140,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left:16.0, right: 16.0, bottom: 10.0),
                    child: Column(
                      children: [
                        // Tabs
                        _buildTabs(),
                        const SizedBox(height: 16),
                        
                        // Pet Selection
                        _buildPetSelection(),
                        const SizedBox(height: 20),
                        
                        // Content based on selected tab
                        _selectedTabIndex == 0 
                            ? _buildExerciseContent() 
                            : _buildFeedingContent(),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
    
              // Home button at bottom
              const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadActivitiesAndFeedings();
            },
            iconSize: 28,
          ),
          Column(
            children: [
              Text(
                _isToday ? 'Today' : _getDayName(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
              _loadActivitiesAndFeedings(); // Reload data for the new date
            },
            iconSize: 28,
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  String _getDayName(DateTime date) {
    final List<String> days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    
    // DateTime weekday is 1-based (1 = Monday, 7 = Sunday)
    return days[date.weekday - 1];
  }
  
  Widget _buildTabs() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == _selectedTabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = entry.key;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPetSelection() {
  return Align(
    alignment: Alignment.centerLeft,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _pets.asMap().entries.map((entry) {
          final index = entry.key;
          final pet = entry.value;
          final isSelected = index == _selectedPetIndex;
          
          // Check if the image URL is an asset path or a file path
          Widget imageWidget;
          if (pet.imageUrl.startsWith('assets/')) {
            // Handle asset path
            imageWidget = Image.asset(
              pet.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            );
          } else {
            // Handle file path or URL
            imageWidget = Image.file(
              File(pet.imageUrl),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a default image if loading fails
                return Image.asset(
                  'assets/images/default_pet.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              },
            );
          }
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPetIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Selection circle
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      // Pet image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: imageWidget,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

  // FIXED: Handle null currentPet
  Widget _buildExerciseContent() {
    if (currentPet == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No pet data available. Please try refreshing the page."),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_isToday ? 'Today' : _getDayName(_selectedDate)}'s Activities",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle creating new activity
                        _showCreateActivityDialog();
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Activities List - Using currentPet.activities
                currentPet!.activities.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No activities scheduled for this day"),
                      ),
                    )
                      : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentPet!.activities.length,
                      itemBuilder: (context, index) {
                        final activity = currentPet!.activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${activity.duration} mins • ${_formatTimeOfDay(activity.time)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                color: Colors.blue,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _editActivity(activity, index);
                                },
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: Colors.red,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _deleteActivity(activity, index);
                                },
                              ),
                              const SizedBox(width: 8),
                              // Complete checkbox
                              GestureDetector(
                                onTap: () {
                                  if (!activity.isCompleted) {
                                    // Open input dialog when marking as complete
                                    _logCompletedActivity(activity, index);
                                  } else {
                                    // Toggle back to incomplete and remove contributions
                                    _markActivityIncomplete(activity, index);
                                  }
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    color: activity.isCompleted ? Colors.blue : Colors.transparent,
                                  ),
                                  child: activity.isCompleted 
                                      ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
          
          // Daily Goals Container
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Daily Goals with Edit Button only
                Row(
                  children: [
                    Text(
                      "Daily Goals",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Edit button
                    GestureDetector(
                      onTap: () {
                        // Handle edit goals
                        _showEditGoalsDialog();
                      },
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Goals Cards - Using currentPet data
                Row(
                  children: [
                    Expanded(
                      child: _buildGoalCard(
                        icon: Icons.map_outlined,
                        title: "Distance",
                        current: currentPet!.currentDistance,
                        goal: currentPet!.distanceGoal,
                        suffix: " km",
                        color: Colors.blue.shade100,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalCard(
                        icon: Icons.timer,
                        title: "Active Time",
                        current: currentPet!.activeMinutes.toDouble(),
                        goal: currentPet!.activeGoal.toDouble(),
                        suffix: " m",
                        color: Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Handle null currentPet
  Widget _buildFeedingContent() {
    if (currentPet == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No pet data available. Please try refreshing the page."),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_isToday ? 'Today' : _getDayName(_selectedDate)}'s Meals",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle creating new meal time
                        _showAddFeedingDialog();
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                currentPet!.feedingSchedule.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No meals scheduled for this day"),
                      ),
                    )
                  : Column(
                      children: currentPet!.feedingSchedule.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feeding = entry.value;
                        final isLast = index == currentPet!.feedingSchedule.length - 1;
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feeding.mealName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${feeding.portion.toStringAsFixed(1)} cups . ${feeding.waterConsumed.toInt()} ml . ${feeding.time}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                color: Colors.blue,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _editFeeding(feeding, index);
                                },
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                color: Colors.red,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _deleteFeeding(feeding, index);
                                },
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  _toggleFeedingCompletion(feeding, index);
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    color: feeding.isCompleted ? Colors.green : Colors.transparent,
                                  ),
                                  child: feeding.isCompleted 
                                      ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with Edit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Nutrition",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle edit nutrition goals
                        _showEditNutritionDialog();
                      },
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Nutrition metrics cards - with consistent formatting
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionMetricCard(
                        icon: Icons.restaurant,
                        title: "Food",
                        current: currentPet!.foodConsumed,
                        goal: currentPet!.foodGoal,
                        suffix: "cups",
                        color: Colors.blue.shade100,
                        progress: currentPet!.foodGoal > 0 ? currentPet!.foodConsumed / currentPet!.foodGoal : 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNutritionMetricCard(
                        icon: Icons.water_drop,
                        title: "Water",
                        current: currentPet!.waterConsumed,
                        goal: currentPet!.waterGoal,
                        suffix: "ml",
                        color: Colors.blue.shade100,
                        progress: currentPet!.waterGoal > 0 ? currentPet!.waterConsumed / currentPet!.waterGoal : 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dietary Preferences Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dietary Preferences",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showEditDietaryDialog();
                      },
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDietaryInfo("Food Type", currentPet!.dietaryPreferences.foodType),
                _buildDietaryInfo("Allergies", currentPet!.dietaryPreferences.allergies),
                _buildDietaryInfo("Special Notes", currentPet!.dietaryPreferences.specialNotes, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Modified to prevent division by zero
  Widget _buildNutritionMetricCard({
    required IconData icon,
    required String title,
    required double current,
    required double goal,
    String suffix = "",
    required Color color,
    required double progress,
  }) {
    // Ensure progress is between 0 and 1 to avoid errors
    double safeProgress = progress.isNaN || progress.isInfinite || progress < 0 ? 0 : (progress > 1 ? 1 : progress);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title == "Food"
                ? '${current.toStringAsFixed(1)} $suffix'
                : '${current.toInt()} $suffix',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title == "Food"
                ? 'Goal: ${goal.toStringAsFixed(1)} $suffix'
                : 'Goal: ${goal.toInt()} $suffix',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: safeProgress,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  // FIXED: Handle possible division by zero in _buildGoalCard too
  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required double current,
    required double goal,
    String suffix = "",
    required Color color,
  }) {
    // Protect against division by zero
    final progress = goal > 0 ? (current / goal) : 0.0;
    // Ensure progress is between 0 and 1
    final safeProgress = progress.isNaN || progress.isInfinite || progress < 0 ? 0.0 : (progress > 1 ? 1.0 : progress);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            // Format to avoid too many decimal places
            title == "Distance" 
                ? '${current.toStringAsFixed(1)}$suffix'
                : '${current.toInt()}$suffix',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            // Format goal value based on type
            title == "Distance"
                ? 'Goal: ${goal.toStringAsFixed(1)}$suffix'
                : 'Goal: ${goal.toInt()}$suffix',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: safeProgress,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDietaryInfo(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  // FIXED: Add null check for currentPet
  void _logCompletedActivity(Activity activity, int activityId) {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot log activity: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final TextEditingController distanceController = TextEditingController();
    final TextEditingController minutesController = TextEditingController(text: activity.duration.toString());
    
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete ${activity.name}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: distanceController,
                    decoration: const InputDecoration(
                      labelText: 'Distance (km)*',
                      hintText: 'How far did you go?',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Distance is required';
                      }
                      double? distance = double.tryParse(value);
                      if (distance == null) {
                        return 'Please enter a valid number';
                      }
                      if (distance <= 0) {
                        return 'Distance must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: minutesController,
                    decoration: const InputDecoration(
                      labelText: 'Time (minutes)*',
                      hintText: 'How long did it take?',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Time is required';
                      }
                      int? minutes = int.tryParse(value);
                      if (minutes == null) {
                        return 'Please enter a valid number';
                      }
                      if (minutes <= 0) {
                        return 'Time must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Complete'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final double additionalDistance = double.parse(distanceController.text);
                  final int activityMinutes = int.parse(minutesController.text);
                  
                  // Get the activity DB ID - using nullcheck for currentPetId
                  final db = await DatabaseHandler().database;
                  final activityMaps = await db.query(
                    'activities',
                    where: 'petId = ? AND date = ? AND name = ?',
                    whereArgs: [currentPetId, _formatDateForDb(_selectedDate), activity.name],
                  );
                  
                  if (activityMaps.isEmpty) {
                    Navigator.pop(context);
                    return;
                  }
                  
                  final int dbActivityId = activityMaps[0]['id'] as int;
                  
                  // Update activity in memory
                  activity.distanceContribution = additionalDistance;
                  activity.minutesContribution = activityMinutes;
                  activity.isCompleted = true;
                  activity.duration = activityMinutes;
                  
                  // Update activity in database
                  await DatabaseHandler().updateActivity(activity, dbActivityId);
                  
                  // Update pet's metrics in memory only - check for null
                  setState(() {
                    if (currentPet != null && _selectedPetIndex < _pets.length) {
                      Pet pet = _pets[_selectedPetIndex];
                      _pets[_selectedPetIndex] = Pet(
                        name: pet.name,
                        imageUrl: pet.imageUrl,
                        activities: pet.activities,
                        currentDistance: pet.currentDistance + additionalDistance,
                        distanceGoal: pet.distanceGoal,
                        activeMinutes: pet.activeMinutes + activityMinutes,
                        activeGoal: pet.activeGoal,
                        feedingSchedule: pet.feedingSchedule,
                        dietaryPreferences: pet.dietaryPreferences,
                        foodConsumed: pet.foodConsumed,
                        foodGoal: pet.foodGoal,
                        waterConsumed: pet.waterConsumed,
                        waterGoal: pet.waterGoal,
                      );
                    }
                  });
                  
                  // Show confirmation message
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${activity.name} completed! Added ${additionalDistance}km and ${activityMinutes} minutes.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  Future<void> _markActivityIncomplete(Activity activity, int index) async {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot mark activity incomplete: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Get the activity ID from the database
    final db = await DatabaseHandler().database;
    final activityMaps = await db.query(
      'activities',
      where: 'petId = ? AND date = ? AND name = ?',
      whereArgs: [currentPetId, _formatDateForDb(_selectedDate), activity.name],
    );
    
    if (activityMaps.isNotEmpty) {
      final activityId = activityMaps[0]['id'] as int;
      
      // Update in memory first
      setState(() {
        // Remove the contributed metrics from current date's totals
        Pet pet = _pets[_selectedPetIndex];
        _pets[_selectedPetIndex] = Pet(
          name: pet.name,
          imageUrl: pet.imageUrl,
          activities: pet.activities,
          currentDistance: pet.currentDistance - activity.distanceContribution,
          distanceGoal: pet.distanceGoal,
          activeMinutes: pet.activeMinutes - activity.minutesContribution,
          activeGoal: pet.activeGoal,
          feedingSchedule: pet.feedingSchedule,
          dietaryPreferences: pet.dietaryPreferences,
          foodConsumed: pet.foodConsumed,
          foodGoal: pet.foodGoal,
          waterConsumed: pet.waterConsumed,
          waterGoal: pet.waterGoal,
        );
        
        // Reset the activity's contribution values
        activity.isCompleted = false;
        activity.distanceContribution = 0.0;
        activity.minutesContribution = 0;
      });
      
      // Update in database
      await DatabaseHandler().updateActivity(activity, activityId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${activity.name} marked as incomplete'),
          duration: const Duration(seconds: 1),
        )
      );
    }
  }

  String _formatDateForDb(DateTime date) {
    // Format: YYYY-MM-DD
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // FIXED: Add null check for currentPet
  void _toggleFeedingCompletion(FeedingTime feeding, int index) async {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot toggle feeding: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (!feeding.isCompleted) {
      final TextEditingController foodAmountController = TextEditingController(text: feeding.portion.toString());
      final TextEditingController waterAmountController = TextEditingController();
      
      // Add form key for validation
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Complete ${feeding.mealName} Meal'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: foodAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Food Amount (cups)*',
                        hintText: 'Enter amount given',
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Food amount is required';
                        }
                        double? foodAmount = double.tryParse(value);
                        if (foodAmount == null) {
                          return 'Please enter a valid number';
                        }
                        if (foodAmount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: waterAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Water Amount (ml)*',
                        hintText: 'Enter water given',
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Water amount is required';
                        }
                        double? waterAmount = double.tryParse(value);
                        if (waterAmount == null) {
                          return 'Please enter a valid number';
                        }
                        if (waterAmount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Complete'),
                onPressed: () async {
                  // Validate form
                  if (formKey.currentState!.validate()) {
                    final double foodAmount = double.parse(foodAmountController.text);
                    final double waterAmount = double.parse(waterAmountController.text);
                    
                    // Get the feeding schedule ID from the database
                    final db = await DatabaseHandler().database;
                    final feedingMaps = await db.query(
                      'feeding_schedule',
                      where: 'petId = ? AND date = ? AND mealName = ?',
                      whereArgs: [currentPetId, _formatDateForDb(_selectedDate), feeding.mealName],
                    );
                    
                    if (feedingMaps.isNotEmpty) {
                      final feedingId = feedingMaps[0]['id'] as int;
                      
                      // Create a new FeedingTime with updated values
                      FeedingTime updatedFeeding = FeedingTime(
                        mealName: feeding.mealName,
                        time: feeding.time,
                        isCompleted: true,
                        portion: foodAmount,
                        waterConsumed: waterAmount,
                      );
                      
                      // Update in memory only - check for null
                      setState(() {
                        if (currentPet != null && _selectedPetIndex < _pets.length) {
                          _pets[_selectedPetIndex].feedingSchedule[index] = updatedFeeding;
                          
                          // Update food and water consumed for this date only
                          Pet pet = _pets[_selectedPetIndex];
                          _pets[_selectedPetIndex] = Pet(
                            name: pet.name,
                            imageUrl: pet.imageUrl,
                            activities: pet.activities,
                            currentDistance: pet.currentDistance,
                            distanceGoal: pet.distanceGoal,
                            activeMinutes: pet.activeMinutes,
                            activeGoal: pet.activeGoal,
                            feedingSchedule: pet.feedingSchedule,
                            dietaryPreferences: pet.dietaryPreferences,
                            foodConsumed: pet.foodConsumed + foodAmount,
                            foodGoal: pet.foodGoal,
                            waterConsumed: pet.waterConsumed + waterAmount,
                            waterGoal: pet.waterGoal,
                          );
                        }
                      });
                      
                      // Update feeding in database
                      await DatabaseHandler().updateFeedingTime(updatedFeeding, feedingId);
                      
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${feeding.mealName} meal completed! Added ${foodAmount.toStringAsFixed(1)} cups of food and ${waterAmount.toInt()} ml of water.'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      final db = await DatabaseHandler().database;
      final feedingMaps = await db.query(
        'feeding_schedule',
        where: 'petId = ? AND date = ? AND mealName = ?',
        whereArgs: [currentPetId, _formatDateForDb(_selectedDate), feeding.mealName],
      );
      
      if (feedingMaps.isNotEmpty) {
        final feedingId = feedingMaps[0]['id'] as int;
        
        FeedingTime updatedFeeding = FeedingTime(
          mealName: feeding.mealName,
          time: feeding.time,
          isCompleted: false,
          portion: feeding.portion,
          waterConsumed: 0.0,
        );
        
        setState(() {
          if (currentPet != null && _selectedPetIndex < _pets.length) {
            _pets[_selectedPetIndex].feedingSchedule[index] = updatedFeeding;
            
            Pet pet = _pets[_selectedPetIndex];
            _pets[_selectedPetIndex] = Pet(
              name: pet.name,
              imageUrl: pet.imageUrl,
              activities: pet.activities,
              currentDistance: pet.currentDistance,
              distanceGoal: pet.distanceGoal,
              activeMinutes: pet.activeMinutes,
              activeGoal: pet.activeGoal,
              feedingSchedule: pet.feedingSchedule,
              dietaryPreferences: pet.dietaryPreferences,
              foodConsumed: max(0, pet.foodConsumed - feeding.portion), // Prevent negative values
              foodGoal: pet.foodGoal,
              waterConsumed: max(0, pet.waterConsumed - feeding.waterConsumed), // Prevent negative values
              waterGoal: pet.waterGoal,
            );
          }
        });
        
        // Update in database
        await DatabaseHandler().updateFeedingTime(updatedFeeding, feedingId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${feeding.mealName} meal marked as incomplete'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // FIXED: Add null check for currentPet
  void _showCreateActivityDialog() {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot create activity: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final TextEditingController nameController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    // Form key for validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Activity'),
          content: Form(
            key: formKey,  // Attach the form key
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Activity Name Field
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Activity Name',
                      hintText: 'Enter activity name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Activity name is required';
                      }
                      return null;
                    },
                  ),
                  // Duration Field
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      hintText: 'Enter duration in minutes',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Duration is required';
                      }
                      int? duration = int.tryParse(value);
                      if (duration == null || duration <= 0) {
                        return 'Please enter a valid duration greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Time Field with Time Picker Dialog
                  TextFormField(
                    controller: TextEditingController(text: _formatTimeOfDay(selectedTime)),
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'Select time',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                // Validate form inputs
                if (formKey.currentState!.validate()) {
                  final int duration = int.tryParse(durationController.text) ?? 30;

                  final newActivity = Activity(
                    name: nameController.text,
                    duration: duration,
                    time: selectedTime,
                  );

                  // Add to database - check currentPetId again
                  if (currentPetId >= 0) {
                    await DatabaseHandler().insertActivity(
                      newActivity,
                      currentPetId,
                      _selectedDate,
                    );

                    // Refresh activities for current date
                    await _loadActivitiesAndFeedings();
                  }

                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet and currentPetId
  void _showEditGoalsDialog() {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot edit goals: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final TextEditingController distanceGoalController = TextEditingController(text: currentPet!.distanceGoal.toString());
    final TextEditingController activeGoalController = TextEditingController(text: currentPet!.activeGoal.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${currentPet!.name}\'s Daily Goals'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: distanceGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Distance Goal (km)',
                    hintText: 'Enter daily distance goal in km',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: activeGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Active Minutes Goal',
                    hintText: 'Enter active minutes goal',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Get the current pet from database to preserve actual metrics
                Pet? dbPet = await DatabaseHandler().getPet(currentPetId);
                if (dbPet == null) {
                  Navigator.pop(context);
                  return;
                }
                
                // Create updated pet with new goals but preserve metrics
                Pet updatedPet = Pet(
                  name: dbPet.name,
                  imageUrl: dbPet.imageUrl,
                  activities: dbPet.activities,
                  currentDistance: dbPet.currentDistance, 
                  distanceGoal: double.tryParse(distanceGoalController.text) ?? dbPet.distanceGoal,
                  activeMinutes: dbPet.activeMinutes,
                  activeGoal: int.tryParse(activeGoalController.text) ?? dbPet.activeGoal,
                  feedingSchedule: dbPet.feedingSchedule,
                  dietaryPreferences: dbPet.dietaryPreferences,
                  foodConsumed: dbPet.foodConsumed,
                  foodGoal: dbPet.foodGoal,
                  waterConsumed: dbPet.waterConsumed,
                  waterGoal: dbPet.waterGoal,
                );
                
                // Update database
                await DatabaseHandler().updatePet(updatedPet, currentPetId);
                
                // Update in-memory representation while preserving current date's metrics
                setState(() {
                  if (_selectedPetIndex < _pets.length) {
                    Pet pet = _pets[_selectedPetIndex];
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance, // Preserve current date metrics
                      distanceGoal: double.tryParse(distanceGoalController.text) ?? pet.distanceGoal,
                      activeMinutes: pet.activeMinutes, // Preserve current date metrics
                      activeGoal: int.tryParse(activeGoalController.text) ?? pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: pet.dietaryPreferences,
                      foodConsumed: pet.foodConsumed, // Preserve current date metrics
                      foodGoal: pet.foodGoal,
                      waterConsumed: pet.waterConsumed, // Preserve current date metrics
                      waterGoal: pet.waterGoal,
                    );
                  }
                });
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Daily goals updated'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  // FIXED: Add null check for currentPet
  void _editActivity(Activity activity, int index) async {
  if (currentPet == null || currentPetId < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cannot edit activity: No pet selected"),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
  
  // Get the activity ID from the database
  final db = await DatabaseHandler().database;
  final activityMaps = await db.query(
    'activities',
    where: 'petId = ? AND date = ? AND name = ?',
    whereArgs: [currentPetId, _formatDateForDb(_selectedDate), activity.name],
  );
  
  if (activityMaps.isEmpty) {
    // Activity not found in database
    return;
  }
  
  final activityId = activityMaps[0]['id'] as int;
  
  // Store the old duration to calculate the difference later
  final int oldDuration = activity.duration;
  final int oldMinutesContribution = activity.minutesContribution;
  
  final TextEditingController nameController = TextEditingController(text: activity.name);
  final TextEditingController durationController = TextEditingController(text: activity.duration.toString());
  TimeOfDay selectedTime = activity.time;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Activity'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Name',
                    hintText: 'Enter activity name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Activity name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                    hintText: 'Enter duration in minutes',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Duration is required';
                    }
                    int? duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'Please enter a valid duration greater than 0';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                  child: TextFormField(
                    controller: TextEditingController(text: _formatTimeOfDay(selectedTime)),
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'Select time',
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newDuration = int.tryParse(durationController.text) ?? 30;
                
                // Calculate difference in minutes if the activity is completed
                int minutesDifference = 0;
                if (activity.isCompleted) {
                  // If activity's minutesContribution is equal to old duration,
                  // then update it to match the new duration
                  if (oldMinutesContribution == oldDuration) {
                    activity.minutesContribution = newDuration;
                  } else {
                    // Otherwise, the user manually entered a minutesContribution before,
                    // so we can calculate a proportional change
                    double ratio = oldMinutesContribution / oldDuration;
                    activity.minutesContribution = (newDuration * ratio).round();
                  }
                  
                  // Calculate the difference to update the pet's total active minutes
                  minutesDifference = activity.minutesContribution - oldMinutesContribution;
                }
                
                // Update activity in memory
                setState(() {
                  activity.name = nameController.text;
                  activity.duration = newDuration;
                  activity.time = selectedTime;
                  
                  // Update pet's total active minutes if the activity is completed
                  if (activity.isCompleted && _selectedPetIndex < _pets.length) {
                    Pet pet = _pets[_selectedPetIndex];
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance,
                      distanceGoal: pet.distanceGoal,
                      activeMinutes: pet.activeMinutes + minutesDifference,
                      activeGoal: pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: pet.dietaryPreferences,
                      foodConsumed: pet.foodConsumed,
                      foodGoal: pet.foodGoal,
                      waterConsumed: pet.waterConsumed,
                      waterGoal: pet.waterGoal,
                    );
                  }
                });
                
                // Update activity in database
                await DatabaseHandler().updateActivity(activity, activityId);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${activity.name} updated'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  // FIXED: Add null check for currentPet
  void _deleteActivity(Activity activity, int index) async {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete activity: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final db = await DatabaseHandler().database;
    final activityMaps = await db.query(
      'activities',
      where: 'petId = ? AND date = ? AND name = ?',
      whereArgs: [currentPetId, _formatDateForDb(_selectedDate), activity.name],
    );
    
    if (activityMaps.isEmpty) {
      return;
    }
    
    final activityId = activityMaps[0]['id'] as int;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Activity'),
          content: Text('Are you sure you want to delete "${activity.name}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                if (activity.isCompleted && _selectedPetIndex < _pets.length) {
                  // Remove contribution from current date's totals in memory
                  setState(() {
                    Pet pet = _pets[_selectedPetIndex];
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance - activity.distanceContribution,
                      distanceGoal: pet.distanceGoal,
                      activeMinutes: pet.activeMinutes - activity.minutesContribution,
                      activeGoal: pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: pet.dietaryPreferences,
                      foodConsumed: pet.foodConsumed,
                      foodGoal: pet.foodGoal,
                      waterConsumed: pet.waterConsumed,
                      waterGoal: pet.waterGoal,
                    );
                  });
                }
                
                // Remove the activity from database
                await DatabaseHandler().deleteActivity(activityId);
                
                // Remove the activity from memory
                setState(() {
                  if (currentPet != null) {
                    currentPet!.activities.removeAt(index);
                  }
                });
                
                Navigator.pop(context);
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${activity.name} deleted' + 
                      (activity.isCompleted ? ' and statistics adjusted' : '')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  void _showAddFeedingDialog() {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot add feeding: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final TextEditingController mealNameController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    final TextEditingController portionController = TextEditingController(text: "2.0");
    final TextEditingController waterController = TextEditingController(text: "0"); 

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void updateTimeText() {
      timeController.text = _formatTimeOfDay(selectedTime);
    }

    updateTimeText(); // Initialize with current time

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Feeding Time'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: mealNameController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name',
                      hintText: 'e.g., Breakfast, Lunch, Dinner',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Meal name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: portionController,
                    decoration: const InputDecoration(
                      labelText: 'Portion Size (cups)',
                      hintText: 'Enter amount in cups',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Portion size is required';
                      }
                      double? portion = double.tryParse(value);
                      if (portion == null) {
                        return 'Please enter a valid number';
                      }
                      if (portion <= 0) {
                        return 'Portion must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: waterController,
                    decoration: const InputDecoration(
                      labelText: 'Water Amount (ml)',
                      hintText: 'Enter water given',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Water amount is required';
                      }
                      double? waterAmount = double.tryParse(value);
                      if (waterAmount == null) {
                        return 'Please enter a valid number';
                      }
                      if (waterAmount < 0) {
                        return 'Amount must be non-negative';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'Select time',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Time is required';
                      }
                      return null;
                    },
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        selectedTime = pickedTime;
                        updateTimeText();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                // Validate inputs
                if (formKey.currentState!.validate()) {
                  final double portion = double.parse(portionController.text);
                  final double waterAmount = double.parse(waterController.text);

                  final newFeeding = FeedingTime(
                    mealName: mealNameController.text,
                    time: _formatTimeOfDay(selectedTime),
                    portion: portion,
                    waterConsumed: waterAmount,
                  );

                  // Add feeding to database
                  await DatabaseHandler().insertFeedingTime(
                    newFeeding, 
                    currentPetId,
                    _selectedDate,
                  );

                  await _loadActivitiesAndFeedings();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Feeding added: ${mealNameController.text} - ${portion.toStringAsFixed(1)} cups, ${waterAmount.toInt()} ml.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  void _editFeeding(FeedingTime feeding, int index) async {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot edit feeding: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final db = await DatabaseHandler().database;
    final feedingMaps = await db.query(
      'feeding_schedule',
      where: 'petId = ? AND date = ? AND mealName = ?',
      whereArgs: [currentPetId, _formatDateForDb(_selectedDate), feeding.mealName],
    );
    
    if (feedingMaps.isEmpty) {
      return;
    }
    
    final feedingId = feedingMaps[0]['id'] as int;

    final TextEditingController mealNameController = TextEditingController(text: feeding.mealName);
    final TextEditingController portionController = TextEditingController(text: feeding.portion.toString());
    final TextEditingController waterController = TextEditingController(text: feeding.waterConsumed.toString());
    final TextEditingController timeController = TextEditingController(text: feeding.time);
    
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      final timeStr = feeding.time;
      final isPM = timeStr.toLowerCase().contains('pm');
      final parts = timeStr.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      // Convert to 24-hour format if PM
      if (isPM && hour < 12) hour += 12;
      // Convert 12 AM to 0 hour
      if (!isPM && hour == 12) hour = 0;
      
      initialTime = TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      // If parsing fails, default to current time
      print('Error parsing time: $e');
    }
    
    TimeOfDay selectedTime = initialTime;
    
    void updateTimeText() {
      timeController.text = _formatTimeOfDay(selectedTime);
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Feeding Time'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: mealNameController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name',
                      hintText: 'e.g., Breakfast, Lunch, Dinner',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Meal name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: portionController,
                    decoration: const InputDecoration(
                      labelText: 'Portion Size (cups)',
                      hintText: 'Enter amount in cups',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Portion size is required';
                      }
                      double? portion = double.tryParse(value);
                      if (portion == null) {
                        return 'Please enter a valid number';
                      }
                      if (portion <= 0) {
                        return 'Portion must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: waterController,
                    decoration: const InputDecoration(
                      labelText: 'Water Amount (ml)',
                      hintText: 'Enter water given',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Water amount is required';
                      }
                      double? waterAmount = double.tryParse(value);
                      if (waterAmount == null) {
                        return 'Please enter a valid number';
                      }
                      if (waterAmount < 0) {
                        return 'Amount must be non-negative';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      hintText: 'Select time',
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Time is required';
                      }
                      return null;
                    },
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        selectedTime = pickedTime;
                        updateTimeText();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Validate inputs
                if (formKey.currentState!.validate()) {
                  final updatedFeeding = FeedingTime(
                    mealName: mealNameController.text,
                    time: timeController.text,
                    isCompleted: feeding.isCompleted,
                    portion: double.tryParse(portionController.text) ?? feeding.portion,
                    waterConsumed: double.tryParse(waterController.text) ?? feeding.waterConsumed,
                  );

                  // Update feeding in database
                  await DatabaseHandler().updateFeedingTime(updatedFeeding, feedingId);

                  // Reload feedings to update the UI
                  await _loadActivitiesAndFeedings();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${feeding.mealName} updated'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  void _deleteFeeding(FeedingTime feeding, int index) async {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete feeding: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final db = await DatabaseHandler().database;
    final feedingMaps = await db.query(
      'feeding_schedule',
      where: 'petId = ? AND date = ? AND mealName = ?',
      whereArgs: [currentPetId, _formatDateForDb(_selectedDate), feeding.mealName],
    );
    
    if (feedingMaps.isEmpty) {
      return;
    }
    
    final feedingId = feedingMaps[0]['id'] as int;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Feeding'),
          content: Text('Are you sure you want to delete the "${feeding.mealName}" meal?'),
          actions: [
            // Cancel button
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            // Delete button
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                // If the feeding was completed, adjust the pet's date-specific nutrition stats
                if (feeding.isCompleted && _selectedPetIndex < _pets.length) {
                  setState(() {
                    Pet pet = _pets[_selectedPetIndex];
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance,
                      distanceGoal: pet.distanceGoal,
                      activeMinutes: pet.activeMinutes,
                      activeGoal: pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: pet.dietaryPreferences,
                      foodConsumed: max(0, pet.foodConsumed - feeding.portion),
                      foodGoal: pet.foodGoal,
                      waterConsumed: max(0, pet.waterConsumed - feeding.waterConsumed),
                      waterGoal: pet.waterGoal,
                    );
                  });
                }
                
                await DatabaseHandler().deleteFeedingTime(feedingId);
                
                setState(() {
                  if (currentPet != null) {
                    currentPet!.feedingSchedule.removeAt(index);
                  }
                });
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${feeding.mealName} feeding deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  void _showEditNutritionDialog() {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot edit nutrition goals: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Controllers for nutrition goals
    final TextEditingController foodGoalController = TextEditingController(text: currentPet!.foodGoal.toString());
    final TextEditingController waterGoalController = TextEditingController(text: currentPet!.waterGoal.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${currentPet!.name}\'s Nutrition Goals'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: foodGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Food Goal (cups)',
                    hintText: 'Enter daily food goal in cups',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: waterGoalController,
                  decoration: const InputDecoration(
                    labelText: 'Water Goal (ml)',
                    hintText: 'Enter daily water goal in ml',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Get the current pet from database to preserve actual metrics
                Pet? dbPet = await DatabaseHandler().getPet(currentPetId);
                if (dbPet == null) {
                  Navigator.pop(context);
                  return;
                }
                
                // Create updated pet with new goals but preserve metrics
                Pet updatedPet = Pet(
                  name: dbPet.name,
                  imageUrl: dbPet.imageUrl,
                  activities: dbPet.activities,
                  currentDistance: dbPet.currentDistance,
                  distanceGoal: dbPet.distanceGoal,
                  activeMinutes: dbPet.activeMinutes,
                  activeGoal: dbPet.activeGoal,
                  feedingSchedule: dbPet.feedingSchedule,
                  dietaryPreferences: dbPet.dietaryPreferences,
                  foodConsumed: dbPet.foodConsumed,
                  foodGoal: double.tryParse(foodGoalController.text) ?? dbPet.foodGoal,
                  waterConsumed: dbPet.waterConsumed,
                  waterGoal: double.tryParse(waterGoalController.text) ?? dbPet.waterGoal,
                );
                
                // Update database
                await DatabaseHandler().updatePet(updatedPet, currentPetId);
                
                // Update in-memory representation while preserving current date's metrics
                setState(() {
                  if (_selectedPetIndex < _pets.length) {
                    Pet pet = _pets[_selectedPetIndex];
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance,
                      distanceGoal: pet.distanceGoal,
                      activeMinutes: pet.activeMinutes,
                      activeGoal: pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: pet.dietaryPreferences,
                      foodConsumed: pet.foodConsumed, // Preserve current date metrics
                      foodGoal: double.tryParse(foodGoalController.text) ?? pet.foodGoal,
                      waterConsumed: pet.waterConsumed, // Preserve current date metrics
                      waterGoal: double.tryParse(waterGoalController.text) ?? pet.waterGoal,
                    );
                  }
                });
                
                Navigator.pop(context);
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nutrition goals updated'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // FIXED: Add null check for currentPet
  void _showEditDietaryDialog() {
    if (currentPet == null || currentPetId < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot edit dietary preferences: No pet selected"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Controllers for dietary preferences
    final TextEditingController foodTypeController = TextEditingController(text: currentPet!.dietaryPreferences.foodType);
    final TextEditingController allergiesController = TextEditingController(text: currentPet!.dietaryPreferences.allergies);
    final TextEditingController notesController = TextEditingController(text: currentPet!.dietaryPreferences.specialNotes);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${currentPet!.name}\'s Diet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: foodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Food Type',
                    hintText: 'Enter food type',
                  ),
                ),
                TextField(
                  controller: allergiesController,
                  decoration: const InputDecoration(
                    labelText: 'Allergies',
                    hintText: 'Enter allergies (if any)',
                  ),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Special Notes',
                    hintText: 'Enter any special feeding notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                // Create new dietary preferences
                final newPreferences = DietaryPreferences(
                  foodType: foodTypeController.text,
                  allergies: allergiesController.text,
                  specialNotes: notesController.text,
                );
                
                // Update in memory
                setState(() {
                  if (_selectedPetIndex < _pets.length) {
                    Pet pet = _pets[_selectedPetIndex];
                    
                    _pets[_selectedPetIndex] = Pet(
                      name: pet.name,
                      imageUrl: pet.imageUrl,
                      activities: pet.activities,
                      currentDistance: pet.currentDistance,
                      distanceGoal: pet.distanceGoal,
                      activeMinutes: pet.activeMinutes,
                      activeGoal: pet.activeGoal,
                      feedingSchedule: pet.feedingSchedule,
                      dietaryPreferences: newPreferences,
                      foodConsumed: pet.foodConsumed,
                      foodGoal: pet.foodGoal,
                      waterConsumed: pet.waterConsumed,
                      waterGoal: pet.waterGoal,
                    );
                  }
                });
                
                // Update in database
                await DatabaseHandler().updateDietaryPreferences(newPreferences, currentPetId);
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dietary preferences updated'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
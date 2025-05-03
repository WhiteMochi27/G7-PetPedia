// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';

class AddAchievementPopup extends StatefulWidget {
  final Function(
    String title,
    String badgeColor,
    DateTime date,
    String? description,
  )
  onSave;

  const AddAchievementPopup({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddAchievementPopup> createState() => _AddAchievementPopupState();
}

class _AddAchievementPopupState extends State<AddAchievementPopup> {
  String? _selectedAchievement;
  String _selectedBadgeColor = 'pink'; // Default badge color
  String? _selectedDescription;

  final Map<String, List<AchievementItem>> _achievementsByCategory = {
    '🏆 Basic Milestones': [
      AchievementItem(
        name: 'First Walk',
        description: 'Took their first outdoor walk!',
      ),
      AchievementItem(
        name: 'Name Recognition',
        description: 'Responds to their name consistently!',
      ),
      AchievementItem(
        name: 'First Bath',
        description: 'Successfully completed their first bath!',
      ),
      AchievementItem(
        name: 'Potty Trained',
        description: 'Learned where to go!',
      ),
      AchievementItem(
        name: 'First Vet Visit',
        description: 'Had their first health check-up!',
      ),
    ],
    '🐾 Training & Behavior': [
      AchievementItem(
        name: 'Sit Mastery',
        description: 'Learned to sit on command!',
      ),
      AchievementItem(
        name: 'Stay Pro',
        description: 'Stays in place when told!',
      ),
      AchievementItem(
        name: 'Shake Paw',
        description: 'Learned to shake hands!',
      ),
      AchievementItem(
        name: 'Fetch Champion',
        description: 'Successfully retrieves and returns an item!',
      ),
      AchievementItem(
        name: 'Leash Expert',
        description: 'Walks nicely on a leash without pulling!',
      ),
    ],
    '🎮 Fun & Activities': [
      AchievementItem(
        name: 'First Playdate',
        description: 'Had fun with another pet!',
      ),
      AchievementItem(
        name: 'Swimming Star',
        description: 'Took their first swim!',
      ),
      AchievementItem(
        name: 'Park Explorer',
        description: 'Visited a new park!',
      ),
      AchievementItem(
        name: 'Trickster',
        description: 'Learned a fun trick (like rolling over)!',
      ),
      AchievementItem(
        name: 'First Car Ride',
        description: 'Enjoyed a safe and happy car trip!',
      ),
    ],
    '🩺 Health & Wellness': [
      AchievementItem(
        name: 'Perfect Weight',
        description: 'Reached a healthy weight!',
      ),
      AchievementItem(
        name: 'Dental Champ',
        description: 'Had a successful teeth cleaning!',
      ),
      AchievementItem(
        name: 'Vaccine Hero',
        description: 'Completed all required vaccinations!',
      ),
      AchievementItem(
        name: 'Healthy Eater',
        description: 'Successfully transitioned to a new diet!',
      ),
      AchievementItem(
        name: 'Allergy Fighter',
        description: 'Overcame a food allergy or health challenge!',
      ),
    ],
    '🌟 Special & Personalized Achievements': [
      AchievementItem(
        name: 'Birthday Paw',
        description: 'Celebrated their first birthday!',
      ),
      AchievementItem(
        name: 'Rescue Hero',
        description: 'Adopted from a shelter or rescue!',
      ),
      AchievementItem(
        name: 'First Snow Experience',
        description: 'Played in the snow for the first time!',
      ),
      AchievementItem(
        name: 'Home Guardian',
        description: 'Alerted the family to something important!',
      ),
      AchievementItem(
        name: 'Best Cuddler',
        description: 'Awarded for the warmest snuggles!',
      ),
    ],
  };

  void _showDateSelectionPopup() {
    if (_selectedAchievement == null) return;

    for (var category in _achievementsByCategory.entries) {
      for (var item in category.value) {
        if (item.name == _selectedAchievement) {
          _selectedDescription = item.description;
          break;
        }
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => DateSelectionPopup(
            achievementName: _selectedAchievement!,
            achievementDescription: _selectedDescription,
            initialBadgeColor: _selectedBadgeColor,
            onSave: (date, badgeColor, description) {
              widget.onSave(
                _selectedAchievement!,
                badgeColor,
                date,
                description,
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCE7).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add New Achievements',
                  style: TextStyle(
                    fontFamily: 'Baloo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _achievementsByCategory.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                entry.key,
                                style: TextStyle(
                                  fontFamily: 'Baloo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...entry.value.map(
                                (item) => _buildAchievementCheckbox(item),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC89484),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontFamily: 'ComicNeue'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed:
                        _selectedAchievement != null
                            ? () {
                              Navigator.of(context).pop();
                              _showDateSelectionPopup();
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF75F4F4),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(fontFamily: 'ComicNeue'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCheckbox(AchievementItem item) {
    final isSelected = _selectedAchievement == item.name;

    return CheckboxListTile(
      title: Text(
        item.name,
        style: TextStyle(fontFamily: 'ComicNeue', fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '– ${item.description}',
        style: TextStyle(fontFamily: 'ComicNeue', fontSize: 13),
      ),
      value: isSelected,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedAchievement = item.name;
          } else if (_selectedAchievement == item.name) {
            _selectedAchievement = null;
          }
        });
      },
      activeColor: Colors.black,
      checkColor: Colors.white,
    );
  }
}

class AchievementItem {
  final String name;
  final String description;

  AchievementItem({required this.name, required this.description});
}

class DateSelectionPopup extends StatefulWidget {
  final String achievementName;
  final String? achievementDescription;
  final String initialBadgeColor;
  final Function(DateTime date, String badgeColor, String? description) onSave;

  const DateSelectionPopup({
    Key? key,
    required this.achievementName,
    this.achievementDescription,
    required this.initialBadgeColor,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DateSelectionPopup> createState() => _DateSelectionPopupState();
}

class _DateSelectionPopupState extends State<DateSelectionPopup> {
  late DateTime _selectedDate;
  late String _selectedBadgeColor;
  late TextEditingController _descriptionController;

  final List<Map<String, dynamic>> _badgeColors = [
    {'name': 'pink', 'asset': 'assets/images/achievement_badge_pink.png'},
    {'name': 'blue', 'asset': 'assets/images/achievement_badge_blue.png'},
    {'name': 'green', 'asset': 'assets/images/achievement_badge_green.png'},
    {'name': 'yellow', 'asset': 'assets/images/achievement_badge_yellow.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedBadgeColor = widget.initialBadgeColor;
    _descriptionController = TextEditingController(
      text: widget.achievementDescription ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF729996),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCE7).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'New Achievement',
                style: TextStyle(
                  fontFamily: 'Baloo',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      _badgeColors.firstWhere(
                        (b) => b['name'] == _selectedBadgeColor,
                      )['asset'],
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.achievementName,
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _selectDate,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(_selectedDate),
                                      style: TextStyle(
                                        fontFamily: 'ComicNeue',
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add a description (optional)',
                  hintStyle: TextStyle(fontFamily: 'ComicNeue'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children:
                    _badgeColors.map((badge) {
                      bool isSelected = badge['name'] == _selectedBadgeColor;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBadgeColor = badge['name'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              badge['asset'],
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC89484),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 15),
                          const SizedBox(width: 4),
                          Text('Cancel'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _selectedDate,
                        _selectedBadgeColor,
                        _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : null,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF75F4F4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 15),
                          const SizedBox(width: 4),
                          Text('Save'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

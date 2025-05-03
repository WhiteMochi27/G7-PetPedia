// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:petpedia/database/database_handler.dart';

class PetCharacteristicsPopup extends StatefulWidget {
  final List<String> selectedCharacteristics;
  final Function(List<String>) onSave;
  final int? petId;
  
  const PetCharacteristicsPopup({
    Key? key,
    required this.selectedCharacteristics,
    required this.onSave,
    this.petId,
  }) : super(key: key);

  @override
  State<PetCharacteristicsPopup> createState() =>
      _PetCharacteristicsPopupState();
}

class _PetCharacteristicsPopupState extends State<PetCharacteristicsPopup> {
  late List<String> _selectedCharacteristics;
  int _maxSelections = 10;
  bool _isLoading = false;
  final DatabaseHandler _db = DatabaseHandler();

  final Map<String, List<CharacteristicItem>> _characteristicsByCategory = {
    '🐾 Personality & Temperament': [
      CharacteristicItem(
        name: 'Affectionate',
        description: 'Loves cuddles and attention',
      ),
      CharacteristicItem(
        name: 'Independent',
        description: 'Enjoys alone time, not overly clingy',
      ),
      CharacteristicItem(
        name: 'Playful',
        description: 'Loves playing and being active',
      ),
      CharacteristicItem(
        name: 'Curious',
        description: 'Always exploring and investigating',
      ),
      CharacteristicItem(
        name: 'Shy',
        description: 'Timid around new people or pets',
      ),
      CharacteristicItem(name: 'Energetic', description: 'Always on the move'),
      CharacteristicItem(name: 'Calm', description: 'Relaxed and easygoing'),
      CharacteristicItem(
        name: 'Loyal',
        description: 'Sticks closely to their owner',
      ),
      CharacteristicItem(
        name: 'Intelligent',
        description: 'Quick learner, figures things out easily',
      ),
      CharacteristicItem(
        name: 'Stubborn',
        description: 'Knows what they want and won\'t budge',
      ),
    ],
    '🐕 Behavior & Social Traits': [
      CharacteristicItem(
        name: 'Friendly',
        description: 'Gets along with people and other pets',
      ),
      CharacteristicItem(
        name: 'Protective',
        description: 'Guards family and home',
      ),
      CharacteristicItem(
        name: 'Gentle',
        description: 'Soft and careful, especially around kids',
      ),
      CharacteristicItem(
        name: 'Anxious',
        description: 'Nervous in new situations or loud noises',
      ),
      CharacteristicItem(
        name: 'Vocal',
        description: 'Barks, meows, chirps, or chatters often',
      ),
      CharacteristicItem(name: 'Quiet', description: 'Rarely makes noise'),
      CharacteristicItem(
        name: 'Social Butterfly',
        description: 'Loves being around people and animals',
      ),
      CharacteristicItem(
        name: 'Territorial',
        description: 'Protective of space, may guard food or toys',
      ),
      CharacteristicItem(
        name: 'Obedient',
        description: 'Listens to commands and follows rules',
      ),
      CharacteristicItem(
        name: 'Mischievous',
        description: 'Sneaky, loves to cause playful trouble',
      ),
    ],
    '🐾 Activity & Play Style': [
      CharacteristicItem(
        name: 'Fetch Lover',
        description: 'Enjoys chasing and bringing back toys',
      ),
      CharacteristicItem(
        name: 'Water Lover',
        description: 'Loves swimming and playing in water',
      ),
      CharacteristicItem(
        name: 'Climber',
        description: 'Loves to climb furniture, trees, or high places',
      ),
      CharacteristicItem(
        name: 'Digger',
        description: 'Enjoys digging in the ground or bedding',
      ),
      CharacteristicItem(
        name: 'Night Owl',
        description: 'Active mostly at night',
      ),
      CharacteristicItem(
        name: 'Sunbather',
        description: 'Loves lying in warm, sunny spots',
      ),
      CharacteristicItem(
        name: 'Cuddler',
        description: 'Enjoys being held and snuggled',
      ),
      CharacteristicItem(
        name: 'Chaser',
        description: 'Loves running after things (toys, squirrels, etc.)',
      ),
      CharacteristicItem(
        name: 'Hunter Instinct',
        description: 'Enjoys stalking and "hunting" toys or small animals',
      ),
      CharacteristicItem(
        name: 'Lap Pet',
        description: 'Loves sitting on laps and staying close',
      ),
    ],
    '🐕‍🦺 Training & Intelligence': [
      CharacteristicItem(
        name: 'Eager to Please',
        description: 'Wants to make the owner happy',
      ),
      CharacteristicItem(
        name: 'Food Motivated',
        description: 'Responds well to treats in training',
      ),
      CharacteristicItem(
        name: 'Trick Master',
        description: 'Knows and enjoys learning tricks',
      ),
      CharacteristicItem(
        name: 'Escape Artist',
        description: 'Good at sneaking out or opening doors',
      ),
      CharacteristicItem(
        name: 'Chewer',
        description: 'Loves to chew on things (toys, shoes, furniture)',
      ),
      CharacteristicItem(
        name: 'Messy Eater',
        description: 'Spills food and water often',
      ),
      CharacteristicItem(
        name: 'Problem Solver',
        description: 'Figures out puzzles and challenges quickly',
      ),
      CharacteristicItem(
        name: 'Pack Leader',
        description: 'Dominant personality in groups',
      ),
      CharacteristicItem(
        name: 'Follower',
        description: 'Prefers to follow instead of lead',
      ),
      CharacteristicItem(
        name: 'Slow Learner',
        description: 'Needs extra patience with training',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedCharacteristics = List.from(widget.selectedCharacteristics);
    
    if (widget.petId != null) {
      _loadCharacteristicsFromDb();
    }
  }

  Future<void> _loadCharacteristicsFromDb() async {
    if (widget.petId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final characteristicsList = await _db.getCharacteristicsForPet(widget.petId!);
      
      setState(() {
        _selectedCharacteristics = characteristicsList
            .map<String>((char) => char['name'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading characteristics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCharacteristicsToDb() async {
    if (widget.petId == null) return;
    
    try {
      final existingCharacteristics = await _db.getCharacteristicsForPet(widget.petId!);
      final existingNames = existingCharacteristics
          .map<String>((char) => char['name'] as String)
          .toList();
      
      for (final existing in existingCharacteristics) {
        if (!_selectedCharacteristics.contains(existing['name'])) {
          await _db.deleteCharacteristic(existing['char_id']);
        }
      }
      
      for (final selected in _selectedCharacteristics) {
        if (!existingNames.contains(selected)) {
          await _db.insertCharacteristic({
            'pet_id': widget.petId,
            'name': selected,
            'percentage': 0.5, 
          });
        }
      }
    } catch (e) {
      print('Error saving characteristics: $e');
    }
  }

  bool _canSelectMore() {
    return _selectedCharacteristics.length < _maxSelections;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCE7).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
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
                  'Add New Characteristics',
                  style: TextStyle(
                    fontFamily: 'Baloo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Maximum ${_maxSelections} Characteristics',
                  style: TextStyle(
                    fontFamily: 'ComicNeue',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _characteristicsByCategory.entries.map((entry) {
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
                                (item) => _buildCharacteristicCheckbox(item),
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontFamily: 'ComicNeue'),
                    ),
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.petId != null) {
                        await _saveCharacteristicsToDb();
                      }
                      
                      widget.onSave(_selectedCharacteristics);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF75F4F4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontFamily: 'ComicNeue'),
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

  Widget _buildCharacteristicCheckbox(CharacteristicItem item) {
    final isSelected = _selectedCharacteristics.contains(item.name);
    final isDisabled = !isSelected && !_canSelectMore();

    return CheckboxListTile(
      title: Text(
        '${item.name}',
        style: TextStyle(
          fontFamily: 'ComicNeue', 
          fontWeight: FontWeight.w600,
          color: isDisabled ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: Text(
        '– ${item.description}',
        style: TextStyle(
          fontFamily: 'ComicNeue', 
          fontSize: 13,
          color: isDisabled ? Colors.grey : Colors.black54,
        ),
      ),
      value: isSelected,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      onChanged: isDisabled 
          ? null 
          : (bool? value) {
              setState(() {
                if (value == true) {
                  if (!isSelected && _canSelectMore()) {
                    _selectedCharacteristics.add(item.name);
                  }
                } else {
                  _selectedCharacteristics.remove(item.name);
                }
              });
            },
      activeColor: Colors.black,
      checkColor: Colors.white,
    );
  }
}

class CharacteristicItem {
  final String name;
  final String description;

  CharacteristicItem({required this.name, required this.description});
}
// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'pet_characteristics_popup_view.dart';

class EditView extends StatefulWidget {
  final Map<String, dynamic> pet;

  const EditView({super.key, required this.pet});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  late Map<String, dynamic> _editedPet;
  bool _isEditing = false;
  bool _neutered = true;
  DateTime _selectedDate = DateTime(2003, 2, 24);
  double _weight = 30;
  bool _useKg = true;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final DatabaseHandler _db = DatabaseHandler();
  bool _isLoading = false;
  final Map<String, double> _characteristics = {};

  @override
  void initState() {
    super.initState();
    _editedPet = Map.from(widget.pet);
    _neutered = widget.pet['neutered'] == 'Yes';

    // Load date of birth
    if (widget.pet['dob'] != null) {
      DateTime? parsedDate = _db.parseDbDate(widget.pet['dob']);
      if (parsedDate != null) {
        _selectedDate = parsedDate;
      }
    }

    // Load weight
    if (widget.pet['weight'] != null) {
      _weight =
          widget.pet['weight'] is double
              ? widget.pet['weight']
              : double.tryParse(widget.pet['weight'].toString()) ?? _weight;
    }

    // Load characteristics
    _loadCharacteristics();
  }

  // Load characteristics from database
  Future<void> _loadCharacteristics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final petId = widget.pet['pet_id'];
      final characteristicsList = await _db.getCharacteristicsForPet(petId);

      Map<String, double> loadedCharacteristics = {};
      for (var char in characteristicsList) {
        final percentage = char['percentage'];
        double percentageValue = 0.5; // Default value

        if (percentage is double) {
          percentageValue = percentage;
        } else if (percentage != null) {
          percentageValue = double.tryParse(percentage.toString()) ?? 0.5;
        }

        loadedCharacteristics[char['name']] = percentageValue;
      }

      if (mounted) {
        setState(() {
          _characteristics.clear();
          _characteristics.addAll(loadedCharacteristics);
        });
      }
    } catch (e) {
      print('Error loading characteristics: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading characteristics: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error selecting image: $e")));
      }
    }
  }

  // Show modal bottom sheet to select image source
  void _showImageSourceSelector() {
    if (!_isEditing) return; // Only allow if in editing mode

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
              // Main Content Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Page Title)
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 10),
                    child: PageTitle(
                      icon: 'assets/images/icon_fursona.png',
                      title: 'Fursona',
                      subtitle: 'Edit Pet',
                    ),
                  ),

                  // 2. Navigation Row (Back and Edit buttons)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        IconButton(
                          icon: Image.asset('assets/images/icon_back.png'),
                          onPressed: () => Navigator.pop(context),
                        ),

                        // Edit/Save/Cancel Buttons
                        _isEditing
                            ? Row(
                              children: [
                                IconButton(
                                  icon: Image.asset(
                                    'assets/images/icon_cancel.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  onPressed: _cancelEditing,
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: Image.asset(
                                    'assets/images/icon_save.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  onPressed: _saveChanges,
                                ),
                              ],
                            )
                            : IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: _startEditing,
                            ),
                      ],
                    ),
                  ),

                  // 3. Main Content (Scrollable)
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Picture
                                    _buildProfilePictureSection(),
                                    const SizedBox(height: 20),

                                    // Details Sections
                                    _buildDetailRow(
                                      'Name',
                                      _editedPet['name'],
                                      (value) => _editedPet['name'] = value,
                                    ),
                                    _buildDetailRow(
                                      'Breed',
                                      _editedPet['breed'] ?? '',
                                      (value) => _editedPet['breed'] = value,
                                    ),
                                    _buildDetailRow(
                                      'Species',
                                      _editedPet['species'] ?? 'Dog',
                                      (value) => _editedPet['species'] = value,
                                    ),
                                    _buildGenderRow(),

                                    // Neutered Toggle
                                    _buildNeuteredRow(),

                                    // Weight Section
                                    _buildWeightRow(),

                                    // Date of Birth
                                    _buildDateRow(),

                                    // Characteristics Sliders
                                    _buildCharacteristicsSection(),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ],
              ),

              // Home Button
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: HomeButton(),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: InkWell(
        onTap: _isEditing ? _showImageSourceSelector : null,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _editedPet['gender'] == 'male'
                          ? const Color(0xFF75F4F4)
                          : const Color(0xFFFFB7F9),
                  width: 4,
                ),
              ),
              child: ClipOval(
                child:
                    _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : _editedPet['avatar_url'] != null &&
                            _editedPet['avatar_url'].startsWith('/')
                        ? Image.file(
                          File(_editedPet['avatar_url']),
                          fit: BoxFit.cover,
                        )
                        : _editedPet['avatar_url'] != null
                        ? Image.asset(
                          _editedPet['avatar_url'],
                          fit: BoxFit.cover,
                        )
                        : _editedPet['imagePath'] != null
                        ? Image.asset(
                          _editedPet['imagePath'],
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/images/Pet profile pic/default.png',
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            if (_isEditing)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Color(0xFF729996),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String value,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _isEditing
                      ? TextFormField(
                        initialValue: value,
                        onChanged: onChanged,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                      : Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Gender',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ), // Increased padding here
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _isEditing
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'male',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: 16,
                            ),
                          ),
                          Switch(
                            value: _editedPet['gender'] == 'female',
                            onChanged: (value) {
                              setState(() {
                                _editedPet['gender'] =
                                    value ? 'female' : 'male';
                              });
                            },
                            activeColor: const Color(0xFFFFB7F9),
                            activeTrackColor: const Color(
                              0xFFFFB7F9,
                            ).withOpacity(0.5),
                            inactiveThumbColor: const Color(0xFF75F4F4),
                            inactiveTrackColor: const Color(
                              0xFF75F4F4,
                            ).withOpacity(0.5),
                          ),
                          const Text(
                            'female',
                            style: TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        _editedPet['gender'],
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuteredRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Neutered',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_neutered ? 'Yes' : 'No'),
                  if (_isEditing)
                    Switch(
                      value: _neutered,
                      onChanged: (value) {
                        setState(() => _neutered = value);
                      },
                      activeColor: const Color(0xFF75F4F4),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Weight',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _isEditing
                      ? Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _weight.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _weight = double.tryParse(value) ?? _weight;
                                });
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ToggleButtons(
                              isSelected: [_useKg, !_useKg],
                              onPressed: (index) {
                                setState(() => _useKg = index == 0);
                              },
                              borderRadius: BorderRadius.circular(5),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('kg'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('g'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                      : Text(
                        '$_weight ${_useKg ? 'kg' : 'g'}',
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Date of Birth',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _isEditing
                      ? InkWell(
                        onTap: _selectDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      )
                      : Text(
                        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildCharacteristicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Pet Characteristics',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCharacteristicsPopup(context),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCE7).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child:
              _characteristics.isEmpty
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No characteristics added yet. Tap the + icon to add some!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                  : Column(
                    children:
                        _characteristics.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontFamily: 'ComicNeue',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 6,
                                      thumbColor: const Color(0xFFC89484),
                                      activeTrackColor: const Color(0xFF729996),
                                      inactiveTrackColor: const Color(
                                        0xFF729996,
                                      ).withOpacity(0.5),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 10,
                                      ),
                                      overlayShape:
                                          SliderComponentShape.noOverlay,
                                    ),
                                    child: Slider(
                                      value: entry.value,
                                      onChanged:
                                          _isEditing
                                              ? (value) {
                                                setState(() {
                                                  _characteristics[entry.key] =
                                                      value;
                                                });
                                              }
                                              : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editedPet = Map.from(widget.pet);
      _imageFile = null; // Reset image if canceling

      // Reset neutered status
      _neutered = widget.pet['neutered'] == 'Yes';

      // Reset date of birth
      if (widget.pet['dob'] != null) {
        DateTime? parsedDate = _db.parseDbDate(widget.pet['dob']);
        if (parsedDate != null) {
          _selectedDate = parsedDate;
        }
      }

      // Reset weight
      if (widget.pet['weight'] != null) {
        _weight =
            widget.pet['weight'] is double
                ? widget.pet['weight']
                : double.tryParse(widget.pet['weight'].toString()) ?? _weight;
      }

      // Reload characteristics
      _loadCharacteristics();
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a map with updated pet data
      Map<String, dynamic> updatedPet = {
        'name': _editedPet['name'],
        'breed': _editedPet['breed'] ?? '',
        'species': _editedPet['species'] ?? _editedPet['breed'],
        'gender': _editedPet['gender'],
        'neutered': _neutered ? 'Yes' : 'No',
        'weight': _weight,
        'dob': _db.formatDateForDb(_selectedDate),
      };

      // Handle image path
      if (_imageFile != null) {
        // Store the file path
        updatedPet['avatar_url'] = _imageFile!.path;
      } else if (_editedPet['avatar_url'] != null) {
        updatedPet['avatar_url'] = _editedPet['avatar_url'];
      } else if (_editedPet['imagePath'] != null) {
        updatedPet['avatar_url'] = _editedPet['imagePath'];
      }

      // Get the pet ID
      final petId = widget.pet['pet_id'];

      // Update the pet profile in the database
      await _db.updatePetProfile(updatedPet, petId);

      // Update characteristics in the database
      await _updateCharacteristics(petId);

      // Set editing state to false
      setState(() {
        _isEditing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet profile updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating pet: $e');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating pet: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCharacteristics(int petId) async {
    try {
      // Get existing characteristics
      final existingCharacteristics = await _db.getCharacteristicsForPet(petId);

      // For each characteristic in the map
      for (final entry in _characteristics.entries) {
        final charName = entry.key;
        final percentage = entry.value;

        // Check if this characteristic already exists
        final existingChar = existingCharacteristics.firstWhere(
          (char) => char['name'] == charName,
          orElse: () => {},
        );

        if (existingChar.isNotEmpty) {
          // Update existing characteristic
          await _db.updateCharacteristic({
            'name': charName,
            'percentage': percentage,
            'pet_id': petId,
          }, existingChar['char_id']);
        } else {
          // Insert new characteristic
          await _db.insertCharacteristic({
            'name': charName,
            'percentage': percentage,
            'pet_id': petId,
          });
        }
      }

      // Find characteristics to delete (in existing but not in current list)
      final currentCharNames = _characteristics.keys.toSet();
      for (final char in existingCharacteristics) {
        if (!currentCharNames.contains(char['name'])) {
          await _db.deleteCharacteristic(char['char_id']);
        }
      }
    } catch (e) {
      print('Error updating characteristics: $e');
      // Error is handled in the calling method
      rethrow;
    }
  }

  void _showCharacteristicsPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Characteristics Popup",
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return PetCharacteristicsPopup(
          selectedCharacteristics: _characteristics.keys.toList(),
          petId: widget.pet['pet_id'],
          onSave: (selectedCharacteristics) {
            // Create a new map with existing values for selected characteristics
            Map<String, double> updatedCharacteristics = {};

            // Keep existing values for characteristics that were already selected
            for (final key in _characteristics.keys) {
              if (selectedCharacteristics.contains(key)) {
                updatedCharacteristics[key] = _characteristics[key]!;
              }
            }

            // Add new characteristics with default value of 0.5
            for (final name in selectedCharacteristics) {
              if (!_characteristics.containsKey(name)) {
                updatedCharacteristics[name] = 0.5;
              }
            }

            setState(() {
              _characteristics.clear();
              _characteristics.addAll(updatedCharacteristics);
            });
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }
}

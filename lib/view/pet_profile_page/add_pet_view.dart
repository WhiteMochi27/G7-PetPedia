// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddPetView extends StatefulWidget {
  const AddPetView({super.key});

  @override
  State<AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends State<AddPetView> {
  final DatabaseHandler _db = DatabaseHandler();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Form values
  String _gender = 'male';
  bool _isNeutered = false;
  DateTime _dateOfBirth = DateTime.now();
  File? _profileImage;
  String _weightUnit = 'kg';

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  void _showImageSourceSelector() {
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
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

  Future<void> _savePet() async {
    // Validate required fields
    if (_nameController.text.isEmpty || _breedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and breed')),
      );
      return;
    }

    // Get the current logged-in user
    final currentUser = await _db.getRememberedUser();
    final userId = currentUser != null ? currentUser['id'] : 1;

    // Build pet data for database
    final Map<String, dynamic> petData = {
      'name': _nameController.text,
      'breed': _breedController.text, 
      'species':
          _speciesController.text.isNotEmpty
              ? _speciesController.text
              : _breedController.text,
      'gender': _gender,
      'neutered': _isNeutered ? 'Yes' : 'No',
      'user_id': userId,
    };

    // Add optional fields
    if (_weightController.text.isNotEmpty) {
      petData['weight'] = double.tryParse(_weightController.text) ?? 0.0;
    }

    petData['dob'] = _db.formatDateForDb(_dateOfBirth);

    // Handle avatar image path
    if (_profileImage != null) {
      // In a real app, you'd handle file storage differently
      // For this implementation, we're mocking behavior
      petData['avatar_url'] = _profileImage!.path;
    } else {
      petData['avatar_url'] = 'assets/images/Pet profile pic/default.png';
    }

    // Save to database
    final petId = await _db.insertPetProfile(petData);

    // Return pet info to previous screen
    if (mounted) {
      // Create pet object for UI display
      final newPet = {
        'name': _nameController.text,
        'breed': _breedController.text,
        'species': _speciesController.text,
        'gender': _gender,
        'neutered': _isNeutered ? 'Yes' : 'No',
        'weight': '${_weightController.text} $_weightUnit',
        'dateOfBirth': _formatDate(_dateOfBirth),
        'imagePath': petData['avatar_url'],
        'save': true,
        'pet_id': petId,
      };

      Navigator.pop(context, newPet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            const PageTitle(
              icon: 'assets/images/icon_fursona.png',
              title: 'Fursona',
              subtitle: 'Add Pet',
            ),

            // Main Content
            Positioned.fill(
              top: 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceSelector,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _gender == 'male'
                                          ? const Color(0xFF75F4F4)
                                          : const Color(0xFFFFB7F9),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    _profileImage != null
                                        ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.pets,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Form Fields
                    _buildFormField('Name', _nameController),
                    _buildFormField('Breed', _breedController),
                    _buildFormField('Species', _speciesController),

                    // Gender Toggle
                    _buildLabelText('Gender'),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
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
                            value: _gender == 'female',
                            onChanged: (value) {
                              setState(() {
                                _gender = value ? 'female' : 'male';
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
                      ),
                    ),

                    // Neutered Toggle
                    _buildLabelText('Neutered'),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isNeutered ? 'Yes' : 'No',
                            style: const TextStyle(
                              fontFamily: 'ComicNeue',
                              fontSize: 16,
                            ),
                          ),
                          Switch(
                            value: _isNeutered,
                            onChanged: (value) {
                              setState(() {
                                _isNeutered = value;
                              });
                            },
                            activeColor: Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                    ),

                    // Weight with Unit Selection
                    _buildLabelText('Weight'),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter weight',
                                hintStyle: TextStyle(fontFamily: 'ComicNeue'),
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                _buildUnitButton('kg'),
                                _buildUnitButton('g'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date of Birth Picker
                    _buildLabelText('Date of Birth'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_dateOfBirth),
                              style: const TextStyle(
                                fontFamily: 'ComicNeue',
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    // Save Button
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: ElevatedButton(
                          onPressed: _savePet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontFamily: 'Baloo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 100,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/images/icon_back.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),

            // Home Button
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelText(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'ComicNeue',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabelText(label),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
              hintText: 'Enter $label',
              hintStyle: TextStyle(fontFamily: 'ComicNeue'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitButton(String unit) {
    bool isSelected = _weightUnit == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          _weightUnit = unit;
        });
      },
      child: Container(
        width: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[400] : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600]),
        ),
      ),
    );
  }
}
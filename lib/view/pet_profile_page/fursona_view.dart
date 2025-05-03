import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'pet_details_view.dart';
import 'edit_view.dart';
import 'add_pet_view.dart';
import 'dart:io';

class FursonaView extends StatefulWidget {
  const FursonaView({super.key});

  @override
  State<FursonaView> createState() => _FursonaViewState();
}

class _FursonaViewState extends State<FursonaView> {
  final DatabaseHandler _db = DatabaseHandler();
  List<Map<String, dynamic>> pets = [];
  int? selectedPetId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    // Get the current logged-in user (assuming you're storing userId somewhere)
    // You can modify this part based on your authentication implementation
    final currentUser = await _db.getRememberedUser();
    final userId =
        currentUser != null
            ? currentUser['id']
            : 1; // Default to 1 if no user found

    final petList = await _db.getAllPetProfiles(userId: userId);

    setState(() {
      pets = petList;
      isLoading = false;
      if (pets.isNotEmpty) {
        selectedPetId = pets.first['pet_id'];
      }
    });
  }

  String _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return "Unknown age";

    final birthDate = _db.parseDbDate(dateOfBirth);
    if (birthDate == null) return "Unknown age";

    return _db.calculateAgeFromDate(birthDate);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_content.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (pets.isEmpty) {
      return _buildEmptyState(context);
    }

    final selectedPet = pets.firstWhere(
      (pet) => pet['pet_id'] == selectedPetId,
      orElse: () => pets.first,
    );
    final isMale = selectedPet['gender'] == 'male';
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
              subtitle: 'Pet Profile',
            ),

            // Main Content
            Positioned.fill(
              top: 100,
              child: Column(
                children: [
                  // Selected Pet Profile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Pet Name (Right-aligned)
                        Text(
                          selectedPet['name'],
                          style: const TextStyle(
                            fontFamily: 'Baloo',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Pet Image and Info on same row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pet Image (Circular)
                            Container(
                              width: screenWidth * 0.4 - 20,
                              height: screenWidth * 0.4 - 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isMale
                                          ? const Color(0xFF75F4F4)
                                          : const Color(0xFFFFB7F9),
                                  width: 6,
                                ),
                              ),
                              child: ClipOval(
                                child:
                                    selectedPet['avatar_url'] != null &&
                                            selectedPet['avatar_url'].isNotEmpty
                                        ? selectedPet['avatar_url'].startsWith(
                                              '/',
                                            )
                                            ? Image.file(
                                              File(selectedPet['avatar_url']),
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(
                                              selectedPet['avatar_url'],
                                              fit: BoxFit.cover,
                                            )
                                        : Image.asset(
                                          'assets/images/Pet profile pic/default.png',
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Pet Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Species/Breed Container
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          isMale
                                              ? 'assets/images/profile_male.png'
                                              : 'assets/images/profile_female.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedPet['species'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontFamily: 'Baloo',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Age Container
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _calculateAge(selectedPet['dob']),
                                      style: const TextStyle(
                                        fontFamily: 'Baloo',
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Edit and View Buttons
                                  Row(
                                    children: [
                                      // Edit Button
                                      Expanded(
                                        child: Material(
                                          color: const Color(0xFFFFFCE7),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            splashColor: Colors.grey
                                                .withOpacity(0.3),
                                            onTap: () => _editPet(selectedPet),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.edit, size: 20),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // View Button
                                      Expanded(
                                        child: Material(
                                          color: const Color(0xFFFFFCE7),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            splashColor: Colors.grey
                                                .withOpacity(0.3),
                                            onTap:
                                                () => _viewPetDetails(
                                                  selectedPet,
                                                ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.visibility,
                                                    size: 20,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'View',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Pet List Container
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCE7).withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 20,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _addNewPet(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Pet'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Scrollable Grid of Pets
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 10,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.7,
                                  ),
                              itemCount: pets.length,
                              itemBuilder: (context, index) {
                                final pet = pets[index];
                                final isPetMale = pet['gender'] == 'male';

                                return GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => selectedPetId = pet['pet_id'],
                                      ),
                                  child: Column(
                                    children: [
                                      // Pet Image (Circular)
                                      AspectRatio(
                                        aspectRatio:
                                            1.0, // This forces a perfect square
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  isPetMale
                                                      ? const Color(0xFF75F4F4)
                                                      : const Color(0xFFFFB7F9),
                                              width: 4,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child:
                                                pet['avatar_url'] != null &&
                                                        pet['avatar_url']
                                                            .isNotEmpty
                                                    ? pet['avatar_url']
                                                            .startsWith('/')
                                                        ? Image.file(
                                                          File(
                                                            pet['avatar_url'],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                        : Image.asset(
                                                          pet['avatar_url'],
                                                          fit: BoxFit.cover,
                                                        )
                                                    : Image.asset(
                                                      'assets/images/Pet profile pic/default.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Pet Name with Paw Icons
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.pets, size: 12),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Text(
                                                pet['name'],
                                                style: const TextStyle(
                                                  fontFamily: 'Baloo',
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.pets, size: 12),
                                          ],
                                        ),  
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Pagination Dots (if needed for multiple pages)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.brown,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Home Button
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
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
              subtitle: 'Pet Profile',
            ),

            // Empty state content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No pets added yet!',
                    style: TextStyle(
                      fontFamily: 'Baloo',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _addNewPet(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Pet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Home Button
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  void _editPet(Map<String, dynamic> pet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditView(pet: pet)),
    ).then((_) => _loadPets()); // Refresh after returning
  }

  void _viewPetDetails(Map<String, dynamic> pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailsView(petId: pet['pet_id']),
      ),
    ).then((_) => _loadPets()); // Refresh after returning
  }

  void _addNewPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPetView()),
    );

    if (result != null && mounted) {
      if (result['save'] == true) {
        _loadPets(); // Reload pets after adding new one
      }
    }
  }
}

// Contributed by: Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/view/pet_profile_page/album_list_view.dart';
import 'edit_view.dart';
import 'pawchievement_view.dart';
import 'package:petpedia/view/health&wellness/furllergic_view.dart';
import 'package:petpedia/view/health&wellness/pawtection_view.dart';
import 'package:petpedia/view/exercise&feeding_tracking/woofnwalk_view.dart';
import 'dart:io';

class PetDetailsView extends StatefulWidget {
  final int petId;

  const PetDetailsView({super.key, required this.petId});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  final DatabaseHandler _db = DatabaseHandler();
  Map<String, dynamic>? pet;
  bool isLoading = true;
  bool _isRemovePressed = false;

  @override
  void initState() {
    super.initState();
    _loadPetDetails();
  }

  Future<void> _loadPetDetails() async {
    final petData = await _db.getPetProfileById(widget.petId);

    setState(() {
      pet = petData;
      isLoading = false;
    });
  }

  Widget _buildActionButton(String label, String imagePath) {
    return GestureDetector(
      onTap: () {
        if (label == 'Pet Details') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditView(pet: pet!)),
          ).then((_) => _loadPetDetails());
        } else if (label == 'Pet Album') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumListView(petId: widget.petId),
            ),
          );
        } else if (label == 'Fitness Status') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WoofnwalkView()),
          );
        } else if (label == 'Pet Achievements') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PawChievementView(petId: widget.petId),
            ),
          );
        } else if (label == 'Health Status') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FurllergicView(petId: widget.petId),
            ),
          );
        } else if (label == 'Pet Appointment') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PawtectionView()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 80, height: 80),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Baloo', fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Pet'),
            content: const Text('Are you sure you want to remove this pet?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _removePet();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _removePet() async {
    if (pet != null) {
      await _db.deletePetProfile(widget.petId);
    }
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

    if (pet == null) {
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
              const PageTitle(
                icon: 'assets/images/icon_fursona.png',
                title: 'Fursona',
                subtitle: 'Pet Details',
              ),
              Center(
                child: Text(
                  'Pet not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 100, left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Image.asset('assets/images/icon_back.png'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: HomeButton(),
              ),
            ],
          ),
        ),
      );
    }

    final isMale = pet!['gender'] == 'male';
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
              subtitle: 'Pet Details',
            ),

            // Main Content
            Positioned.fill(
              top: 80,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Pet Profile Picture
                    Container(
                      width: screenWidth * 0.5,
                      height: screenWidth * 0.5,
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
                            pet!['avatar_url'] != null &&
                                    pet!['avatar_url'].isNotEmpty
                                ? pet!['avatar_url'].startsWith('/')
                                    ? Image.file(
                                      File(pet!['avatar_url']),
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      pet!['avatar_url'],
                                      fit: BoxFit.cover,
                                    )
                                : Image.asset(
                                  'assets/images/Pet profile pic/default.png',
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pet Name and Species
                    Text(
                      pet!['name'],
                      style: const TextStyle(
                        fontFamily: 'Baloo',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet!['species'] ?? 'Unknown Species',
                      style: const TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: 18,
                      ),
                    ),

                    if (pet!['breed'] != null && pet!['breed'].isNotEmpty)
                      Text(
                        pet!['breed'],
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 10),

                    // Action Buttons Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1,
                        children: [
                          _buildActionButton(
                            'Pet Details',
                            'assets/images/profile_details_button.png',
                          ),
                          _buildActionButton(
                            'Pet Album',
                            'assets/images/profile_album_button.png',
                          ),
                          _buildActionButton(
                            'Fitness Status',
                            'assets/images/profile_status_button.png',
                          ),
                          _buildActionButton(
                            'Pet Achievements',
                            'assets/images/profile_achievements_button.png',
                          ),
                          _buildActionButton(
                            'Health Status',
                            'assets/images/profile_health_status_button.png',
                          ),
                          _buildActionButton(
                            'Pet Appointment',
                            'assets/images/profile_appointment_button.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Remove Pet Button
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isRemovePressed = true),
                      onTapUp: (_) => setState(() => _isRemovePressed = false),
                      onTapCancel:
                          () => setState(() => _isRemovePressed = false),
                      onTap: () => _showRemoveConfirmation(context),
                      child: Container(
                        width: screenWidth * 0.8,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              _isRemovePressed
                                  ? 'assets/images/button_delete_click.png'
                                  : 'assets/images/button_delete.png',
                              fit: BoxFit.fill,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Remove Pet',
                                style: TextStyle(
                                  fontFamily: 'Baloo',
                                  fontSize: 18,
                                  color:
                                      _isRemovePressed
                                          ? Colors.black87
                                          : Colors.black38,
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
            ),

            // Back button
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Image.asset('assets/images/icon_back.png'),
                  onPressed: () => Navigator.pop(context),
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

  // Widget _buildActionButton(String label, String imagePath) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (label == 'Pet Details') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => EditView(pet: pet)),
  //         );
  //       }
  //       if (label == 'Pet Album') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => AlbumListView()),
  //         );
  //       }
  //       if (label == 'Fitness Status') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => WoofnwalkView()),
  //         );
  //       }
  //       if (label == 'Pet Achievements') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => PawChievementView()),
  //         );
  //       }
  //       // if (label == 'Health Status') {
  //       //   Navigator.push(
  //       //     context,
  //       //     MaterialPageRoute(builder: (context) => FurllergicView()),
  //       //   );
  //       // }
  //       if (label == 'Pet Appointment') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => PawtectionView()),
  //         );
  //       }
  //     },
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Image.asset(imagePath, width: 80, height: 80),
  //         const SizedBox(height: 8),
  //         Text(
  //           label,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(fontFamily: 'Baloo', fontSize: 12),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showRemoveConfirmation(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Remove Pet'),
  //           content: const Text('Are you sure you want to remove this pet?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 Navigator.pop(context);
  //               },
  //               child: const Text(
  //                 'Remove',
  //                 style: TextStyle(color: Colors.red),
  //               ),
  //             ),
  //           ],
  //         ),
  //   );
  // }
}

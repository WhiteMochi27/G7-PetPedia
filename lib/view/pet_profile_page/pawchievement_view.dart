import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'add_achievement_popup.dart';
import 'dart:io';

class PawChievementView extends StatefulWidget {
  final int petId;

  const PawChievementView({super.key, required this.petId});

  @override
  State<PawChievementView> createState() => _PawChievementViewState();
}

class _PawChievementViewState extends State<PawChievementView> {
  // Current page for achievements pagination
  int currentPage = 0;
  List<Map<String, dynamic>> achievements = [];
  bool isLoading = true;
  Map<String, dynamic>? petData;
  final DatabaseHandler _db = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    _loadPetAndAchievements();
  }

  Future<void> _loadPetAndAchievements() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load pet profile data
      final pet = await _db.getPetProfileById(widget.petId);

      // Load pet achievements
      final achievementList = await _db.getAchievementsForPet(widget.petId);

      setState(() {
        petData = pet;
        achievements = achievementList;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading pet data: $e");
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
  }

  Future<void> _addAchievement(
    String title,
    String badgeColor,
    DateTime date,
    String? description,
  ) async {
    try {
      final achievement = {
        'pet_id': widget.petId,
        'name': title,
        'date': _db.formatDateForDb(date),
        'description': description,
        'badge_color': badgeColor,
      };

      await _db.insertAchievement(achievement);

      // Reload achievements
      await _loadPetAndAchievements();

      // Reset to first page if adding a new achievement
      if (currentPage != 0) {
        setState(() {
          currentPage = 0;
        });
      }
    } catch (e) {
      print("Error adding achievement: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding achievement: $e")));
      }
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

    // If pet not found
    if (petData == null) {
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
                icon: 'assets/images/icon_achievement.png',
                title: 'PawChievement',
                subtitle: 'Pet Achievement Tracker',
              ),
              Center(
                child: Text(
                  'Pet not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 90,
                left: 15,
                child: IconButton(
                  icon: Image.asset('assets/images/icon_back.png'),
                  onPressed: () => Navigator.pop(context),
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

    // Calculate paw level and progress based on achievements count
    int totalAchievements = achievements.length;
    int pawLevel = (totalAchievements / 10).floor() + 1;
    int currentLevelAchievements = totalAchievements % 10;

    return Scaffold(
      appBar: null, // Remove default app bar
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
              icon: 'assets/images/icon_achievement.png',
              title: 'PawChievement',
              subtitle: 'Pet Achievement Tracker',
            ),
            Positioned(
              top: 90,
              left: 15,
              child: IconButton(
                icon: Image.asset('assets/images/icon_back.png'),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned.fill(
              top: 100,
              child: Column(
                children: [
                  // Pet profile section
                  _buildProfileSection(),

                  // Paw level progress bar
                  _buildPawLevelBar(pawLevel, currentLevelAchievements),

                  // Achievements grid
                  _buildAchievementsSection(),
                ],
              ),
            ),

            // Home button at bottom
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final isMale = petData!['gender'] == 'male';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Pet profile image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isMale ? const Color(0xFF75F4F4) : const Color(0xFFFFB7F9),
                width: 4,
              ),
            ),
            child: ClipOval(child: _getProfileImage()),
          ),

          const SizedBox(height: 8),

          // Pet name
          Text(
            petData!['name'],
            style: const TextStyle(
              fontFamily: 'Baloo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Star bar
          Image.asset(
            'assets/images/achievement_star_bar.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  // Helper method to get the correct image widget based on the avatar_url
  Widget _getProfileImage() {
    if (petData!['avatar_url'] == null || petData!['avatar_url'].isEmpty) {
      // Use default image from assets
      return Image.asset(
        'assets/images/Pet profile pic/default.png',
        fit: BoxFit.cover,
      );
    }

    String avatarUrl = petData!['avatar_url'];

    // Check if the path is an asset path or a file path
    if (avatarUrl.startsWith('assets/')) {
      // It's an asset path
      return Image.asset(avatarUrl, fit: BoxFit.cover);
    } else if (avatarUrl.startsWith('/')) {
      // It's likely a file path on the device
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading profile image: $error");
          // Fallback to default image if file can't be loaded
          return Image.asset(
            'assets/images/Pet profile pic/default.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // It might be a network image URL
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading profile image: $error");
          // Fallback to default image if URL can't be loaded
          return Image.asset(
            'assets/images/Pet profile pic/default.png',
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  Widget _buildPawLevelBar(int pawLevel, int currentLevelAchievements) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Paw level text
          Text(
            'Paw Level: $pawLevel',
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Progress bar
          Stack(
            clipBehavior:
                Clip.none, // Allow the button to overflow outside the stack
            alignment: Alignment.centerLeft,
            children: [
              // Background bar
              Container(
                height: 15,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF729996), width: 1),
                ),
              ),

              // Progress fill
              Container(
                height: 15,
                width:
                    MediaQuery.of(context).size.width *
                    (currentLevelAchievements / 10) *
                    0.9, // 0.9 to account for padding
                decoration: BoxDecoration(
                  color: const Color(0xFF729996),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Paw icon on slider - positioned outside the bar
              Positioned(
                left:
                    (MediaQuery.of(context).size.width *
                        (currentLevelAchievements / 10) *
                        0.9) -
                    15,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Center(
                    child: Image.asset(
                      'assets/images/achievement_badge_slidebar.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Achievement count text
          Text(
            '$currentLevelAchievements/10',
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    // Calculate start and end indices for current page
    int startIndex = currentPage * 6;
    int endIndex = startIndex + 6;
    if (endIndex > achievements.length) {
      endIndex = achievements.length;
    }

    // Get achievements for current page
    List<Map<String, dynamic>> currentPageAchievements = achievements.sublist(
      startIndex,
      endIndex,
    );

    // Calculate total pages
    int totalPages = (achievements.length / 6).ceil();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          80,
        ), // Bottom margin for home button
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCE7),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Add Achievement button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AddAchievementPopup(
                            onSave: (title, badgeColor, date, description) {
                              _addAchievement(
                                title,
                                badgeColor,
                                date,
                                description,
                              );
                            },
                          ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Achievement',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'ComicNeue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF729996),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Empty state or Achievements grid
            Expanded(
              child:
                  achievements.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/achievement_badge_blue.png',
                              width: 80,
                              height: 80,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No achievements yet',
                              style: TextStyle(
                                fontFamily: 'Baloo',
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your pet\'s first achievement\nby clicking the button above',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'ComicNeue',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ScrollConfiguration(
                        behavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(scrollbars: false),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: currentPageAchievements.length,
                          itemBuilder: (context, index) {
                            return _buildAchievementBadge(
                              currentPageAchievements[index],
                            );
                          },
                        ),
                      ),
            ),

            // Pagination controls - only show if there are achievements and multiple pages
            if (achievements.isNotEmpty && totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous page button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed:
                        currentPage > 0
                            ? () {
                              setState(() {
                                currentPage--;
                              });
                            }
                            : null,
                    color:
                        currentPage > 0 ? const Color(0xFF729996) : Colors.grey,
                  ),

                  // Page indicator
                  Text(
                    '${currentPage + 1}/$totalPages',
                    style: const TextStyle(
                      fontFamily: 'ComicNeue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Next page button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed:
                        currentPage < totalPages - 1
                            ? () {
                              setState(() {
                                currentPage++;
                              });
                            }
                            : null,
                    color:
                        currentPage < totalPages - 1
                            ? const Color(0xFF729996)
                            : Colors.grey,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(Map<String, dynamic> achievement) {
    // Parse date from the database
    DateTime? achievementDate = _db.parseDbDate(achievement['date']);
    String formattedDate =
        achievementDate != null
            ? '${achievementDate.month.toString().padLeft(2, '0')}/${achievementDate.day.toString().padLeft(2, '0')}/${achievementDate.year}'
            : 'Unknown date';

    // Determine which badge asset to use based on color
    String badgeAsset;
    switch (achievement['badge_color']) {
      case 'blue':
        badgeAsset = 'assets/images/achievement_badge_blue.png';
        break;
      case 'green':
        badgeAsset = 'assets/images/achievement_badge_green.png';
        break;
      case 'pink':
        badgeAsset = 'assets/images/achievement_badge_pink.png';
        break;
      case 'yellow':
        badgeAsset = 'assets/images/achievement_badge_yellow.png';
        break;
      default:
        badgeAsset = 'assets/images/achievement_badge_pink.png';
    }

    return GestureDetector(
      onTap: () {
        // Show achievement details in a dialog
        if (achievement['description'] != null) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(achievement['name']),
                  content: Text(achievement['description']),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge image
          Image.asset(badgeAsset, width: 70, height: 70),

          const SizedBox(height: 4),

          // Achievement title with constrained width to prevent overflow
          SizedBox(
            width: 90,
            child: Text(
              achievement['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'ComicNeue',
              ),
            ),
          ),

          // Achievement date
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontFamily: 'ComicNeue',
            ),
          ),
        ],
      ),
    );
  }
}

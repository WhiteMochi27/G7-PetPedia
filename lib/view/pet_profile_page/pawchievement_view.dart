// Contributed by: Tong Qian Ru

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
      final pet = await _db.getPetProfileById(widget.petId);

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

      await _loadPetAndAchievements();

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
                  _buildProfileSection(),

                  _buildPawLevelBar(pawLevel, currentLevelAchievements),

                  _buildAchievementsSection(),
                ],
              ),
            ),

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

          Text(
            petData!['name'],
            style: const TextStyle(
              fontFamily: 'Baloo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Image.asset(
            'assets/images/achievement_star_bar.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ],
      ),
    );
  }

  Widget _getProfileImage() {
    if (petData!['avatar_url'] == null || petData!['avatar_url'].isEmpty) {
      return Image.asset(
        'assets/images/Pet profile pic/default.png',
        fit: BoxFit.cover,
      );
    }

    String avatarUrl = petData!['avatar_url'];

    if (avatarUrl.startsWith('assets/')) {
      return Image.asset(avatarUrl, fit: BoxFit.cover);
    } else if (avatarUrl.startsWith('/')) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading profile image: $error");
          return Image.asset(
            'assets/images/Pet profile pic/default.png',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading profile image: $error");
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
          Text(
            'Paw Level: $pawLevel',
            style: const TextStyle(
              fontFamily: 'ComicNeue',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          Stack(
            clipBehavior:
                Clip.none, 
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 15,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF729996), width: 1),
                ),
              ),

              Container(
                height: 15,
                width:
                    MediaQuery.of(context).size.width *
                    (currentLevelAchievements / 10) *
                    0.9, 
                decoration: BoxDecoration(
                  color: const Color(0xFF729996),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

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
    int startIndex = currentPage * 6;
    int endIndex = startIndex + 6;
    if (endIndex > achievements.length) {
      endIndex = achievements.length;
    }

    List<Map<String, dynamic>> currentPageAchievements = achievements.sublist(
      startIndex,
      endIndex,
    );

    int totalPages = (achievements.length / 6).ceil();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          80,
        ), 
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

            if (achievements.isNotEmpty && totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  Text(
                    '${currentPage + 1}/$totalPages',
                    style: const TextStyle(
                      fontFamily: 'ComicNeue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

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
    DateTime? achievementDate = _db.parseDbDate(achievement['date']);
    String formattedDate =
        achievementDate != null
            ? '${achievementDate.month.toString().padLeft(2, '0')}/${achievementDate.day.toString().padLeft(2, '0')}/${achievementDate.year}'
            : 'Unknown date';

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
          Image.asset(badgeAsset, width: 70, height: 70),

          const SizedBox(height: 4),

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

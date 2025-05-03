import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});
  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _avatarFile;
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  void initState() {
    super.initState();
    _loadUserAvatar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload avatar when dependencies change
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null &&
        userProvider.currentUser!.id != null) {
      Map<String, dynamic>? settings = await _dbHandler.getUserSettings(
        userProvider.currentUser!.id!,
      );

      if (settings != null && settings['avatar_path'] != null) {
        File avatarFile = File(settings['avatar_path']);
        if (await avatarFile.exists()) {
          setState(() {
            _avatarFile = avatarFile;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.currentUser?.name ?? 'Sprite Keeper';

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            PageTitle(
              icon: 'assets/images/icon_pawhub.png',
              title: 'PawHub',
              subtitle: 'Pet Profile',
            ),

            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/pettings');
                },
                child: Image.asset(
                  'assets/images/icon_settings.png',
                  width: 27,
                  height: 27,
                ),
              ),
            ),

            // Main Content
            Positioned.fill(
              top: 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Welcome Card
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi,',
                                style: TextStyle(
                                  fontFamily: "Fredoka One",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Sprite Keeper!',
                                style: TextStyle(
                                  fontFamily: "Fredoka One",
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TColor.orangePeel,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                _avatarFile != null
                                    ? Image.file(
                                      _avatarFile!,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      'assets/images/user avatar.png',
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                      ],
                    ),

                    //Fursona
                    const SizedBox(height: 24),
                    _buildNavCard(
                      context,
                      image: 'assets/images/home_fursona.png',
                      route: '/fursona',
                      fullWidth: true,
                    ),
                    const SizedBox(height: 12),

                    //Pawtection, WoofnWalk, Furstaid
                    Row(
                      children: [
                        Expanded(
                          child: _buildNavCard(
                            context,
                            image: 'assets/images/home_pawtection.png',
                            route: '/pawtection',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildNavCard(
                            context,
                            image: 'assets/images/home_woofnwalk.png',
                            route: '/woofnwalk',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildNavCard(
                            context,
                            image: 'assets/images/home_furstaid.png',
                            route: '/furstaid',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    //BarkBot and Petsonal Hub
                    Row(
                      children: [
                        Expanded(
                          child: _buildNavCard(
                            context,
                            image: 'assets/images/home_barkbot.png',
                            route: '/barkbot',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildNavCard(
                            context,
                            image: 'assets/images/home_petsonalhub.png',
                            route: '/petsonalhub',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    //Feedback
                    _buildNavCard(
                      context,
                      image: 'assets/images/home_pawprints.png',
                      route: '/pawprints',
                      fullWidth: true,
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String image,
    required String route,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: fullWidth ? double.infinity : null,
        margin: fullWidth ? const EdgeInsets.symmetric(vertical: 4.0) : null,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(57, 81, 66, 66),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                image,
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.arrow_forward, color: TColor.black, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

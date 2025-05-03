import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';

class PettingsView extends StatefulWidget {
  const PettingsView({super.key});

  @override
  State<PettingsView> createState() => _PettingsViewState();
}

class _PettingsViewState extends State<PettingsView> {
  final List<Map<String, dynamic>> settingsItems = [
    {
      'icon': 'assets/images/about_us.png',
      'title': 'About Us',
      'isExpanded': false,
      'content':
          'PetPedia is your go-to app for all pet-related information. We are dedicated to helping pet owners provide the best care for their beloved animals.',
    },
    {
      'icon': 'assets/images/privacy_policy.png',
      'title': 'Privacy Policy',
      'isExpanded': false,
      'content':
          'We respect your privacy and are committed to protecting your personal data. Our privacy policy outlines how we collect, use, and safeguard your information.',
    },
    {
      'icon': 'assets/images/terms_conditions.png',
      'title': 'Terms & Conditions',
      'isExpanded': false,
      'content':
          'By using PetPedia, you agree to our terms and conditions. These terms govern your use of our application and services.',
    },
    {
      'icon': 'assets/images/sign_out.png',
      'title': 'Sign out',
      'isExpanded': false,
      'content': '',
    },
  ];

  final List<Map<String, String>> socialMedia = [
    {'icon': 'assets/images/fb_logo.png', 'url': 'facebook_url'},
    {'icon': 'assets/images/ig_logo.png', 'url': 'instagram_url'},
    {'icon': 'assets/images/x_logo.png', 'url': 'twitter_url'},
  ];

  @override
  Widget build(BuildContext context) {
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
              icon: 'assets/images/icon_settings.png',
              title: 'Pettings',
              subtitle: 'Settings',
            ),

            Positioned.fill(
              top: 120,
              left: 20,
              right: 20,
              bottom: 100,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: settingsItems.length,
                      itemBuilder: (context, index) {
                        final item = settingsItems[index];
                        if (item['title'] == 'Sign out') {
                          return _buildSettingButton(
                            icon: item['icon'] ?? '',
                            title: item['title'] ?? '',
                            onTap:
                                () => _handleSettingsTap(item['title'] ?? ''),
                          );
                        } else {
                          return _buildExpandableSettingItem(index);
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Follow Us',
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: TColor.black,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            'Version',
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: TColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 2,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFA7AEF9), Color(0xFF3996E2)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children:
                              socialMedia
                                  .map(
                                    (social) => _buildSocialButton(
                                      social['icon'] ?? '',
                                    ),
                                  )
                                  .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '1.0',
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 14,
                              color: TColor.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSettingItem(int index) {
    final item = settingsItems[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA7AEF9), Color(0xFF3996E2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: TColor.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    item['isExpanded'] = !(item['isExpanded'] ?? false);
                  });
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item['icon'],
                        width: 24,
                        height: 24,
                        color: TColor.black,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['title'],
                          style: TextStyle(
                            fontFamily: "ComicNeue",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: TColor.black,
                          ),
                        ),
                      ),
                      Icon(
                        item['isExpanded']
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: TColor.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (item['isExpanded'])
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3996E2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item['content'],
                style: TextStyle(
                  fontFamily: "ComicNeue",
                  fontSize: 16,
                  color: TColor.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingButton({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA7AEF9), Color(0xFF3996E2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: TColor.black.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  Image.asset(icon, width: 24, height: 24, color: TColor.black),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "ComicNeue",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColor.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(iconPath, width: 28, height: 28),
        ),
      ),
    );
  }

  void _handleSettingsTap(String title) {
    switch (title) {
      case 'About Us':
        Navigator.pushNamed(context, '/about');
        break;
      case 'Privacy Policy':
        Navigator.pushNamed(context, '/privacy');
        break;
      case 'Terms & Conditions':
        Navigator.pushNamed(context, '/terms');
        break;
      case 'Sign out':
        _showSignOutDialog();
        break;
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

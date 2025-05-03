import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';

class RegisterSuccessView extends StatefulWidget {
  const RegisterSuccessView({super.key});

  @override
  State<RegisterSuccessView> createState() => _RegisterSuccessViewState();
}

class _RegisterSuccessViewState extends State<RegisterSuccessView>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Mark animation as initialized
    setState(() {
      _isAnimationInitialized = true;
    });

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_content.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Paw prints - kept as in original
          Positioned(
            top: 60,
            left: 20,
            child: Image.asset(
              'assets/images/paw.png',
              width: 100,
              height: 100,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          Positioned(
            bottom: 250,
            right: 10,
            child: Image.asset(
              'assets/images/paw.png',
              width: 100,
              height: 100,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 40,
            child: Image.asset(
              'assets/images/paw.png',
              width: 100,
              height: 100,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),

          SafeArea(
            child:
                _isAnimationInitialized
                    ? _buildAnimatedContent()
                    : _buildStaticContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContent() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(
                      child: Image(
                        image: AssetImage(
                          'assets/images/account_creation_badge.png',
                        ),
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Success image
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          const Image(
                            image: AssetImage(
                              'assets/images/account_creation_success.png',
                            ),
                            width: 500,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            left: 60,
                            bottom: -30,
                            child: const Image(
                              image: AssetImage('assets/images/pet_food.png'),
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Text content
                  Text(
                    'Account Created!',
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: TColor.black,
                    ),
                  ),
                  Text(
                    'Welcome to PetPedia!',
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: TColor.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "You're all set! Let's start exploring and taking care of your furry friend.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 16,
                        color: TColor.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Button with fade animation
        FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.jellyfish,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Start Exploring!',
                  style: TextStyle(
                    fontFamily: "Fredoka One",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColor.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticContent() {
    // This is a fallback that will be shown while the animation is initializing
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const Center(
                    child: Image(
                      image: AssetImage(
                        'assets/images/account_creation_badge.png',
                      ),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Success image
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        const Image(
                          image: AssetImage(
                            'assets/images/account_creation_success.png',
                          ),
                          width: 500,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          left: 60,
                          bottom: -30,
                          child: const Image(
                            image: AssetImage('assets/images/pet_food.png'),
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),

                const SizedBox(height: 24),

                // Text content
                Text(
                  'Account Created!',
                  style: TextStyle(
                    fontFamily: "Baloo",
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
                Text(
                  'Welcome to PetPedia!',
                  style: TextStyle(
                    fontFamily: "Baloo",
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: TColor.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "You're all set! Let's start exploring and taking care of your furry friend.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Baloo",
                      fontSize: 16,
                      color: TColor.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Button
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.jellyfish,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              child: Text(
                'Start Exploring!',
                style: TextStyle(
                  fontFamily: "Fredoka One",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

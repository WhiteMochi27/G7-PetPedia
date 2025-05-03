// Contributed by: Davin Cheong, Tong Qian Ru

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:petpedia/view/chatbot/barkbot_view.dart';
import 'package:petpedia/view/emergency&vet_assistance/furstaid_view.dart';
import 'package:petpedia/view/homepage/pawprints_view.dart';
import 'package:petpedia/view/health&wellness/pawtection_view.dart';
import 'package:petpedia/view/account_centre/petsonalhub_view.dart';
import 'package:petpedia/view/exercise&feeding_tracking/woofnwalk_view.dart';
import 'package:petpedia/view/splash_screen/splash_screen.dart';
import 'package:petpedia/view/homepage/homepage_view.dart';
import 'package:petpedia/view/pet_profile_page/fursona_view.dart';
import 'package:petpedia/view/chatbot/providers/chat_provider.dart';
import 'package:petpedia/view/settings/pettings_view.dart';
import 'package:petpedia/view/register&login/login.dart';
import 'package:petpedia/view/register&login/register.dart';
import 'package:petpedia/view/register&login/register_success.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/services/auth_service.dart';
import 'package:petpedia/models/user_model.dart';
import 'package:petpedia/providers/user_provider.dart';

void main() async {
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  DatabaseHandler dbHandler = DatabaseHandler();
  await dbHandler.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Pet Pedia',
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/register_success': (context) => const RegisterSuccessView(),
          '/home': (context) => const HomeScreen(),
          '/pettings': (context) => const PettingsView(),
          '/fursona': (context) => const FursonaView(),
          '/pawtection': (context) => const PawtectionView(),
          '/woofnwalk': (context) => const WoofnwalkView(),
          '/furstaid': (context) => const FurstaidView(),
          '/barkbot': (context) => const BarkBotView(),
          '/petsonalhub': (context) {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            if (userProvider.currentUser == null) {
              // If no user, redirect to login
              return const LoginView();
            }
            return PetsonalhubView(user: userProvider.currentUser!);
          },
          '/pawprints': (context) => const PawprintsView(),
        },
      ),
    );
  }
}

class PetsonalhubViewWrapper extends StatelessWidget {
  const PetsonalhubViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.currentUser != null) {
      // If user is already loaded in provider
      return PetsonalhubView(user: userProvider.currentUser!);
    } else {
      // Otherwise fetch user and show loading
      return FutureBuilder<User?>(
        future: _getUserFromAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          } else if (snapshot.hasData && snapshot.data != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.setUser(snapshot.data!);
            });
            return PetsonalhubView(user: snapshot.data!);
          } else {
            print("No user found, redirecting to login");

            // No user found, redirect to login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });

            return Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_content.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(child: Text('Redirecting to login...')),
              ),
            );
          }
        },
      );
    }
  }

  Future<User?> _getUserFromAuth() async {
    final AuthService authService = AuthService();
    return await authService.getRememberedUser();
  }
}

import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:petpedia/providers/user_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkRememberedUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkRememberedUser() async {
    final rememberedUser = await _authService.getRememberedUser();
    if (rememberedUser != null) {
      _emailController.text = rememberedUser.email;
      _rememberMe = true;
      setState(() {});
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        // Get the UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Set the user
        userProvider.setUser(user);
        // Navigate to home screen if login successful
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool isEmailVerified = false;
    bool isResetting = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEmailVerified ? 'Reset Password' : 'Forgot Password',
                style: const TextStyle(
                  fontFamily: "Baloo",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: "ComicNeue",
                          ),
                        ),
                      ),

                    if (!isEmailVerified)
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/images/icon_email.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: "ComicNeue",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColor.black,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isResetting,
                      )
                    else
                      Column(
                        children: [
                          TextField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'New Password',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/images/icon_password.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TColor.black,
                            ),
                            enabled: !isResetting,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Confirm New Password',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  'assets/images/icon_password.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: "ComicNeue",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TColor.black,
                            ),
                            enabled: !isResetting,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                if (isResetting)
                  Center(
                    child: CircularProgressIndicator(color: TColor.jellyfish),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: "ComicNeue",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: TColor.gray,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (!isEmailVerified) {
                            // Verify email exists
                            if (emailController.text.isEmpty) {
                              setState(() {
                                errorMessage = 'Please enter your email';
                              });
                              return;
                            }

                            setState(() {
                              isResetting = true;
                              errorMessage = null;
                            });

                            // Use the AuthService method instead of direct access
                            bool exists = await _authService.checkEmailExists(
                              emailController.text.trim(),
                            );

                            setState(() {
                              isResetting = false;
                            });

                            if (exists) {
                              setState(() {
                                isEmailVerified = true;
                                errorMessage = null;
                              });
                            } else {
                              setState(() {
                                errorMessage = 'Email not found';
                              });
                            }
                          } else {
                            // Reset password
                            if (newPasswordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty) {
                              setState(() {
                                errorMessage = 'Please fill in all fields';
                              });
                              return;
                            }

                            if (newPasswordController.text !=
                                confirmPasswordController.text) {
                              setState(() {
                                errorMessage = 'Passwords do not match';
                              });
                              return;
                            }

                            setState(() {
                              isResetting = true;
                              errorMessage = null;
                            });

                            bool success = await _authService.resetPassword(
                              email: emailController.text.trim(),
                              newPassword: newPasswordController.text,
                            );

                            if (success) {
                              Navigator.of(context).pop();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password reset successful! Please login with your new password.',
                                    style: TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontSize: 14,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              setState(() {
                                isResetting = false;
                                errorMessage =
                                    'Failed to reset password. Please try again.';
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.jellyfish,
                          foregroundColor: TColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          isEmailVerified ? 'Reset Password' : 'Continue',
                          style: const TextStyle(
                            fontFamily: "Fredoka One",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_content.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TColor.butteryWhite.withOpacity(0.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontFamily: "Baloo",
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'PetPal',
                                          style: TextStyle(
                                            fontFamily: "Baloo",
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          'assets/images/tdesign_wave-bye.png',
                                          width: 27,
                                          height: 27,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Meow meow!',
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          'assets/images/solar_cat-broken.png',
                                          width: 17,
                                          height: 17,
                                        ),
                                        const Text(
                                          ' Woof Woof!',
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          'assets/images/lucide_dog.png',
                                          width: 17,
                                          height: 17,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Image.asset(
                                      'assets/images/paw.png',
                                      width: 120,
                                      height: 120,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Display error message if any
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontFamily: "ComicNeue",
                                  ),
                                ),
                              ),

                            // Email field
                            Container(
                              decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColor.gray.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _emailController,
                                // TextStyle that users type
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'E-Mail',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icon_email.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: TColor.gray.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _passwordController,
                                // TextStyle that users type
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.black,
                                ),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icon_password.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Remember Me and Forgot Password
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text(
                                  'Meow Me',
                                  style: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _showForgotPasswordDialog();
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: TColor.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 100),

                            // Sign in button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.jellyfish,
                                foregroundColor: TColor.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: TColor.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontFamily: "Fredoka One",
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),

                            const SizedBox(height: 16),

                            // Create account button
                            OutlinedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TColor.orangePeel,
                                side: BorderSide(color: TColor.orangePeel),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: "Fredoka One",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: TColor.orangePeel,
                                ),
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
          ),
        ],
      ),
    );
  }
}

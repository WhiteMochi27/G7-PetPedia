import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:country_picker/country_picker.dart';
import 'package:petpedia/services/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _termsAccepted = false;
  bool _tipsAccepted = false;
  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  Country? _selectedCountry;
  String _countryFlag = "🌎";
  String _countryCode = "+";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Attempt to register the user
      bool success = await _authService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _countryCode + _phoneNumberController.text.trim(),
        country: _selectedCountry?.name,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Navigate to success screen
        Navigator.pushNamed(context, '/register_success');
      } else {
        setState(() {
          _errorMessage = 'This email is already registered';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during registration';
        _isLoading = false;
      });
    }
  }

  bool _validateInputs() {
    // Reset error message
    setState(() {
      _errorMessage = null;
    });

    // Check if fields are empty
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedCountry == null ||
        _phoneNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return false;
    }

    // Check password length
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return false;
    }

    // Check terms acceptance
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'You must accept the terms and conditions';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/images/icon_back.png',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_content.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
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
                                const Text(
                                  'Register an account',
                                  style: TextStyle(
                                    fontFamily: "Baloo",
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    left: 2,
                                  ),
                                  child: Image.asset(
                                    'assets/images/register_paw.png',
                                    width: 30,
                                    height: 30,
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

                            // Full Name field
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
                                controller: _nameController,
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  color: TColor.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 16,
                                    color: TColor.black,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icon-park-solid_edit-name.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                            ),

                            const SizedBox(height: 16),

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
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  color: TColor.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'E-Mail',
                                  hintStyle: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 16,
                                    color: TColor.black,
                                  ),
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
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  color: TColor.black,
                                ),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 16,
                                    color: TColor.black,
                                  ),
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

                            const SizedBox(height: 16),

                            // Confirm Password field
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
                                controller: _confirmPasswordController,
                                style: TextStyle(
                                  fontFamily: "ComicNeue",
                                  fontSize: 16,
                                  color: TColor.black,
                                ),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: TextStyle(
                                    fontFamily: "ComicNeue",
                                    fontSize: 16,
                                    color: TColor.black,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      'assets/images/icon_password.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Country dropdown field
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
                              child: InkWell(
                                onTap: () {
                                  showCountryPicker(
                                    context: context,
                                    showPhoneCode: true,
                                    onSelect: (Country country) {
                                      setState(() {
                                        _selectedCountry = country;
                                        _countryFlag = country.flagEmoji;
                                        _countryCode = '+${country.phoneCode}';
                                      });
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                        ),
                                        child: Image.asset(
                                          'assets/images/country.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      Text(
                                        _selectedCountry?.name ?? 'Country',
                                        style: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontSize: 16,
                                          color: TColor.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (_selectedCountry != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          child: Text(
                                            _countryFlag,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      const Icon(Icons.arrow_drop_down),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Phone number field with country code
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
                              child: Row(
                                children: [
                                  // Country code prefix
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(left: 12),
                                    child: Row(
                                      children: [
                                        Text(
                                          _countryFlag,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _countryCode,
                                          style: TextStyle(
                                            fontFamily: "ComicNeue",
                                            fontSize: 16,
                                            color: TColor.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Vertical divider
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: TColor.gray,
                                  ),
                                  // Phone number field
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneNumberController,
                                      decoration: InputDecoration(
                                        hintText: 'Phone',
                                        hintStyle: TextStyle(
                                          fontFamily: "ComicNeue",
                                          fontSize: 16,
                                          color: TColor.black,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 16,
                                              horizontal: 12,
                                            ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            Row(
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: "ComicNeue",
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: TColor.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              'By joining Petpedia, you agree to our ',
                                        ),
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                            color: TColor.jellyfish,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: TColor.jellyfish,
                                          ),
                                        ),
                                        const TextSpan(text: '. Woof!'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Checkbox(
                                  value: _tipsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _tipsAccepted = value ?? false;
                                    });
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Stay in the loop! Get pet care tips, news and promotions (you can opt-out anytime).',
                                    style: TextStyle(
                                      fontFamily: "ComicNeue",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 50),

                            // Create account button
                            OutlinedButton(
                              onPressed: _isLoading ? null : _register,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: TColor.orangePeel,
                                backgroundColor: TColor.orangePeel,
                                side: BorderSide(color: TColor.orangePeel),
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
                                      : Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontFamily: "Fredoka One",
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: TColor.white,
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

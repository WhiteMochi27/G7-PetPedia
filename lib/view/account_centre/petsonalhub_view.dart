import 'package:flutter/material.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/view/splash_screen/splash_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:petpedia/services/auth_service.dart';
import 'package:petpedia/models/user_model.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:petpedia/providers/user_provider.dart';

class PetsonalhubView extends StatefulWidget {
  final User user;

  const PetsonalhubView({super.key, required this.user});

  @override
  State<PetsonalhubView> createState() => _PetsonalhubViewState();
}

class _PetsonalhubViewState extends State<PetsonalhubView> {
  bool _isEditing = false;
  bool _isRemovePressed = false;
  bool _notificationsEnabled = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  final DatabaseHandler _dbHandler = DatabaseHandler();
  late User _currentUser;

  bool _isUserDataLoaded = false;

  // Controllers for edit mode
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadUserSettings();

    _usernameController = TextEditingController(text: _currentUser.name);
    _emailController = TextEditingController(text: _currentUser.email);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // If user already has an avatar path, use it
    if (_currentUser.avatarPath != null) {
      _imageFile = File(_currentUser.avatarPath!);
    } else {
      // Otherwise load from database
      _loadUserAvatar();
    }
  }

  Future<void> _loadUserSettings() async {
    if (_currentUser.id != null) {
      // Get notification settings
      Map<String, bool> notificationSettings = await _dbHandler
          .getNotificationSettings(_currentUser.id!);

      setState(() {
        // We'll just use 'general' for the main notification toggle
        _notificationsEnabled = notificationSettings['general'] ?? true;
        // Mark user data as loaded
        _isUserDataLoaded = true;
      });
    } else {
      // If there's no user ID, set the flag to prevent loading
      setState(() {
        _isUserDataLoaded = false;
      });
    }
  }

  Future<void> _loadUserAvatar() async {
    if (_currentUser.id != null) {
      Map<String, dynamic>? settings = await _dbHandler.getUserSettings(
        _currentUser.id!,
      );

      if (settings != null && settings['avatar_path'] != null) {
        File avatarFile = File(settings['avatar_path']);
        if (await avatarFile.exists()) {
          setState(() {
            _imageFile = avatarFile;

            // Update the current user with the avatar path
            _currentUser = _currentUser.copyWith(
              avatarPath: settings['avatar_path'],
            );

            // Update UserProvider
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).setUser(_currentUser);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current user from provider to ensure we have the latest
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null &&
        userProvider.currentUser!.id != null) {
      if (_currentUser.id != userProvider.currentUser!.id) {
        setState(() {
          _currentUser = userProvider.currentUser!;
          _usernameController.text = _currentUser.name;
          _emailController.text = _currentUser.email;
          _loadUserSettings();
          _loadUserAvatar();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have a valid user with an ID
    if (_currentUser.id == null) {
      // If there's no user ID, we should redirect to login
      // But we'll use a delayed action to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if user provider has a valid user
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.currentUser != null &&
            userProvider.currentUser!.id != null) {
          // If user provider has a valid user, update our local user
          setState(() {
            _currentUser = userProvider.currentUser!;
            _loadUserSettings();
            _loadUserAvatar();
          });
        } else {
          // If there's no valid user, navigate to login
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      });

      // Show loading indicator while checking
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_content.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Remove the AppBar completely
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              const PageTitle(
                icon: 'assets/images/icon_petsonalhub.png',
                title: 'Petsonal Hub',
                subtitle: 'Account Center',
              ),

              // Main Content Container to ensure all content is visible
              Positioned.fill(
                top: 100,
                bottom: 70, // Ensure there's space for the home button
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture and Paw Section
                      _buildProfileSection(),

                      // Edit/Save Buttons - moved to below profile section
                      _buildEditButtons(),

                      const SizedBox(height: 20),

                      // User Info Form
                      _buildUserInfoForm(),

                      const SizedBox(height: 30),

                      // Delete Account Button
                      GestureDetector(
                        onTapDown:
                            (_) => setState(() => _isRemovePressed = true),
                        onTapUp:
                            (_) => setState(() => _isRemovePressed = false),
                        onTapCancel:
                            () => setState(() => _isRemovePressed = false),
                        onTap: () => _showDeleteConfirmation(context),
                        child: Container(
                          width: screenWidth * 0.8, // 80% of screen width
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  'Delete Account',
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

              // Home Button - make sure it's at the very bottom
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: HomeButton(),
              ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildProfileSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar section with change button
        Stack(
          children: [
            // Avatar Circle - made larger
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD700), width: 4),
              ),
              child: ClipOval(
                child:
                    _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Image.asset(
                          'assets/images/user avatar.png',
                          fit: BoxFit.cover,
                        ),
              ),
            ),

            // Change Avatar Button (only in edit mode)
            if (_isEditing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfilePicture,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Change Avatar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Baloo',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            'assets/images/paw.png',
            width: 120, // Increased from 60 to 120 (80% of 150)
            height: 120, // Increased from 60 to 120
          ),
        ),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Right alignment
        children:
            _isEditing
                ? [
                  IconButton(
                    icon: Image.asset(
                      'assets/images/icon_cancel.png',
                      width: 25,
                      height: 25,
                    ),
                    onPressed: _cancelEditing,
                    tooltip: 'Cancel',
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/images/icon_save.png',
                      width: 25,
                      height: 25,
                    ),
                    onPressed: _saveChanges,
                    tooltip: 'Save',
                  ),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _startEditing,
                    tooltip: 'Edit',
                  ),
                ],
      ),
    );
  }

  Widget _buildUserInfoForm() {
    return Column(
      children: [
        // Username Field
        _buildDetailRow('Username', _currentUser.name, _usernameController),

        // Email Field
        _buildDetailRow('Email', _currentUser.email, _emailController),

        // Password Fields - show differently based on edit mode
        if (!_isEditing)
          _buildDetailRow('Password', 'xxxxxxxxx', null)
        else
          Column(
            children: [
              _buildDetailRow(
                'Old\nPassword',
                '',
                _oldPasswordController,
                isPassword: true,
              ),
              _buildDetailRow(
                'New\nPassword',
                '',
                _newPasswordController,
                isPassword: true,
              ),
              _buildDetailRow(
                'Confirm\nPassword',
                '',
                _confirmPasswordController,
                isPassword: true,
              ),
            ],
          ),

        // Notification Toggle
        _buildNotificationRow(),
      ],
    );
  }

  Widget _buildDetailRow(
    String title,
    String value,
    TextEditingController? controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child:
                  _isEditing && controller != null
                      ? TextFormField(
                        controller: controller,
                        obscureText: isPassword,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      )
                      : Text(
                        // Show masked text for password
                        isPassword ? 'xxxxxxxxx' : value,
                        style: const TextStyle(
                          fontFamily: 'ComicNeue',
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              'Notification',
              style: TextStyle(
                fontFamily: 'Baloo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCE7).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _notificationsEnabled ? 'Enable' : 'Disable',
                    style: const TextStyle(
                      fontFamily: 'ComicNeue',
                      fontSize: 16,
                    ),
                  ),
                  if (_isEditing)
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                      activeColor: const Color(0xFFC89484),
                      activeTrackColor: const Color(0xFF729996),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Show error dialog or message
      print("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error selecting image: $e")));
    }
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      // Reset controller values to original data
      _usernameController.text = _currentUser.name;
      _emailController.text = _currentUser.email;
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // If we have a new image file but haven't saved, revert to the original
      _loadUserAvatar();
    });
  }

  Future<void> _saveChanges() async {
    // Validate form inputs
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty')),
      );
      return;
    }

    // Check if trying to change password
    bool isChangingPassword =
        _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    if (isChangingPassword) {
      // Validate new passwords match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }

      // Verify old password
      final authResult = await _authService.loginUser(
        email: _currentUser.email,
        password: _oldPasswordController.text,
      );

      if (authResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current password is incorrect')),
        );
        return;
      }

      // Update password
      await _authService.resetPassword(
        email: _currentUser.email,
        newPassword: _newPasswordController.text,
      );
    }

    // Update user name (if changed)
    if (_usernameController.text != _currentUser.name ||
        _emailController.text != _currentUser.email) {
      // Email can't be changed to an existing email
      if (_emailController.text != _currentUser.email) {
        bool emailExists = await _authService.checkEmailExists(
          _emailController.text,
        );
        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already in use by another account'),
            ),
          );
          return;
        }
      }

      // Update user data in database
      await _dbHandler.insertUser({
        'id': _currentUser.id,
        'name': _usernameController.text,
        'email': _emailController.text,
        'password': _currentUser.password, // Don't change password here
        'phone': _currentUser.phone,
        'country': _currentUser.country,
        'remember_me': _currentUser.rememberMe ? 1 : 0,
      });

      // Update local user object
      _currentUser = _currentUser.copyWith(
        name: _usernameController.text,
        email: _emailController.text,
      );
    }

    String? updatedAvatarPath = _currentUser.avatarPath;

    // Save profile picture if changed
    if (_imageFile != null && _currentUser.id != null) {
      // Save image to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'user_${_currentUser.id}_avatar.jpg';
      final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

      // Update avatar path in database
      await _dbHandler.updateUserAvatar(_currentUser.id!, savedImage.path);

      // Update avatar path for user model
      updatedAvatarPath = savedImage.path;
    }

    // Update notification settings
    if (_currentUser.id != null) {
      await _dbHandler.updateNotificationSettings(
        _currentUser.id!,
        'general',
        _notificationsEnabled,
      );
    }

    // Update local user object with avatar path and notification settings
    _currentUser = _currentUser.copyWith(
      avatarPath: updatedAvatarPath,
      notificationsEnabled: _notificationsEnabled,
    );

    // Update the UserProvider with the updated user
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(_currentUser);

    // Update local state
    setState(() {
      _isEditing = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account information updated successfully!'),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Baloo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(fontFamily: 'ComicNeue', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Baloo', color: Color(0xFF729996)),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Delete user from database
                if (_currentUser.id != null) {
                  final db = await _dbHandler.database;

                  // Delete user settings first due to foreign key constraint
                  await db.delete(
                    'user_settings',
                    where: 'user_id = ?',
                    whereArgs: [_currentUser.id],
                  );

                  // Delete user
                  await db.delete(
                    'users',
                    where: 'id = ?',
                    whereArgs: [_currentUser.id],
                  );

                  // Delete avatar file if exists
                  if (_imageFile != null && await _imageFile!.exists()) {
                    await _imageFile!.delete();
                  }
                }

                // Navigate to splash screen after confirming deletion
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Baloo', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

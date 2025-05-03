// Contributed by: Tong Qian Ru

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

    if (_currentUser.avatarPath != null) {
      _imageFile = File(_currentUser.avatarPath!);
    } else {
      _loadUserAvatar();
    }
  }

  Future<void> _loadUserSettings() async {
    if (_currentUser.id != null) {
      Map<String, bool> notificationSettings = await _dbHandler
          .getNotificationSettings(_currentUser.id!);

      setState(() {
        _notificationsEnabled = notificationSettings['general'] ?? true;
      });
    } else {
      setState(() {
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

            _currentUser = _currentUser.copyWith(
              avatarPath: settings['avatar_path'],
            );

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
    if (_currentUser.id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.currentUser != null &&
            userProvider.currentUser!.id != null) {
          setState(() {
            _currentUser = userProvider.currentUser!;
            _loadUserSettings();
            _loadUserAvatar();
          });
        } else {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      });

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
              const PageTitle(
                icon: 'assets/images/icon_petsonalhub.png',
                title: 'Petsonal Hub',
                subtitle: 'Account Center',
              ),

              Positioned.fill(
                top: 100,
                bottom: 70, 
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileSection(),

                      _buildEditButtons(),

                      const SizedBox(height: 20),

                      _buildUserInfoForm(),

                      const SizedBox(height: 30),

                      GestureDetector(
                        onTapDown:
                            (_) => setState(() => _isRemovePressed = true),
                        onTapUp:
                            (_) => setState(() => _isRemovePressed = false),
                        onTapCancel:
                            () => setState(() => _isRemovePressed = false),
                        onTap: () => _showDeleteConfirmation(context),
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
        Stack(
          children: [
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
            width: 120, 
            height: 120, 
          ),
        ),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, 
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
        _buildDetailRow('Username', _currentUser.name, _usernameController),

        _buildDetailRow('Email', _currentUser.email, _emailController),

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
      _usernameController.text = _currentUser.name;
      _emailController.text = _currentUser.email;
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _loadUserAvatar();
    });
  }

  Future<void> _saveChanges() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty')),
      );
      return;
    }

    bool isChangingPassword =
        _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    if (isChangingPassword) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }

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

      await _authService.resetPassword(
        email: _currentUser.email,
        newPassword: _newPasswordController.text,
      );
    }

    if (_usernameController.text != _currentUser.name ||
        _emailController.text != _currentUser.email) {
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

      await _dbHandler.insertUser({
        'id': _currentUser.id,
        'name': _usernameController.text,
        'email': _emailController.text,
        'password': _currentUser.password, 
        'phone': _currentUser.phone,
        'country': _currentUser.country,
        'remember_me': _currentUser.rememberMe ? 1 : 0,
      });

      _currentUser = _currentUser.copyWith(
        name: _usernameController.text,
        email: _emailController.text,
      );
    }

    String? updatedAvatarPath = _currentUser.avatarPath;

    if (_imageFile != null && _currentUser.id != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'user_${_currentUser.id}_avatar.jpg';
      final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

      await _dbHandler.updateUserAvatar(_currentUser.id!, savedImage.path);

      updatedAvatarPath = savedImage.path;
    }

    if (_currentUser.id != null) {
      await _dbHandler.updateNotificationSettings(
        _currentUser.id!,
        'general',
        _notificationsEnabled,
      );
    }

    _currentUser = _currentUser.copyWith(
      avatarPath: updatedAvatarPath,
      notificationsEnabled: _notificationsEnabled,
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(_currentUser);

    setState(() {
      _isEditing = false;
    });

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
                if (_currentUser.id != null) {
                  final db = await _dbHandler.database;

                  await db.delete(
                    'user_settings',
                    where: 'user_id = ?',
                    whereArgs: [_currentUser.id],
                  );

                  await db.delete(
                    'users',
                    where: 'id = ?',
                    whereArgs: [_currentUser.id],
                  );

                  if (_imageFile != null && await _imageFile!.exists()) {
                    await _imageFile!.delete();
                  }
                }

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

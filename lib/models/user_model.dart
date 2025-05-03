class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? country;
  final bool rememberMe;
  final String? avatarPath;
  final bool notificationsEnabled;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.country,
    this.rememberMe = false,
    this.avatarPath,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'country': country,
      'remember_me': rememberMe ? 1 : 0,
    };
  }

  Map<String, dynamic> toSettingsMap() {
    return {
      'user_id': id,
      'avatar_path': avatarPath,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'],
      country: map['country'],
      rememberMe: map['remember_me'] == 1,
      avatarPath: map['avatar_path'],
      notificationsEnabled: map['notifications_enabled'] == 1,
    );
  }
  
  // Create a copy of user with modified fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? country,
    bool? rememberMe,
    String? avatarPath,
    bool? notificationsEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      rememberMe: rememberMe ?? this.rememberMe,
      avatarPath: avatarPath ?? this.avatarPath,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:petpedia/view/exercise&feeding_tracking/woofnwalk_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  factory DatabaseHandler() => _instance;
  DatabaseHandler._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'petpedia.db');

    bool exists = await databaseExists(path);

    if (exists) {
      try {
        Database db = await openDatabase(path);
        await db.query('users', limit: 1);
        await db.close();
      } catch (e) {
        await deleteDatabase(path);
        exists = false;
      }
    }

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT,
        country TEXT,
        remember_me INTEGER DEFAULT 0
      )
    ''');

        await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        avatar_path TEXT,
        notification_general INTEGER DEFAULT 1,
        notification_promotions INTEGER DEFAULT 1,
        notification_security INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Create pet_profile table (to avoid conflict with existing 'pets' table)
    await db.execute('''
      CREATE TABLE pet_profile(
        pet_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        breed TEXT NOT NULL,
        species TEXT NOT NULL,
        gender TEXT NOT NULL,
        neutered TEXT,
        weight REAL,
        dob TEXT,
        avatar_url TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create characteristics table
    await db.execute('''
      CREATE TABLE characteristics(
        char_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        percentage REAL NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pet_profile (pet_id) ON DELETE CASCADE
      )
    ''');

    // Create album table
    await db.execute('''
      CREATE TABLE album(
        album_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        created_date TEXT NOT NULL,
        FOREIGN KEY (pet_id) REFERENCES pet_profile (pet_id) ON DELETE CASCADE
      )
    ''');

    // Create image table
    await db.execute('''
      CREATE TABLE image(
        image_id INTEGER PRIMARY KEY AUTOINCREMENT,
        album_id INTEGER NOT NULL,
        image_url TEXT NOT NULL,
        caption TEXT,
        date_added TEXT NOT NULL,
        FOREIGN KEY (album_id) REFERENCES album (album_id) ON DELETE CASCADE
      )
    ''');

    // Create achievements table
    await db.execute('''
      CREATE TABLE achievements(
        achievement_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        badge_color TEXT,
        FOREIGN KEY (pet_id) REFERENCES pet_profile (pet_id) ON DELETE CASCADE
      )
    ''');

    // Create pets table
    await db.execute('''
      CREATE TABLE pets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        currentDistance REAL NOT NULL,
        distanceGoal REAL NOT NULL,
        activeMinutes INTEGER NOT NULL,
        activeGoal INTEGER NOT NULL,
        foodConsumed REAL NOT NULL,
        foodGoal REAL NOT NULL,
        waterConsumed REAL NOT NULL,
        waterGoal REAL NOT NULL
      )
    ''');

    // Create activities table
    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        timeHour INTEGER NOT NULL,
        timeMinute INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        distanceContribution REAL NOT NULL,
        minutesContribution INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // Create feeding schedule table
    await db.execute('''
      CREATE TABLE feeding_schedule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        mealName TEXT NOT NULL,
        time TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        portion REAL NOT NULL,
        waterConsumed REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // Create dietary preferences table
    await db.execute('''
      CREATE TABLE dietary_preferences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        petId INTEGER NOT NULL,
        foodType TEXT NOT NULL,
        allergies TEXT NOT NULL,
        specialNotes TEXT NOT NULL,
        FOREIGN KEY (petId) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    //firstaid table
    await db.execute('''
      CREATE TABLE firstaid (
        firstaid_id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstaid_title TEXT,
        firstaid_status BOOLEAN DEFAULT 0
      )
    ''');
    await _insertDefaultFirstAidItems(db);

    //emergency table
    await db.execute('''
      CREATE TABLE emergency (
        emergency_id INTEGER PRIMARY KEY AUTOINCREMENT,
        emergency_title TEXT,
        emergency_desc TEXT,
        emergency_cat VARCHAR
      )
    ''');
    await _insertDefaultEmergencyTips(db);

    // Create reminder table
    await db.execute('''
      CREATE TABLE reminder (
        reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        reminder_datetime TEXT NOT NULL,
        reminder_location TEXT,
        reminder_cat TEXT NOT NULL,
        reminder_desc TEXT,
        activity_name TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // Create medication table
    await db.execute('''
      CREATE TABLE medication (
        medication_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        medication_datetime TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        medication_dose TEXT NOT NULL,
        medication_status INTEGER NOT NULL DEFAULT 0,
        medication_cat TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');

    // Create allergic table
    await db.execute('''
      CREATE TABLE allergic (
        allergic_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        allergic_datetime TEXT NOT NULL,
        allergic_name TEXT NOT NULL,
        allergic_reaction TEXT,
        FOREIGN KEY (pet_id) REFERENCES pets (id) ON DELETE CASCADE
      )
    ''');
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> updateRememberMe(String email, bool rememberMe) async {
    Database db = await database;
    int count = await db.update(
      'users',
      {'remember_me': rememberMe ? 1 : 0},
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

  Future<Map<String, dynamic>?> getRememberedUser() async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'remember_me = ?',
      whereArgs: [1],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<bool> checkUserExists(String email) async {
    var user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    Database db = await database;
    int count = await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

    // User settings
  Future<int> insertUserSettings(Map<String, dynamic> settings) async {
    Database db = await database;
    return await db.insert(
      'user_settings',
      settings,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user settings by user ID
  Future<Map<String, dynamic>?> getUserSettings(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'user_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }

    // If no settings exist yet, create default settings
    Map<String, dynamic> defaultSettings = {
      'user_id': userId,
      'avatar_path': null,
      'notification_general': 1,
      'notification_promotions': 1,
      'notification_security': 1,
    };

    await insertUserSettings(defaultSettings);
    return defaultSettings;
  }

  // Update user avatar
  Future<bool> updateUserAvatar(int userId, String avatarPath) async {
    Database db = await database;
    int count = await db.update(
      'user_settings',
      {'avatar_path': avatarPath},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (count == 0) {
      // If no record exists, create one
      await insertUserSettings({
        'user_id': userId,
        'avatar_path': avatarPath,
        'notification_general': 1,
        'notification_promotions': 1,
        'notification_security': 1,
      });
      return true;
    }

    return count > 0;
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(
    int userId,
    String type,
    bool enabled,
  ) async {
    Database db = await database;
    String columnName = 'notification_$type';

    int count = await db.update(
      'user_settings',
      {columnName: enabled ? 1 : 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (count == 0) {
      // If no record exists, create one with default values
      Map<String, dynamic> settings = {
        'user_id': userId,
        'avatar_path': null,
        'notification_general': 1,
        'notification_promotions': 1,
        'notification_security': 1,
      };
      // Override the specific notification type
      settings[columnName] = enabled ? 1 : 0;

      await insertUserSettings(settings);
      return true;
    }

    return count > 0;
  }

  // Get all notification settings for a user
  Future<Map<String, bool>> getNotificationSettings(int userId) async {
    Map<String, dynamic>? settings = await getUserSettings(userId);

    if (settings != null) {
      return {
        'general': settings['notification_general'] == 1,
        'promotions': settings['notification_promotions'] == 1,
        'security': settings['notification_security'] == 1,
      };
    }

    return {'general': true, 'promotions': true, 'security': true};
  }

  // ===================== PET PROFILE METHODS =====================
  Future<int> insertPetProfile(Map<String, dynamic> pet) async {
    final Database db = await database;
    return await db.insert(
      'pet_profile',
      pet,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updatePetProfile(Map<String, dynamic> pet, int petId) async {
    final Database db = await database;
    return await db.update(
      'pet_profile',
      pet,
      where: 'pet_id = ?',
      whereArgs: [petId],
    );
  }

  Future<int> deletePetProfile(int petId) async {
    final Database db = await database;
    return await db.delete(
      'pet_profile',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );
  }

  Future<Map<String, dynamic>?> getPetProfileById(int petId) async {
    final Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'pet_profile',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllPetProfiles({int? userId}) async {
    final Database db = await database;
    if (userId != null) {
      return await db.query(
        'pet_profile',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    return await db.query('pet_profile');
  }

  // ===================== CHARACTERISTICS METHODS =====================
  Future<int> insertCharacteristic(Map<String, dynamic> characteristic) async {
    final Database db = await database;
    return await db.insert(
      'characteristics',
      characteristic,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCharacteristic(
    Map<String, dynamic> characteristic,
    int charId,
  ) async {
    final Database db = await database;
    return await db.update(
      'characteristics',
      characteristic,
      where: 'char_id = ?',
      whereArgs: [charId],
    );
  }

  Future<int> deleteCharacteristic(int charId) async {
    final Database db = await database;
    return await db.delete(
      'characteristics',
      where: 'char_id = ?',
      whereArgs: [charId],
    );
  }

  Future<List<Map<String, dynamic>>> getCharacteristicsForPet(int petId) async {
    final Database db = await database;
    return await db.query(
      'characteristics',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );
  }

  // ===================== ALBUM METHODS =====================
  Future<int> insertAlbum(Map<String, dynamic> album) async {
    final Database db = await database;
    return await db.insert(
      'album',
      album,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAlbum(Map<String, dynamic> album, int albumId) async {
    final Database db = await database;
    return await db.update(
      'album',
      album,
      where: 'album_id = ?',
      whereArgs: [albumId],
    );
  }

  Future<int> deleteAlbum(int albumId) async {
    final Database db = await database;
    return await db.delete(
      'album',
      where: 'album_id = ?',
      whereArgs: [albumId],
    );
  }

  Future<List<Map<String, dynamic>>> getAlbumsForPet(int petId) async {
    final Database db = await database;
    return await db.query('album', where: 'pet_id = ?', whereArgs: [petId]);
  }

  Future<void> movePhotosToAlbum(List<int> imageIds, int albumId) async {
    final Database db = await database;

    Batch batch = db.batch();
    for (int imageId in imageIds) {
      batch.update(
        'image',
        {'album_id': albumId},
        where: 'image_id = ?',
        whereArgs: [imageId],
      );
    }

    await batch.commit();
  }

  // ===================== IMAGE METHODS =====================
  Future<int> insertImage(Map<String, dynamic> image) async {
    final Database db = await database;
    return await db.insert(
      'image',
      image,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateImage(Map<String, dynamic> image, int imageId) async {
    final Database db = await database;
    return await db.update(
      'image',
      image,
      where: 'image_id = ?',
      whereArgs: [imageId],
    );
  }

  Future<int> deleteImage(int imageId) async {
    final Database db = await database;
    return await db.delete(
      'image',
      where: 'image_id = ?',
      whereArgs: [imageId],
    );
  }

  Future<List<Map<String, dynamic>>> getImagesForAlbum(int albumId) async {
    final Database db = await database;
    return await db.query('image', where: 'album_id = ?', whereArgs: [albumId]);
  }

  // ===================== ACHIEVEMENTS METHODS =====================
  Future<int> insertAchievement(Map<String, dynamic> achievement) async {
    final Database db = await database;
    return await db.insert(
      'achievements',
      achievement,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAchievement(
    Map<String, dynamic> achievement,
    int achievementId,
  ) async {
    final Database db = await database;
    return await db.update(
      'achievements',
      achievement,
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );
  }

  Future<int> deleteAchievement(int achievementId) async {
    final Database db = await database;
    return await db.delete(
      'achievements',
      where: 'achievement_id = ?',
      whereArgs: [achievementId],
    );
  }

  Future<List<Map<String, dynamic>>> getAchievementsForPet(int petId) async {
    final Database db = await database;
    return await db.query(
      'achievements',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );
  }

  // ===================== HELPER METHODS =====================
  String formatDateForDb(DateTime date) {
    // Format: YYYY-MM-DD
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? parseDbDate(String? dateStr) {
    if (dateStr == null) return null;

    try {
      // Parse: YYYY-MM-DD
      List<String> parts = dateStr.split('-');
      if (parts.length == 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  String calculateAgeFromDate(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (now.day < birthDate.day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      return months > 0 ? "$years years $months months" : "$years years";
    } else {
      return "$months months";
    }
  }

  // ===================== PETS METHODS =====================
  Future<int> insertPet(Pet pet) async {
    final Database db = await database;

    return await db.insert('pets', {
      'name': pet.name,
      'imageUrl': pet.imageUrl,
      'currentDistance': 0, // Initialize with zero, will calculate per date
      'distanceGoal': pet.distanceGoal,
      'activeMinutes': 0, // Initialize with zero, will calculate per date
      'activeGoal': pet.activeGoal,
      'foodConsumed': 0, // Initialize with zero, will calculate per date
      'foodGoal': pet.foodGoal,
      'waterConsumed': 0, // Initialize with zero, will calculate per date
      'waterGoal': pet.waterGoal,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updatePet(Pet pet, int petId) async {
  final Database db = await database;
  
  // Check if pet exists in the pets table
  final petExists = await getPetById(petId) != null;
  
  if (!petExists) {
    // If pet doesn't exist in pets table, insert it first
    return await insertPet(pet);
  } else {
    // Only update the pet's goals, not the metrics which are date-specific
    return await db.update(
      'pets',
      {
        'name': pet.name,
        'imageUrl': pet.imageUrl,
        'distanceGoal': pet.distanceGoal,
        'activeGoal': pet.activeGoal,
        'foodGoal': pet.foodGoal,
        'waterGoal': pet.waterGoal,
      },
      where: 'id = ?',
      whereArgs: [petId],
    );
  }
}

  Future<int> deletePet(int id) async {
    final Database db = await database;

    // Delete related data first (SQLite will handle this with CASCADE if configured properly)
    return await db.delete('pets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Pet>> getPets() async {
  final Database db = await database;

  // Query pet profiles instead of the pets table
  final List<Map<String, dynamic>> petProfileMaps = await db.query('pet_profile');
  
  List<Pet> pets = [];

  for (var petMap in petProfileMaps) {
    int petId = petMap['pet_id']; // Note the different column name
    String imageUrl = petMap['avatar_url'] ?? 'assets/images/default_pet.png';
    String name = petMap['name'];

    // Get activities for this pet for today
    List<Activity> activities = await getActivitiesForPet(
      petId,
      DateTime.now(),
    );

    // Get feeding schedule for this pet for today
    List<FeedingTime> feedingSchedule = await getFeedingScheduleForPet(
      petId,
      DateTime.now(),
    );

    // Get dietary preferences for this pet
    DietaryPreferences dietaryPreferences = await getDietaryPreferencesForPet(
      petId,
    );

    // Get or create default metrics
    double distanceGoal = 5.0; // Default goal
    int activeGoal = 60; // Default goal
    double foodGoal = 2.0; // Default goal
    double waterGoal = 1000.0; // Default goal in ml

    // Try to get existing pet metrics if available
    Map<String, dynamic>? existingPet = await getPetById(petId);
    if (existingPet != null) {
      distanceGoal = existingPet['distanceGoal'] ?? distanceGoal;
      activeGoal = existingPet['activeGoal'] ?? activeGoal;
      foodGoal = existingPet['foodGoal'] ?? foodGoal;
      waterGoal = existingPet['waterGoal'] ?? waterGoal;
    }

    // Get daily metrics for today
    Map<String, dynamic> todayMetrics = await getPetDailyMetrics(
      petId,
      DateTime.now(),
    );

    pets.add(
      Pet(
        name: name,
        imageUrl: imageUrl,
        activities: activities,
        currentDistance: todayMetrics['totalDistance'], 
        distanceGoal: distanceGoal,
        activeMinutes: todayMetrics['totalActiveMinutes'],
        activeGoal: activeGoal,
        feedingSchedule: feedingSchedule,
        dietaryPreferences: dietaryPreferences,
        foodConsumed: todayMetrics['totalFood'],
        foodGoal: foodGoal,
        waterConsumed: todayMetrics['totalWater'],
        waterGoal: waterGoal,
      ),
    );
  }

  return pets;
}

  Future<Pet?> getPet(int id) async {
  final Database db = await database;

  // Query pet profile instead of pets table
  final List<Map<String, dynamic>> petProfileMaps = await db.query(
    'pet_profile',
    where: 'pet_id = ?', // Changed column name
    whereArgs: [id],
  );

  if (petProfileMaps.isEmpty) {
    return null;
  }

  var petMap = petProfileMaps.first;
  String imageUrl = petMap['avatar_url'] ?? 'assets/images/default_pet.png';
  String name = petMap['name'];

  // Get activities for this pet for today
  List<Activity> activities = await getActivitiesForPet(id, DateTime.now());

  // Get feeding schedule for this pet for today
  List<FeedingTime> feedingSchedule = await getFeedingScheduleForPet(
    id,
    DateTime.now(),
  );

  // Get dietary preferences for this pet
  DietaryPreferences dietaryPreferences = await getDietaryPreferencesForPet(
    id,
  );

  // Get or create default metrics
  double distanceGoal = 0.0; // Default goal
  int activeGoal = 0; // Default goal
  double foodGoal = 0.0; // Default goal
  double waterGoal = 0.0; 

  // Try to get existing pet metrics if available
  Map<String, dynamic>? existingPet = await getPetById(id);
  if (existingPet != null) {
    distanceGoal = existingPet['distanceGoal'] ?? distanceGoal;
    activeGoal = existingPet['activeGoal'] ?? activeGoal;
    foodGoal = existingPet['foodGoal'] ?? foodGoal;
    waterGoal = existingPet['waterGoal'] ?? waterGoal;
  }

  // Get daily metrics for today
  Map<String, dynamic> todayMetrics = await getPetDailyMetrics(
    id,
    DateTime.now(),
  );

  return Pet(
    name: name,
    imageUrl: imageUrl,
    activities: activities,
    currentDistance: todayMetrics['totalDistance'],
    distanceGoal: distanceGoal,
    activeMinutes: todayMetrics['totalActiveMinutes'],
    activeGoal: activeGoal,
    feedingSchedule: feedingSchedule,
    dietaryPreferences: dietaryPreferences,
    foodConsumed: todayMetrics['totalFood'],
    foodGoal: foodGoal,
    waterConsumed: todayMetrics['totalWater'],
    waterGoal: waterGoal,
  );
}

  // ===================== ACTIVITIES METHODS =====================
  Future<int> insertActivity(
    Activity activity,
    int petId,
    DateTime date,
  ) async {
    final Database db = await database;

    return await db.insert('activities', {
      'petId': petId,
      'name': activity.name,
      'duration': activity.duration,
      'timeHour': activity.time.hour,
      'timeMinute': activity.time.minute,
      'isCompleted': activity.isCompleted ? 1 : 0,
      'distanceContribution': activity.distanceContribution,
      'minutesContribution': activity.minutesContribution,
      'date': _formatDateForDb(date),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateActivity(Activity activity, int activityId) async {
    final Database db = await database;

    return await db.update(
      'activities',
      {
        'name': activity.name,
        'duration': activity.duration,
        'timeHour': activity.time.hour,
        'timeMinute': activity.time.minute,
        'isCompleted': activity.isCompleted ? 1 : 0,
        'distanceContribution': activity.distanceContribution,
        'minutesContribution': activity.minutesContribution,
      },
      where: 'id = ?',
      whereArgs: [activityId],
    );
  }

  Future<int> deleteActivity(int id) async {
    final Database db = await database;

    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Activity>> getActivitiesForPet(int petId, DateTime date) async {
  final Database db = await database;

  // First check if we need to use pet_id instead of petId in activities table
  bool usesPetProfileId = false;
  
  try {
    // Check if there's a column named pet_id in the activities table
    final List<Map<String, dynamic>> columnInfo = await db.rawQuery(
      "PRAGMA table_info(activities)"
    );
    
    usesPetProfileId = columnInfo.any((col) => col['name'] == 'pet_id');
  } catch (e) {
    print('Error checking table structure: $e');
  }
  
  // Use the appropriate column name
  final String whereClause = usesPetProfileId 
      ? 'pet_id = ? AND date = ?' 
      : 'petId = ? AND date = ?';
  
  final List<Map<String, dynamic>> activityMaps = await db.query(
    'activities',
    where: whereClause,
    whereArgs: [petId, _formatDateForDb(date)],
  );

  return List.generate(activityMaps.length, (i) {
    return Activity(
      name: activityMaps[i]['name'],
      duration: activityMaps[i]['duration'],
      time: TimeOfDay(
        hour: activityMaps[i]['timeHour'],
        minute: activityMaps[i]['timeMinute'],
      ),
      isCompleted: activityMaps[i]['isCompleted'] == 1,
      distanceContribution: activityMaps[i]['distanceContribution'],
      minutesContribution: activityMaps[i]['minutesContribution'],
    );
  });
}

  // ===================== FEEDING SCHEDULE METHODS =====================
  Future<int> insertFeedingTime(
    FeedingTime feedingTime,
    int petId,
    DateTime date,
  ) async {
    final Database db = await database;

    return await db.insert('feeding_schedule', {
      'petId': petId,
      'mealName': feedingTime.mealName,
      'time': feedingTime.time,
      'isCompleted': feedingTime.isCompleted ? 1 : 0,
      'portion': feedingTime.portion,
      'waterConsumed': feedingTime.waterConsumed,
      'date': _formatDateForDb(date),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateFeedingTime(FeedingTime feedingTime, int feedingId) async {
    final Database db = await database;

    return await db.update(
      'feeding_schedule',
      {
        'mealName': feedingTime.mealName,
        'time': feedingTime.time,
        'isCompleted': feedingTime.isCompleted ? 1 : 0,
        'portion': feedingTime.portion,
        'waterConsumed': feedingTime.waterConsumed,
      },
      where: 'id = ?',
      whereArgs: [feedingId],
    );
  }

  Future<int> deleteFeedingTime(int id) async {
    final Database db = await database;

    return await db.delete(
      'feeding_schedule',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FeedingTime>> getFeedingScheduleForPet(
    int petId,
    DateTime date,
  ) async {
    final Database db = await database;

    final List<Map<String, dynamic>> feedingMaps = await db.query(
      'feeding_schedule',
      where: 'petId = ? AND date = ?',
      whereArgs: [petId, _formatDateForDb(date)],
    );

    return List.generate(feedingMaps.length, (i) {
      return FeedingTime(
        mealName: feedingMaps[i]['mealName'],
        time: feedingMaps[i]['time'],
        isCompleted: feedingMaps[i]['isCompleted'] == 1,
        portion: feedingMaps[i]['portion'],
        waterConsumed: feedingMaps[i]['waterConsumed'],
      );
    });
  }

  // ===================== DEITARY PREFERENCES METHODS =====================
  Future<int> insertDietaryPreferences(
    DietaryPreferences preferences,
    int petId,
  ) async {
    final Database db = await database;

    return await db.insert('dietary_preferences', {
      'petId': petId,
      'foodType': preferences.foodType,
      'allergies': preferences.allergies,
      'specialNotes': preferences.specialNotes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDietaryPreferences(
    DietaryPreferences preferences,
    int petId,
  ) async {
    final Database db = await database;

    return await db.update(
      'dietary_preferences',
      {
        'foodType': preferences.foodType,
        'allergies': preferences.allergies,
        'specialNotes': preferences.specialNotes,
      },
      where: 'petId = ?',
      whereArgs: [petId],
    );
  }

  Future<DietaryPreferences> getDietaryPreferencesForPet(int petId) async {
    final Database db = await database;

    final List<Map<String, dynamic>> prefsMaps = await db.query(
      'dietary_preferences',
      where: 'petId = ?',
      whereArgs: [petId],
    );

    if (prefsMaps.isEmpty) {
      // Return default preferences if none exists
      return DietaryPreferences(
        foodType: 'Not specified',
        allergies: 'None',
        specialNotes: 'None',
      );
    }

    return DietaryPreferences(
      foodType: prefsMaps[0]['foodType'],
      allergies: prefsMaps[0]['allergies'],
      specialNotes: prefsMaps[0]['specialNotes'],
    );
  }

  // ===================== HELPER METHODS =====================
  Future<Map<String, dynamic>> getPetDailyMetrics(
    int petId,
    DateTime date,
  ) async {
    final Database db = await database;

    // Format the date for database query
    String formattedDate = _formatDateForDb(date);

    // Calculate distance and active minutes from activities
    final List<Map<String, dynamic>> activityStats = await db.rawQuery(
      '''
    SELECT 
      SUM(CASE WHEN isCompleted = 1 THEN distanceContribution ELSE 0 END) as totalDistance,
      SUM(CASE WHEN isCompleted = 1 THEN minutesContribution ELSE 0 END) as totalActiveMinutes
    FROM activities
    WHERE petId = ? AND date = ?
  ''',
      [petId, formattedDate],
    );

    // Calculate food and water from feeding schedule
    final List<Map<String, dynamic>> feedingStats = await db.rawQuery(
      '''
    SELECT 
      SUM(CASE WHEN isCompleted = 1 THEN portion ELSE 0 END) as totalFood,
      SUM(CASE WHEN isCompleted = 1 THEN waterConsumed ELSE 0 END) as totalWater
    FROM feeding_schedule
    WHERE petId = ? AND date = ?
  ''',
      [petId, formattedDate],
    );

    // Ensure all values are properly converted to double
    return {
      'totalDistance':
          activityStats.first['totalDistance'] != null
              ? double.parse(activityStats.first['totalDistance'].toString())
              : 0.0,
      'totalActiveMinutes':
          activityStats.first['totalActiveMinutes'] != null
              ? activityStats.first['totalActiveMinutes'] as int
              : 0,
      'totalFood':
          feedingStats.first['totalFood'] != null
              ? double.parse(feedingStats.first['totalFood'].toString())
              : 0.0,
      'totalWater':
          feedingStats.first['totalWater'] != null
              ? double.parse(feedingStats.first['totalWater'].toString())
              : 0.0,
    };
  }

  String _formatDateForDb(DateTime date) {
    // Format: YYYY-MM-DD
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Initialize the database with sample data if needed
  Future<void> initializeSampleData() async {
    // This method checks if the database is initialized correctly
    final Database db = await database;

    // Ensure tables exist by performing a simple query
    await db.rawQuery('SELECT COUNT(*) FROM pets');

    // Check if there's any data
    //final petsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM pets'));

    // If no pets exist, you could add sample data here if needed
    // For now, just keeping it empty
  }

  // ===================== FIRST AID METHODS =====================
  Future<int> insertFirstAidItem(String title, {bool status = false}) async {
    Database db = await database;
    return await db.insert('firstaid', {
      'firstaid_title': title,
      'firstaid_status': status ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllFirstAidItems() async {
    Database db = await database;
    return await db.query('firstaid');
  }

  // Helper to insert default first aid items during creation
  Future<void> _insertDefaultFirstAidItems(Database db) async {
    List<String> items = [
      'Latex (or hypoallergenic material) gloves',
      'Gauze sponges (a variety of sizes)',
      'Gauze roll, 2-inch width',
      'Elastic cling bandage',
      'Material to make a splint',
      'Adhesive tape, hypoallergenic',
      'Non-adherent sterile pads',
      'Small scissors',
      'Tweezers',
      'Magnifying glass',
      'Grooming clippers or safety razor',
      'Nylon leash',
      'Towel',
      'Muzzle',
      'Water-based sterile lubricant',
      'Rubbing alcohol',
      'Antiseptic towelettes',
      'Epsom salts',
      'Clean cloth',
      'Needle-nose pliers',
      'Glucose paste or syrup',
      'Instant cold pack',
      'Safety pins (medium size)',
      'List of emergency phone numbers',
    ];

    for (String title in items) {
      await db.insert('firstaid', {
        'firstaid_title': title,
        'firstaid_status': 0,
      });
    }
  }

  // ===================== EMERGENCY METHODS =====================
  Future<void> _insertDefaultEmergencyTips(Database db) async {
    List<Map<String, String>> tips = [
      {
        'title': 'Choking or Airway Obstruction',
        'desc':
            'If your pet is gasping, pawing at their mouth, or unable to breathe, check their mouth for visible obstructions. Carefully remove the object with tweezers or your fingers if possible. Perform the Heimlich maneuver for pets (learn proper technique in advance). Rush to the vet immediately if unsuccessful.',
        'cat': 'Life-Threatening Emergencies',
      },
      {
        'title': 'Poisoning',
        'desc':
            'Symptoms include vomiting, seizures, or collapse. Identify the toxin (e.g., chocolate, antifreeze, plants) and contact a vet or pet poison hotline (e.g., ASPCA Poison Control). Do NOT induce vomiting unless instructed. Bring the toxin’s packaging to the vet.',
        'cat': 'Life-Threatening Emergencies',
      },
      {
        'title': 'Severe Bleeding',
        'desc':
            'Apply direct pressure to the wound with a clean cloth or gauze. Elevate the injured area if possible. Use a tourniquet only as a last resort for limb injuries. Transport to the vet immediately while maintaining pressure.',
        'cat': 'Life-Threatening Emergencies',
      },
      {
        'title': 'Broken Bones or Fractures',
        'desc':
            'Immobilize your pet using a towel or splint (avoid manipulating the limb). Place them in a carrier or on a flat surface to minimize movement. Seek veterinary care immediately.',
        'cat': 'Injuries and Wounds',
      },
      {
        'title': 'Burns or Scalds',
        'desc':
            'Cool the affected area with room-temperature water (avoid ice). Cover minor burns with a sterile, non-stick bandage. For severe burns (charred skin, blistering), wrap loosely and go to the vet.',
        'cat': 'Injuries and Wounds',
      },
      {
        'title': 'Bite Wounds',
        'desc':
            'Clean superficial wounds with saline or mild soap and water. For deep punctures or signs of infection (swelling, pus), seek vet care. Ensure your pet’s rabies vaccination is up-to-date.',
        'cat': 'Injuries and Wounds',
      },
      {
        'title': 'Seizures',
        'desc':
            'Clear the area of hazards. Do not restrain your pet. Time the seizure; if it lasts longer than 2–3 minutes or recurs, go to the vet. Note details (triggers, duration) for the vet.',
        'cat': 'Illness and Internal Issues',
      },
      {
        'title': 'Bloating (Gastric Dilatation-Volvulus)',
        'desc':
            'Common in large breeds. Symptoms include a distended abdomen, retching, and restlessness. This is fatal without immediate surgery—transport to the ER immediately.',
        'cat': 'Illness and Internal Issues',
      },
      {
        'title': 'Sudden Paralysis (e.g., Back Injury)',
        'desc':
            'If your pet cannot move their hind legs or shows pain, gently place them on a flat board or towel to stabilize their spine. Avoid bending their neck/back. Seek emergency care.',
        'cat': 'Illness and Internal Issues',
      },
      {
        'title': 'Heatstroke',
        'desc':
            'Signs include excessive panting, drooling, or collapse. Move your pet to a cool area, apply wet towels to their paws/groin, and offer small sips of water. Use a fan and go to the vet.',
        'cat': 'Environmental Hazards',
      },
      {
        'title': 'Hypothermia',
        'desc':
            'Symptoms: shivering, lethargy, or icy extremities. Warm your pet gradually with blankets or warm (not hot) water bottles. Avoid direct heat sources. Contact a vet.',
        'cat': 'Environmental Hazards',
      },
      {
        'title': 'Electrocution (Chewing Wires)',
        'desc':
            'Turn off the power source before touching your pet. Check for burns around the mouth or breathing difficulties. Even if they seem fine, vet evaluation is critical for internal damage.',
        'cat': 'Environmental Hazards',
      },
      {
        'title': 'Pet First-Aid Kit Essentials',
        'desc':
            'Include gauze, adhesive tape, antiseptic wipes, a digital thermometer, hydrogen peroxide (for vet-approved vomiting), and a muzzle (even friendly pets may bite when in pain).',
        'cat': 'Emergency Preparedness',
      },
      {
        'title': 'Emergency Contacts List',
        'desc':
            'Keep numbers for your vet, the nearest 24-hour animal hospital, and poison control (e.g., ASPCA: 888-426-4435) accessible. Save them in your phone and post on the fridge.',
        'cat': 'Emergency Preparedness',
      },
      {
        'title': 'Evacuation Plan for Disasters',
        'desc':
            'Prepare a “go-bag” with food, water, medications, medical records, and a photo of your pet. Ensure carriers are labeled and microchip info is updated. Practice evacuation routes.',
        'cat': 'Emergency Preparedness',
      },
    ];

    for (var tip in tips) {
      await db.insert('emergency', {
        'emergency_title': tip['title']!,
        'emergency_desc': tip['desc']!,
        'emergency_cat': tip['cat']!,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllEmergencyTips() async {
    Database db = await database;
    return await db.query('emergency');
  }

  // ===================== REMINDER METHODS =====================
  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    Database db = await database;
    return await db.insert(
      'reminder',
      reminder,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateReminder(
    Map<String, dynamic> reminder,
    int reminderId,
  ) async {
    Database db = await database;
    return await db.update(
      'reminder',
      reminder,
      where: 'reminder_id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<int> deleteReminder(int reminderId) async {
    Database db = await database;
    return await db.delete(
      'reminder',
      where: 'reminder_id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<List<Map<String, dynamic>>> getRemindersForPet(int petId) async {
    Database db = await database;
    return await db.query(
      'reminder',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'reminder_datetime ASC',
    );
  }

  // Get reminder by ID
  Future<Map<String, dynamic>?> getReminderById(int reminderId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'reminder',
      where: 'reminder_id = ?',
      whereArgs: [reminderId],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Add this method to your DatabaseHandler class
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    Database db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // ===================== MEDICATION METHODS =====================
  Future<int> insertMedication(Map<String, dynamic> medication) async {
    Database db = await database;
    return await db.insert(
      'medication',
      medication,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMedication(
    Map<String, dynamic> medication,
    int medicationId,
  ) async {
    Database db = await database;
    return await db.update(
      'medication',
      medication,
      where: 'medication_id = ?',
      whereArgs: [medicationId],
    );
  }

  Future<int> updateMedicationStatus(int medicationId, bool isCompleted) async {
    Database db = await database;
    return await db.update(
      'medication',
      {'medication_status': isCompleted ? 1 : 0},
      where: 'medication_id = ?',
      whereArgs: [medicationId],
    );
  }

  Future<int> deleteMedication(int medicationId) async {
    Database db = await database;
    return await db.delete(
      'medication',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
    );
  }

  Future<List<Map<String, dynamic>>> getMedicationsForPet(int petId) async {
    Database db = await database;
    return await db.query(
      'medication',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'medication_datetime ASC',
    );
  }

  // ===================== ALLERGIC METHODS =====================
  Future<int> insertAllergic(Map<String, dynamic> allergic) async {
    Database db = await database;
    return await db.insert(
      'allergic',
      allergic,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAllergic(
    Map<String, dynamic> allergic,
    int allergicId,
  ) async {
    Database db = await database;
    return await db.update(
      'allergic',
      allergic,
      where: 'allergic_id = ?',
      whereArgs: [allergicId],
    );
  }

  Future<int> deleteAllergic(int allergicId) async {
    Database db = await database;
    return await db.delete(
      'allergic',
      where: 'allergic_id = ?',
      whereArgs: [allergicId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllergicsForPet(int petId) async {
    Database db = await database;
    return await db.query('allergic', where: 'pet_id = ?', whereArgs: [petId]);
  }

  //----------add one pet for reference---------------
  Future<int> insertSamplePet() async {
    Database db = await database;
    Map<String, dynamic> samplePet = {
      'name': 'Buddy',
      'imageUrl': 'assets/images/Pet profile pic/8.png',
      'currentDistance': 0.0,
      'distanceGoal': 5.0,
      'activeMinutes': 0,
      'activeGoal': 60,
      'foodConsumed': 0.0,
      'foodGoal': 2.0,
      'waterConsumed': 0.0,
      'waterGoal': 1.0,
    };

    return await db.insert(
      'pets',
      samplePet,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Method to get all pets (useful for testing)
  Future<List<Map<String, dynamic>>> getAllPets() async {
    Database db = await database;
    return await db.query('pets');
  }

  // Method to get a specific pet by ID
  Future<Map<String, dynamic>?> getPetById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'pets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}

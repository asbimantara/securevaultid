import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String pin;

  @HiveField(2)
  String salt;

  @HiveField(3)
  bool useBiometric;

  @HiveField(4)
  DateTime? lastLogin;

  @HiveField(5)
  int failedAttempts;

  @HiveField(6)
  DateTime? lockedUntil;

  User({
    required this.id,
    required this.pin,
    required this.salt,
    this.useBiometric = false,
    this.lastLogin,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  void incrementFailedAttempts() {
    failedAttempts++;
    if (failedAttempts >= 3) {
      lockedUntil = DateTime.now().add(const Duration(minutes: 30));
    }
  }

  void resetFailedAttempts() {
    failedAttempts = 0;
    lockedUntil = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pin': pin,
      'salt': salt,
      'useBiometric': useBiometric,
      'lastLogin': lastLogin?.toIso8601String(),
      'failedAttempts': failedAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      pin: json['pin'],
      salt: json['salt'],
      useBiometric: json['useBiometric'] ?? false,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      failedAttempts: json['failedAttempts'] ?? 0,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'])
          : null,
    );
  }

  Future<void> clearData() async {
    final passwordBox = await Hive.openBox('passwords');
    final categoryBox = await Hive.openBox('categories');
    final settingsBox = await Hive.openBox('settings');
    final userBox = await Hive.openBox('users');

    await passwordBox.clear();
    await categoryBox.clear();
    await settingsBox.clear();
    await userBox.clear();

    await passwordBox.close();
    await categoryBox.close();
    await settingsBox.close();
    await userBox.close();
  }
}

import 'package:hive/hive.dart';

part 'password_model.g.dart';

@HiveType(typeId: 0)
class Password extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String username;

  @HiveField(3)
  String password;

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? lastModified;

  @HiveField(7)
  String? url;

  @HiveField(8)
  String? notes;

  Password({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.categoryId,
    required this.createdAt,
    this.lastModified,
    this.url,
    this.notes,
  });

  double get strength {
    double score = 0;
    if (password.length >= 8) score += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) score += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score;
  }

  Password copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    String? categoryId,
    DateTime? lastModified,
  }) {
    return Password(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

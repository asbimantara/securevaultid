import 'package:hive/hive.dart';

part 'password_history_model.g.dart';

@HiveType(typeId: 2)
class PasswordHistory extends HiveObject {
  @HiveField(0)
  final String password;

  @HiveField(1)
  final DateTime changedAt;

  PasswordHistory({
    required this.password,
    required this.changedAt,
  });
}

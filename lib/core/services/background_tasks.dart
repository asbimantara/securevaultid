import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import '../../data/providers/password_provider.dart';
import 'password_rotation_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == PasswordRotationService._rotationTaskName) {
        final passwordKey = inputData?['password_key'] as int;
        final provider = PasswordProvider();
        await provider.init();

        final password = provider.passwords.firstWhere(
          (p) => p.key == passwordKey,
        );

        final newPassword = PasswordRotationService.generateStrongPassword();
        password.updatePassword(newPassword);
        await provider.updatePassword(password);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  });
}

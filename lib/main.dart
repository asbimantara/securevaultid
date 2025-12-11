import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/settings_provider.dart';
import 'data/providers/password_provider.dart';
import 'data/providers/category_provider.dart';
import 'data/repositories/password_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/models/password_model.dart';
import 'data/models/category_model.dart';
import 'data/models/user_model.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/password/widgets/password_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PasswordAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Initialize repositories
  final settingsRepository = SettingsRepository();
  await settingsRepository.initialize();

  final categoryRepository = CategoryRepository();
  await categoryRepository.initialize();

  final passwordRepository = PasswordRepository();
  await passwordRepository.initialize();

  // Initialize services
  await PasswordGenerator.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PasswordProvider(passwordRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureVault ID',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
    );
  }
}

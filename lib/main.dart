import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for German locale
  await initializeDateFormatting('de_DE', null);

  // Initialize config service
  await ConfigService.init();

  // Initialize Supabase if already configured
  if (ConfigService.isConfigured) {
    await Supabase.initialize(
      url: ConfigService.supabaseUrl!,
      anonKey: ConfigService.supabaseAnonKey!,
    );
  }

  // Initialize notification service
  await NotificationService.init();

  // Set preferred orientations (portrait only for simplicity)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NotifyMeApp());
}

class NotifyMeApp extends StatefulWidget {
  const NotifyMeApp({super.key});

  @override
  State<NotifyMeApp> createState() => _NotifyMeAppState();
}

class _NotifyMeAppState extends State<NotifyMeApp> {
  bool _isConfigured = ConfigService.isConfigured;

  void _onConfigured() {
    setState(() {
      _isConfigured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotifyMe',
      debugShowCheckedModeBanner: false,

      // Light theme - clean and minimal
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD97757), // Claude Orange
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),

      // Dark theme - equally clean
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD97757), // Claude Orange
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),

      themeMode: ThemeMode.system, // Follow system setting

      home: _isConfigured
          ? const HomeScreen()
          : OnboardingScreen(onConfigured: _onConfigured),
    );
  }
}

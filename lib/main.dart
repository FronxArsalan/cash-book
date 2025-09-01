import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'services/transaction_service.dart';
import 'services/settings_service.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => TransactionService()),
        ChangeNotifierProvider(create: (ctx) => SettingsService()),
      ],
      child: MaterialApp(
        title: 'Cash Book',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/transaction_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

void main() {
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

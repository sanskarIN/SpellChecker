import 'package:flutter/material.dart';

import 'features/editor/spell_checker_page.dart';

class SpellCheckerApp extends StatelessWidget {
  const SpellCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4458D8),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'SpellChecker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9CA7FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SpellCheckerPage(),
    );
  }
}

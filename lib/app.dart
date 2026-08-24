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
      home: const _AdaptiveSpellCheckerHome(),
    );
  }
}

class _AdaptiveSpellCheckerHome extends StatelessWidget {
  const _AdaptiveSpellCheckerHome();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const page = SpellCheckerPage();
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final needsScrollableCanvas =
            constraints.maxWidth < 900 && textScale > 1.3;

        if (!needsScrollableCanvas || !constraints.hasBoundedHeight) {
          return page;
        }

        final extraScale = (textScale - 1).clamp(0.0, 2.0);
        final canvasHeight = constraints.maxHeight * (1 + extraScale);

        return SingleChildScrollView(
          child: SizedBox(
            width: constraints.maxWidth,
            height: canvasHeight,
            child: page,
          ),
        );
      },
    );
  }
}

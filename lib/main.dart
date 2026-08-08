import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/color_palette.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Command',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorPalette.accentOrange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: ColorPalette.darkNavy,
      ),
      home: const HomeScreen(),
    );
  }
}

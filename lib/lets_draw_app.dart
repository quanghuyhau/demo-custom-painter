import 'package:demo_custom_painter/presentation/pages/drawing_page.dart';
import 'package:demo_custom_painter/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LetsDrawApp extends StatelessWidget {
  const LetsDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "HUYTQ",
      theme: lightTheme,
      home: const DrawingPage(),
    );
  }
}

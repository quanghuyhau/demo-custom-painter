import 'package:demo_custom_painter/src/presentation/presentation.dart';
import 'package:flutter/material.dart';

class LetsDrawApp extends StatelessWidget {
  const LetsDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let/'s Draw",
      theme: lightTheme,
      home: const DrawingPage(),
    );
  }
}

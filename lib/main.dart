import 'package:circle_rush/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Since we're using a dark theme, changing to light icons for better visibility
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EscapeRush());
}

class EscapeRush extends StatelessWidget {
  const EscapeRush({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escape Rush',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFF1F2B3E, {
          50: Color(0xFFEDF0F0), // paleGray
          100: Color(0xFFB1BDC2), // mistGray
          200: Color(0xFF618096), // slateBlue
          300: Color(0xFF304B5F), // marineBlue
          400: Color(0xFF1B4167), // deepBlue
          500: Color(0xFF1F2B3E), // deepestBlue - primary
          600: Color(0xFF1F2B3E),
          700: Color(0xFF1F2B3E),
          800: Color(0xFF1F2B3E),
          900: Color(0xFF1F2B3E),
        }),
        scaffoldBackgroundColor: const Color(0xFF1F2B3E),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFFEDF0F0), // paleGray
          displayColor: const Color(0xFFEDF0F0), // paleGray
        ),
        brightness: Brightness.dark,
        cardColor: const Color(0xFF304B5F), // marineBlue
        dialogBackgroundColor: const Color(0xFF1B4167), // deepBlue
        dividerColor: const Color(0xFF618096), // slateBlue
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

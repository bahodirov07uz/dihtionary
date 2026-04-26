import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LugatApp());
}

class LugatApp extends StatelessWidget {
  const LugatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "O'zbek Lug'at",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6B3C),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.ibmPlexSansTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A6B3C),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.ibmPlexSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

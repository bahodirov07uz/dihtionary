import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';
import '../models/word_service.dart';
import 'words_screen.dart';
import 'dashboard_screen.dart';
import 'import_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Word> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final words = await WordService.loadWords();
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  Future<void> _onWordsChanged(List<Word> words) async {
    await WordService.saveWords(words);
    setState(() => _words = words);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      WordsScreen(words: _words, onWordsChanged: _onWordsChanged),
      DashboardScreen(words: _words),
      ImportScreen(words: _words, onWordsChanged: _onWordsChanged),
    ];

    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A6B3C)),
            )
          : screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A6B3C).withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: Color(0xFF1A6B3C)),
            label: "So'zlar",
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart, color: Color(0xFF1A6B3C)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.upload_file_outlined),
            selectedIcon: const Icon(Icons.upload_file, color: Color(0xFF1A6B3C)),
            label: 'Yuklash',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';
import '../models/word_service.dart';
import 'word_detail_screen.dart';

class WordsScreen extends StatefulWidget {
  final List<Word> words;
  final Function(List<Word>) onWordsChanged;

  const WordsScreen({super.key, required this.words, required this.onWordsChanged});

  @override
  State<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends State<WordsScreen> with SingleTickerProviderStateMixin {
  String _filter = 'all'; // all, learned, notlearned
  String _search = '';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _filter = ['all', 'notlearned', 'learned'][_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Word> get filteredWords {
    var list = widget.words;
    if (_search.isNotEmpty) {
      list = list.where((w) =>
        w.word.toLowerCase().contains(_search.toLowerCase()) ||
        w.meaning.toLowerCase().contains(_search.toLowerCase())
      ).toList();
    }
    if (_filter == 'learned') return list.where((w) => w.isLearned).toList();
    if (_filter == 'notlearned') return list.where((w) => !w.isLearned).toList();
    return list;
  }

  Future<void> _toggleLearned(Word word) async {
    final updated = widget.words.map((w) {
      if (w.id == word.id) {
        return w.copyWith(
          isLearned: !w.isLearned,
          learnedAt: !w.isLearned ? DateTime.now() : null,
          reviewCount: w.reviewCount + 1,
        );
      }
      return w;
    }).toList();
    await widget.onWordsChanged(updated);
  }

  Future<void> _deleteWord(String id) async {
    final updated = widget.words.where((w) => w.id != id).toList();
    await widget.onWordsChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: Text("Mening Lug'atim"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "So'z qidirish...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(text: "Barchasi (${widget.words.length})"),
                  Tab(text: "Yodlanmadi (${widget.words.where((w) => !w.isLearned).length})"),
                  Tab(text: "Yodlandi (${widget.words.where((w) => w.isLearned).length})"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: filteredWords.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredWords.length,
              itemBuilder: (context, i) => _WordCard(
                word: filteredWords[i],
                onToggle: () => _toggleLearned(filteredWords[i]),
                onDelete: () => _deleteWord(filteredWords[i].id),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordDetailScreen(
                      word: filteredWords[i],
                      onToggle: () => _toggleLearned(filteredWords[i]),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _search.isNotEmpty ? "Topilmadi" : "So'z yo'q",
            style: GoogleFonts.ibmPlexSans(fontSize: 20, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            _search.isNotEmpty
                ? "Boshqa so'z qidiring"
                : "Yuklash bo'limidan so'zlar qo'shing",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final Word word;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _WordCard({
    required this.word,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(word.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("O'chirish"),
            content: Text("'${word.word}' so'zini o'chirmoqchimisiz?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Yo'q")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ha")),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: word.isLearned
                  ? const Color(0xFF1A6B3C).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: word.isLearned
                        ? const Color(0xFF1A6B3C).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    word.isLearned ? Icons.check_circle : Icons.circle_outlined,
                    color: word.isLearned ? const Color(0xFF1A6B3C) : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.word,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (word.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A6B3C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                word.category!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1A6B3C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.meaning,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (word.isLearned && word.learnedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "✓ ${_formatDate(word.learnedAt!)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1A6B3C),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: word.isLearned
                          ? const Color(0xFF1A6B3C)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      word.isLearned ? "Yodlandi" : "Yodla",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: word.isLearned ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }
}

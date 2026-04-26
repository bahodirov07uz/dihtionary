import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/word.dart';
import '../models/word_service.dart';

class ImportScreen extends StatefulWidget {
  final List<Word> words;
  final Function(List<Word>) onWordsChanged;

  const ImportScreen({super.key, required this.words, required this.onWordsChanged});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  bool _loading = false;
  String? _lastMessage;
  bool _lastSuccess = false;

  Future<void> _pickFile(String type) async {
    setState(() { _loading = true; _lastMessage = null; });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: type == 'json' ? ['json'] : ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      List<Word> newWords = [];
      if (type == 'json') {
        newWords = WordService.parseJson(content);
      } else {
        newWords = WordService.parseCsv(content);
      }

      if (newWords.isEmpty) {
        setState(() {
          _loading = false;
          _lastMessage = "Fayl bo'sh yoki format noto'g'ri";
          _lastSuccess = false;
        });
        return;
      }

      // Merge (skip duplicates by word text)
      final existingWords = Set<String>.from(widget.words.map((w) => w.word.toLowerCase()));
      final toAdd = newWords.where((w) => !existingWords.contains(w.word.toLowerCase())).toList();
      
      final updated = [...widget.words, ...toAdd];
      await widget.onWordsChanged(updated);

      setState(() {
        _loading = false;
        _lastMessage = "${toAdd.length} ta yangi so'z qo'shildi! (${newWords.length - toAdd.length} ta mavjud bo'lgani o'tkazib yuborildi)";
        _lastSuccess = true;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _lastMessage = "Xato: ${e.toString()}";
        _lastSuccess = false;
      });
    }
  }

  Future<void> _addManually() async {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final exampleController = TextEditingController();
    final categoryController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yangi so'z qo'shish",
              style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildField(wordController, "So'z *", Icons.text_fields),
            const SizedBox(height: 12),
            _buildField(meaningController, "Ma'nosi *", Icons.translate),
            const SizedBox(height: 12),
            _buildField(exampleController, "Misol (ixtiyoriy)", Icons.format_quote),
            const SizedBox(height: 12),
            _buildField(categoryController, "Kategoriya (ixtiyoriy)", Icons.label_outline),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (wordController.text.trim().isEmpty || meaningController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("So'z va ma'nosi majburiy!")),
                    );
                    return;
                  }
                  final newWord = Word(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    word: wordController.text.trim(),
                    meaning: meaningController.text.trim(),
                    example: exampleController.text.trim().isEmpty ? null : exampleController.text.trim(),
                    category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                  );
                  final updated = [...widget.words, newWord];
                  await widget.onWordsChanged(updated);
                  Navigator.pop(context);
                  setState(() {
                    _lastMessage = "'${newWord.word}' so'zi qo'shildi!";
                    _lastSuccess = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6B3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Qo'shish", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A6B3C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A6B3C), width: 2),
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Barchasini o'chirish"),
        content: const Text("Barcha so'zlar o'chiriladi. Ishonchingiz komilmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Bekor qilish")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.onWordsChanged([]);
      setState(() {
        _lastMessage = "Barcha so'zlar o'chirildi";
        _lastSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(title: const Text("So'z Yuklash")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status message
            if (_lastMessage != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lastSuccess ? const Color(0xFFE8F5EE) : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lastSuccess ? const Color(0xFF1A6B3C) : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastSuccess ? Icons.check_circle : Icons.error_outline,
                      color: _lastSuccess ? const Color(0xFF1A6B3C) : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_lastMessage!)),
                  ],
                ),
              ),

            // Import buttons
            Text("Fayl orqali yuklash",
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),

            _ImportCard(
              icon: Icons.data_object,
              title: "JSON yuklash",
              subtitle: 'word, meaning, example, category maydonlari',
              color: const Color(0xFF1A6B3C),
              onTap: _loading ? null : () => _pickFile('json'),
            ),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.table_chart,
              title: "CSV yuklash",
              subtitle: "word, meaning, example, category ustunlari",
              color: const Color(0xFF2196F3),
              onTap: _loading ? null : () => _pickFile('csv'),
            ),

            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator(color: Color(0xFF1A6B3C))),
            ],

            const SizedBox(height: 24),
            Text("Qo'lda qo'shish",
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.add_circle_outline,
              title: "Yangi so'z qo'shish",
              subtitle: "Bitta so'z qo'lda kiritish",
              color: Colors.purple,
              onTap: _addManually,
            ),

            const SizedBox(height: 24),
            // Format info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
                      const SizedBox(width: 8),
                      Text("Format namunasi",
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber[800])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("JSON:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber[800])),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '[{"word":"apple","meaning":"olma","example":"I eat an apple","category":"meva"}]',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("CSV:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber[800])),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "word,meaning,example,category\napple,olma,I eat an apple,meva",
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.words.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: Text(
                    "Barcha so'zlarni o'chirish (${widget.words.length} ta)",
                    style: const TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ImportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

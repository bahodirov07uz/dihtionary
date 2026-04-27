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
      await _importContent(content, type);
    } catch (e) {
      setState(() {
        _loading = false;
        _lastMessage = "Xato: $e";
        _lastSuccess = false;
      });
    }
  }

  Future<void> _importContent(String content, String type) async {
    final List<Word> newWords = type == 'json'
        ? WordService.parseJson(content)
        : WordService.parseCsv(content);

    if (newWords.isEmpty) {
      setState(() {
        _loading = false;
        _lastMessage = "Fayl bo'sh yoki format noto'g'ri";
        _lastSuccess = false;
      });
      return;
    }
    final existing = Set<String>.from(widget.words.map((w) => w.word.toLowerCase().trim()));
    final toAdd = newWords.where((w) => !existing.contains(w.word.toLowerCase().trim())).toList();
    await widget.onWordsChanged([...widget.words, ...toAdd]);
    setState(() {
      _loading = false;
      _lastMessage = "${toAdd.length} ta yangi so'z qo'shildi!"
          + (newWords.length - toAdd.length > 0
              ? " (${newWords.length - toAdd.length} ta mavjud)"
              : "");
      _lastSuccess = true;
    });
  }

  Future<void> _showJsonPasteDialog() async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("JSON matn kiritish",
              style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text("So'zlar ro'yxatini JSON formatida kiriting",
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                  hintText: '[{"word":"apple","meaning":"olma","category":"meva"}]',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Format hint
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Maydonlar:", style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12, color: Colors.amber[800])),
                  const SizedBox(height: 4),
                  Text(
                    "• word / so'z  (majburiy)\n"
                    "• meaning / manosi  (majburiy)\n"
                    "• example / misol  (ixtiyoriy)\n"
                    "• category / kategoriya  (ixtiyoriy)",
                    style: TextStyle(fontSize: 11, color: Colors.amber[900]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Bekor qilish"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final text = ctrl.text.trim();
                      if (text.isEmpty) return;
                      Navigator.pop(ctx);
                      setState(() => _loading = true);
                      await _importContent(text, 'json');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A6B3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Qo'shish",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addManually() async {
    final wordCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final exampleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Yangi so'z qo'shish",
              style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _field(wordCtrl, "So'z *", Icons.text_fields),
            const SizedBox(height: 12),
            _field(meaningCtrl, "Ma'nosi *", Icons.translate),
            const SizedBox(height: 12),
            _field(exampleCtrl, "Misol (ixtiyoriy)", Icons.format_quote),
            const SizedBox(height: 12),
            _field(categoryCtrl, "Kategoriya (ixtiyoriy)", Icons.label_outline),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (wordCtrl.text.trim().isEmpty || meaningCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("So'z va ma'nosi majburiy!")));
                    return;
                  }
                  final newWord = Word(
                    id: '${DateTime.now().millisecondsSinceEpoch}_manual',
                    word: wordCtrl.text.trim(),
                    meaning: meaningCtrl.text.trim(),
                    example: exampleCtrl.text.trim().isEmpty ? null : exampleCtrl.text.trim(),
                    category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                  );
                  await widget.onWordsChanged([...widget.words, newWord]);
                  if (ctx.mounted) Navigator.pop(ctx);
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
                child: const Text("Qo'shish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A6B3C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A6B3C), width: 2)),
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
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text("Bekor qilish")),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text("O'chirish", style: TextStyle(color: Colors.red))),
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
            if (_lastMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lastSuccess ? const Color(0xFFE8F5EE) : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _lastSuccess ? const Color(0xFF1A6B3C) : Colors.red),
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

            // FILE import
            Text("Fayl orqali yuklash",
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.data_object,
              title: "JSON fayl yuklash",
              subtitle: ".json fayl tanlash",
              color: const Color(0xFF1A6B3C),
              onTap: _loading ? null : () => _pickFile('json'),
            ),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.table_chart,
              title: "CSV fayl yuklash",
              subtitle: ".csv fayl tanlash",
              color: const Color(0xFF2196F3),
              onTap: _loading ? null : () => _pickFile('csv'),
            ),

            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator(color: Color(0xFF1A6B3C))),
            ],

            const SizedBox(height: 24),

            // TEXT import
            Text("Matn orqali qo'shish",
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.code,
              title: "JSON matn kiritish",
              subtitle: "JSON ni to'g'ridan-to'g'ri yozing / nusxalang",
              color: Colors.deepPurple,
              onTap: _showJsonPasteDialog,
            ),
            const SizedBox(height: 12),
            _ImportCard(
              icon: Icons.add_circle_outline,
              title: "Bitta so'z qo'shish",
              subtitle: "Forma orqali qo'lda kiritish",
              color: Colors.teal,
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
                  Row(children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
                    const SizedBox(width: 8),
                    Text("Format namunasi",
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber[800])),
                  ]),
                  const SizedBox(height: 10),
                  Text("JSON:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber[800])),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      '[{"word":"apple","meaning":"olma","category":"meva"},\n{"word":"book","meaning":"kitob"}]',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  ),
                  const SizedBox(height: 8),
                  Text("CSV:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber[800])),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      "word,meaning,category\napple,olma,meva\nbook,kitob,ta'lim",
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
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
                    style: const TextStyle(color: Colors.red)),
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

  const _ImportCard({required this.icon, required this.title,
    required this.subtitle, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w700, fontSize: 15)),
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

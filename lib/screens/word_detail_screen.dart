import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/word.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;
  final VoidCallback onToggle;
  const WordDetailScreen({super.key, required this.word, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(title: Text(word.word)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(word.word,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 32, fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E))),
                      if (word.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A6B3C).withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(word.category!,
                            style: const TextStyle(
                              color: Color(0xFF1A6B3C), fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 3, width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A6B3C),
                      borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 20),
                  Text("Ma'nosi",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.grey[500], letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(word.meaning,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 20, color: const Color(0xFF1A1A2E), height: 1.5)),
                  if (word.example != null) ...[
                    const SizedBox(height: 24),
                    Text("Misol",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.grey[500], letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F3),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(color: Color(0xFF1A6B3C), width: 3)),
                      ),
                      child: Text(word.example!,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15, fontStyle: FontStyle.italic,
                          color: const Color(0xFF2D5A3D))),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatCard(icon: Icons.refresh,
                  label: "Ko'rilgan", value: "${word.reviewCount} marta"),
                const SizedBox(width: 12),
                _StatCard(icon: Icons.access_time,
                  label: "Yodlangan",
                  value: word.learnedAt != null
                      ? "${word.learnedAt!.day}.${word.learnedAt!.month}.${word.learnedAt!.year}"
                      : "—"),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () { onToggle(); Navigator.pop(context); },
                icon: Icon(word.isLearned ? Icons.close : Icons.check),
                label: Text(
                  word.isLearned ? "Yodlanmadi deb belgilash" : "Yodlandi deb belgilash",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: word.isLearned ? Colors.orange : const Color(0xFF1A6B3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1A6B3C), size: 20),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

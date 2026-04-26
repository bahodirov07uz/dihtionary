import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/word.dart';

class DashboardScreen extends StatelessWidget {
  final List<Word> words;

  const DashboardScreen({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    final learned = words.where((w) => w.isLearned).length;
    final notLearned = words.length - learned;
    final percent = words.isEmpty ? 0.0 : (learned / words.length * 100);

    // Last 7 days activity
    final now = DateTime.now();
    final dailyCounts = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return words.where((w) =>
        w.isLearned && w.learnedAt != null &&
        w.learnedAt!.year == day.year &&
        w.learnedAt!.month == day.month &&
        w.learnedAt!.day == day.day
      ).length;
    });

    // Category stats
    final categories = <String, int>{};
    for (final w in words) {
      final cat = w.category ?? 'Umumiy';
      categories[cat] = (categories[cat] ?? 0) + 1;
    }
    final learnedByCategory = <String, int>{};
    for (final w in words.where((w) => w.isLearned)) {
      final cat = w.category ?? 'Umumiy';
      learnedByCategory[cat] = (learnedByCategory[cat] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(title: const Text('Dashboard')),
      body: words.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Hali so'z yo'q", style: GoogleFonts.ibmPlexSans(fontSize: 18, color: Colors.grey[500])),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      _SummaryCard(
                        value: words.length.toString(),
                        label: "Jami so'z",
                        color: const Color(0xFF1A6B3C),
                        icon: Icons.auto_stories,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        value: learned.toString(),
                        label: "Yodlandi",
                        color: const Color(0xFF2196F3),
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(width: 12),
                      _SummaryCard(
                        value: notLearned.toString(),
                        label: "Qolgan",
                        color: Colors.orange,
                        icon: Icons.pending,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Umumiy progress",
                              style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${percent.toStringAsFixed(1)}%",
                              style: GoogleFonts.ibmPlexSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: const Color(0xFF1A6B3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            backgroundColor: const Color(0xFFE8F5EE),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A6B3C)),
                            minHeight: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$learned yodlandi", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            Text("$notLearned qoldi", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pie chart + bar chart side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donut chart
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Holat",
                                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 35,
                                    sections: [
                                      if (learned > 0)
                                        PieChartSectionData(
                                          value: learned.toDouble(),
                                          color: const Color(0xFF1A6B3C),
                                          radius: 40,
                                          title: '$learned',
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      if (notLearned > 0)
                                        PieChartSectionData(
                                          value: notLearned.toDouble(),
                                          color: Colors.orange,
                                          radius: 40,
                                          title: '$notLearned',
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _Legend(color: const Color(0xFF1A6B3C), label: "Yodlandi"),
                                  const SizedBox(width: 12),
                                  _Legend(color: Colors.orange, label: "Qolgan"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Weekly bar chart
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "7 kunlik",
                                style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 150,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (dailyCounts.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, _) {
                                            final days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
                                            final day = now.subtract(Duration(days: 6 - v.toInt()));
                                            return Text(
                                              days[day.weekday % 7],
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(7, (i) => BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: dailyCounts[i].toDouble(),
                                          color: const Color(0xFF1A6B3C),
                                          width: 16,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Categories
                  if (categories.length > 1) ...[
                    const SizedBox(height: 20),
                    Text(
                      "Kategoriyalar",
                      style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...categories.entries.map((entry) {
                      final total = entry.value;
                      final done = learnedByCategory[entry.key] ?? 0;
                      final pct = total == 0 ? 0.0 : done / total;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text("$done / $total", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: const Color(0xFFE8F5EE),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A6B3C)),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

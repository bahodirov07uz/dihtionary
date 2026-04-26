import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

class WordService {
  static const String _wordsKey = 'words_data';

  static Future<List<Word>> loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_wordsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Word.fromJson(e)).toList();
  }

  static Future<void> saveWords(List<Word> words) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(words.map((w) => w.toJson()).toList());
    await prefs.setString(_wordsKey, data);
  }

  static Future<void> updateWord(List<Word> words, Word updatedWord) async {
    final index = words.indexWhere((w) => w.id == updatedWord.id);
    if (index != -1) {
      words[index] = updatedWord;
      await saveWords(words);
    }
  }

  static Future<void> deleteWord(List<Word> words, String id) async {
    words.removeWhere((w) => w.id == id);
    await saveWords(words);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wordsKey);
  }

  static List<Word> parseJson(String jsonString) {
    final data = json.decode(jsonString);
    if (data is List) {
      return data.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data.containsKey('words')) {
      final list = data['words'] as List;
      return list.map((e) => Word.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static List<Word> parseCsv(String csvString) {
    final lines = csvString.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];
    
    final headers = lines[0].split(',').map((h) => h.trim().toLowerCase().replaceAll('"', '')).toList();
    final wordIdx = headers.indexWhere((h) => h == 'word' || h == "so'z" || h == 'soz');
    final meaningIdx = headers.indexWhere((h) => h == 'meaning' || h == 'manosi' || h == 'mano');
    final exampleIdx = headers.indexWhere((h) => h == 'example' || h == 'misol');
    final categoryIdx = headers.indexWhere((h) => h == 'category' || h == 'kategoriya');

    if (wordIdx == -1 || meaningIdx == -1) return [];

    final words = <Word>[];
    for (int i = 1; i < lines.length; i++) {
      final cols = _parseCsvLine(lines[i]);
      if (cols.length <= wordIdx || cols.length <= meaningIdx) continue;
      final w = cols[wordIdx].trim();
      final m = cols[meaningIdx].trim();
      if (w.isEmpty || m.isEmpty) continue;
      words.add(Word(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        word: w,
        meaning: m,
        example: exampleIdx != -1 && cols.length > exampleIdx ? cols[exampleIdx].trim() : null,
        category: categoryIdx != -1 && cols.length > categoryIdx ? cols[categoryIdx].trim() : null,
      ));
    }
    return words;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final current = StringBuffer();
    for (int i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        inQuotes = !inQuotes;
      } else if (c == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(c);
      }
    }
    result.add(current.toString());
    return result;
  }
}

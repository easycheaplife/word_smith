import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/essay_history.dart';

class HistoryService {
  static const String _storageKey = 'essay_histories';

  // 保存历史记录
  Future<void> saveHistories(List<EssayHistory> histories) async {
    final prefs = await SharedPreferences.getInstance();
    final historiesJson = histories
        .map((history) => {
              'input': history.input,
              'output': history.output,
              'timestamp': history.timestamp.toIso8601String(),
              'functionType': history.functionType,
            })
        .toList();
    await prefs.setString(_storageKey, jsonEncode(historiesJson));
  }

  // 加载历史记录
  Future<List<EssayHistory>> loadHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final historiesJson = prefs.getString(_storageKey);
    if (historiesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historiesJson);
    return decoded
        .map((item) => EssayHistory(
              input: item['input'],
              output: item['output'],
              timestamp: DateTime.parse(item['timestamp']),
              functionType: item['functionType'],
            ))
        .toList();
  }

  // 清除历史记录
  Future<void> clearHistories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

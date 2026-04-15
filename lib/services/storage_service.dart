import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _coinsKey = 'total_coins';
  static const String _highScoreKey = 'high_score';
  static const String _lastAdTimeKey = 'last_ad_time'; // Add this

  Future<void> saveCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
  }

  Future<int> loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  Future<int> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  // New Ad Cooldown methods
  Future<void> saveLastAdTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAdTimeKey, time.toIso8601String());
  }

  Future<DateTime?> loadLastAdTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_lastAdTimeKey);
    return timeStr != null ? DateTime.tryParse(timeStr) : null;
  }
}

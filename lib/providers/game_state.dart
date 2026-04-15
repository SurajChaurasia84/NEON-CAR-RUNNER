import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GameState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  int _totalCoins = 0;
  int _highScore = 0; // Add this
  double _currentRunScore = 0;
  int _currentRunCoins = 0;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _hasUsedCoinContinue = false;
  int _coinsFinalizedInRun = 0;

  int get totalCoins => _totalCoins;
  int get highScore => _highScore; // Add this
  int get currentRunScore => _currentRunScore.floor();
  int get currentRunCoins => _currentRunCoins;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused;
  bool get hasUsedCoinContinue => _hasUsedCoinContinue;

  GameState() {
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    _totalCoins = await _storage.loadCoins();
    _highScore = await _storage.loadHighScore(); // Load highScore
    notifyListeners();
  }

  void updateScore(double points) {
    _currentRunScore += points;
    notifyListeners();
  }

  void resetScore() {
    _currentRunScore = 0;
    _currentRunCoins = 0;
    _coinsFinalizedInRun = 0;
    notifyListeners();
  }

  void collectCoin() {
    _currentRunCoins++;
    notifyListeners();
  }

  void setGameOver(bool value) {
    _isGameOver = value;
    if (value) {
      _finalizeRun();
    } else {
      resetScore();
      _hasUsedCoinContinue = false;
      _isPaused = false;
    }
    notifyListeners();
  }

  void setPaused(bool value) {
    _isPaused = value;
    notifyListeners();
  }

  void resumeGame() {
    _isGameOver = false;
    _isPaused = false;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (_totalCoins >= amount) {
      _totalCoins -= amount;
      _hasUsedCoinContinue = true;
      _storage.saveCoins(_totalCoins);
      notifyListeners();
      return true;
    }
    return false;
  }

  void _finalizeRun() {
    // Update total coins
    int newCoins = _currentRunCoins - _coinsFinalizedInRun;
    if (newCoins > 0) {
      _totalCoins += newCoins;
      _coinsFinalizedInRun = _currentRunCoins;
      _storage.saveCoins(_totalCoins);
    }

    // Check and update High Score
    int currentScoreInt = _currentRunScore.floor();
    if (currentScoreInt > _highScore) {
      _highScore = currentScoreInt;
      _storage.saveHighScore(_highScore);
    }
  }

  void addBonusCoins(int amount) {
    _totalCoins += amount;
    _storage.saveCoins(_totalCoins);
    notifyListeners();
  }
}

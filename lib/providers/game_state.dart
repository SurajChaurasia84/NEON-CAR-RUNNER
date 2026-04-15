import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GameState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  int _totalCoins = 0;
  double _currentRunScore = 0;
  int _currentRunCoins = 0;
  bool _isGameOver = false;
  bool _isPaused = false; // Add this
  bool _hasUsedCoinContinue = false;
  int _coinsFinalizedInRun = 0;

  int get totalCoins => _totalCoins;
  int get currentRunScore => _currentRunScore.floor();
  int get currentRunCoins => _currentRunCoins;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused; // Add this
  bool get hasUsedCoinContinue => _hasUsedCoinContinue;

  GameState() {
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    _totalCoins = await _storage.loadCoins();
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
      _isPaused = false; // Reset pause on new run
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
    int newCoins = _currentRunCoins - _coinsFinalizedInRun;
    if (newCoins > 0) {
      _totalCoins += newCoins;
      _coinsFinalizedInRun = _currentRunCoins;
      _storage.saveCoins(_totalCoins);
    }
  }

  void addBonusCoins(int amount) {
    _totalCoins += amount;
    _storage.saveCoins(_totalCoins);
    notifyListeners();
  }
}

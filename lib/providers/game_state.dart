import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class GameState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  int _totalCoins = 0;
  int _highScore = 0;
  DateTime? _lastAdTime; // Add this
  Timer? _cooldownTimer; // Add this
  
  double _currentRunScore = 0;
  int _currentRunCoins = 0;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _hasUsedCoinContinue = false;
  int _coinsFinalizedInRun = 0;

  int get totalCoins => _totalCoins;
  int get highScore => _highScore;
  int get currentRunScore => _currentRunScore.floor();
  int get currentRunCoins => _currentRunCoins;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused;
  bool get hasUsedCoinContinue => _hasUsedCoinContinue;
  
  // Getter for cooldown duration
  Duration? get adCooldownRemaining {
    if (_lastAdTime == null) return null;
    final diff = DateTime.now().difference(_lastAdTime!);
    final remaining = const Duration(minutes: 30) - diff;
    return remaining.isNegative ? null : remaining;
  }

  GameState() {
    _loadState();
  }

  Future<void> _loadState() async {
    _totalCoins = await _storage.loadCoins();
    _highScore = await _storage.loadHighScore();
    _lastAdTime = await _storage.loadLastAdTime();
    
    // Start timer if cooldown active
    if (adCooldownRemaining != null) {
      _startCooldownTimer();
    }
    notifyListeners();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (adCooldownRemaining == null) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void recordAdWatch() {
    _lastAdTime = DateTime.now();
    _storage.saveLastAdTime(_lastAdTime!);
    _startCooldownTimer();
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
    int newCoins = _currentRunCoins - _coinsFinalizedInRun;
    if (newCoins > 0) {
      _totalCoins += newCoins;
      _coinsFinalizedInRun = _currentRunCoins;
      _storage.saveCoins(_totalCoins);
    }

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

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class GameState extends ChangeNotifier with WidgetsBindingObserver {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();

  int _totalCoins = 0;
  int _highScore = 0;
  DateTime? _lastAdTime;
  Timer? _cooldownTimer;
  bool _isMusicEnabled = true;
  
  double _currentRunScore = 0;
  int _currentRunCoins = 0;
  bool _isGameOver = false;
  bool _isPaused = false;
  bool _hasContinuedInRun = false;
  int _coinsFinalizedInRun = 0;

  int get totalCoins => _totalCoins;
  int get highScore => _highScore;
  int get currentRunScore => _currentRunScore.floor();
  int get currentRunCoins => _currentRunCoins;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused;
  bool get hasContinuedInRun => _hasContinuedInRun;
  bool get isMusicEnabled => _isMusicEnabled;
  
  Duration? get adCooldownRemaining {
    if (_lastAdTime == null) return null;
    final diff = DateTime.now().difference(_lastAdTime!);
    final remaining = const Duration(minutes: 30) - diff;
    return remaining.isNegative ? null : remaining;
  }

  GameState() {
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  Future<void> _loadState() async {
    _totalCoins = await _storage.loadCoins();
    _highScore = await _storage.loadHighScore();
    _lastAdTime = await _storage.loadLastAdTime();
    _isMusicEnabled = await _storage.loadMusicEnabled();
    
    if (adCooldownRemaining != null) {
      _startCooldownTimer();
    }
    _syncAudio();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _audio.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      _syncAudio();
    }
  }

  void _syncAudio() {
    if (!_isMusicEnabled || _isGameOver || _isPaused) {
      _audio.pauseBgm();
    } else {
      _audio.playBgm('bg.mp3');
    }
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    debugPrint('DEBUG: Music Enabled: $_isMusicEnabled');
    _storage.saveMusicEnabled(_isMusicEnabled);
    if (!_isMusicEnabled) {
      _audio.stopBgm();
    } else {
      _syncAudio();
    }
    notifyListeners();
  }

  void setGameOver(bool value) {
    _isGameOver = value;
    if (value) {
      _finalizeRun();
      _audio.stopBgm();
      if (_isMusicEnabled) {
        _audio.playSfx('go.mp3');
      }
    } else {
      resetScore();
      _hasContinuedInRun = false;
      _isPaused = false;
      _syncAudio();
    }
    notifyListeners();
  }

  void setPaused(bool value) {
    _isPaused = value;
    _syncAudio();
    notifyListeners();
  }

  void resumeGame() {
    _isGameOver = false;
    _isPaused = false;
    _hasContinuedInRun = true;
    _syncAudio();
    notifyListeners();
  }

  // Helper for UI to trigger audio update if needed
  void updateAudio() => _syncAudio();

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

  bool spendCoins(int amount) {
    if (_totalCoins >= amount) {
      _totalCoins -= amount;
      _hasContinuedInRun = true;
      _storage.saveCoins(_totalCoins);
      _syncAudio();
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

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (adCooldownRemaining == null) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cooldownTimer?.cancel();
    _audio.dispose();
    super.dispose();
  }
}

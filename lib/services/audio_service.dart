import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _bgmStarted = false;

  void init() {
    if (_isInitialized) return;
    FlameAudio.bgm.initialize();
    // Using the exact literal prefix confirmed as working for SFX
    FlameAudio.audioCache.prefix = 'assets/music/';
    _isInitialized = true;
  }

  /// Master switch to enable/disable all audio globally
  void updateMuteState(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stopBgm();
    }
  }

  void playBgm(String fileName, {double volume = 1.0}) {
    if (_isMuted) return;
    init();
    
    // Only call play if we haven't started yet or if it's completely stopped.
    // This prevents the "Restart from beginning" bug when unpausing.
    if (!_bgmStarted || !FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.play(fileName, volume: volume);
      _bgmStarted = true;
    }
  }

  void stopBgm() {
    // Stop completely resets the BGM singleton
    FlameAudio.bgm.stop();
    _bgmStarted = false;
  }

  void pauseBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
    }
  }

  void resumeBgm() {
    if (_isMuted) return;
    // resume() only works if it was previously paused. 
    // If it was stopped, we need playBgm() instead.
    FlameAudio.bgm.resume();
  }

  void playSfx(String fileName, {double volume = 1.0}) {
    if (_isMuted) return;
    init();
    FlameAudio.play(fileName, volume: volume);
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}

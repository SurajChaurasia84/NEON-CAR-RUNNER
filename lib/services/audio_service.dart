import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isInitialized = false;
  bool _isMuted = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      FlameAudio.bgm.initialize();
      // Explicitly set the prefix (Flame adds 'assets/' automatically)
      FlameAudio.audioCache.prefix = 'music/';
      
      // Pre-load assets to avoid lag or first-play failures
      await FlameAudio.audioCache.loadAll(['bg.mp3', 'go.mp3']);
      
      _isInitialized = true;
      print('AudioService Initialized and Assets Pre-loaded');
    } catch (e) {
      print('AudioService Init Error: $e');
    }
  }

  /// Master switch to enable/disable all audio globally
  void updateMuteState(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stopBgm();
    }
  }

  Future<void> playBgm(String fileName, {double volume = 1.0}) async {
    if (_isMuted) return; 
    if (!_isInitialized) await init();
    
    try {
      // If already playing, don't restart (saves CPU and avoids overlaps)
      if (FlameAudio.bgm.isPlaying) {
        return;
      }
      
      print('Attempting to play BGM: $fileName');
      await FlameAudio.bgm.play(fileName, volume: volume);
    } catch (e) {
      print('BGM Play Error: $e');
    }
  }

  void stopBgm() {
    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.stop();
      }
    } catch (_) {}
  }

  void pauseBgm() {
    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.pause();
      }
    } catch (_) {}
  }

  void resumeBgm() {
    if (_isMuted) return; 
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  void playSfx(String fileName, {double volume = 1.0}) {
    if (_isMuted) return; // Block SFX too
    init();
    FlameAudio.play(fileName, volume: volume);
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}

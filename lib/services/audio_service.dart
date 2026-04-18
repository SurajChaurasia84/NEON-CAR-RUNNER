import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isInitialized = false;
  bool _isMuted = false;

  void init() {
    if (_isInitialized) return;
    FlameAudio.bgm.initialize();
    // Flame Audio automatically prepends 'assets/' to the prefix.
    // So 'music/' becomes 'assets/music/'
    FlameAudio.audioCache.prefix = 'music/';
    _isInitialized = true;
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
    init();
    
    try {
      // If already playing, don't restart
      if (FlameAudio.bgm.isPlaying) return;
      
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

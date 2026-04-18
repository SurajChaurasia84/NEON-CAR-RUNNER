import 'package:flame_audio/flame_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.prefix = 'assets/music/';
    _isInitialized = true;
  }

  void playBgm(String fileName, {double volume = 1.0}) {
    init();
    FlameAudio.bgm.play(fileName, volume: volume);
  }

  void stopBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.stop();
    }
  }

  void pauseBgm() {
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
    }
  }

  void resumeBgm() {
    if (!FlameAudio.bgm.isPlaying) {
      // In some versions resume might not work if fully stopped, 
      // but Bgm handles its own state. 
      FlameAudio.bgm.resume();
    }
  }

  void playSfx(String fileName, {double volume = 1.0}) {
    init();
    FlameAudio.play(fileName, volume: volume);
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }
}

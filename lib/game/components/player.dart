import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';

class Player extends SpriteComponent with HasGameRef<RunnerGame>, CollisionCallbacks {
  int currentLane = 1; // 0: Left, 1: Middle, 2: Right
  final double laneWidth = 100.0;
  
  Player() : super(
    size: Vector2(60, 100),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    _updatePosition();
    await super.onLoad();
    sprite = await game.loadSprite('car1_spr.png');
    add(RectangleHitbox());
  }

  void _updatePosition() {
    final centerX = gameRef.size.x / 2;
    position = Vector2(centerX + (currentLane - 1) * laneWidth, gameRef.size.y - 120);
  }

  void moveLeft() {
    if (currentLane > 0) {
      currentLane--;
      _updatePosition();
    }
  }

  void moveRight() {
    if (currentLane < 2) {
      currentLane++;
      _updatePosition();
    }
  }

  void reset() {
    currentLane = 1;
    _updatePosition();
  }
}

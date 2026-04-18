import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';
import 'player.dart';

import 'dart:math';

class Obstacle extends SpriteComponent with HasGameRef<RunnerGame>, CollisionCallbacks {
  final int lane;
  final double speed;
  final double laneWidth = 100.0;

  Obstacle({required this.lane, required this.speed}) : super(
    size: Vector2(70, 110),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Set position immediately to avoid middle-screen pop-in
    final centerX = game.size.x / 2;
    position = Vector2(centerX + (lane - 1) * laneWidth, -200);

    await super.onLoad();
    final carIndex = 2 + Random().nextInt(5); // 2 to 6
    sprite = await game.loadSprite('car$carIndex.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (gameRef.gameState.isGameOver) return;
    super.update(dt);
    position.y += speed * dt;

    if (position.y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      gameRef.gameOver();
    }
  }
}

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../runner_game.dart';
import 'player.dart';

class Coin extends SpriteComponent with HasGameRef<RunnerGame>, CollisionCallbacks {
  final int lane;
  final double speed;
  final double laneWidth = 100.0;

  Coin({required this.lane, required this.speed}) : super(
    size: Vector2(40, 40),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    // Set position immediately
    final centerX = game.size.x / 2;
    position = Vector2(centerX + (lane - 1) * laneWidth, -200);

    await super.onLoad();
    sprite = await game.loadSprite('coin.png');
    add(CircleHitbox());
  }

  double _timer = 0;

  @override
  void update(double dt) {
    if (gameRef.gameState.isGameOver) return;
    super.update(dt);
    _timer += dt;
    position.y += speed * dt;
    
    // Create a 'flip' effect (horizontal spin)
    scale.x = math.cos(_timer * 4);

    if (position.y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      gameRef.gameState.collectCoin();
      removeFromParent();
    }
  }
}

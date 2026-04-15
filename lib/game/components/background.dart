import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../runner_game.dart';

class GameBackground extends ParallaxComponent<RunnerGame> with HasGameRef<RunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    parallax = await game.loadParallax(
      [
        // We don't have images, so we can use colored layers or just skip images
        // Since loadParallax requires images, I'll simulate a background with a ShapeComponent
        // But for a true "Flame" experience, I should use layers.
        // Instead of images, I'll use simple RectangleComponents for lanes in RunnerGame.
      ],
    );
  }
}

// Since I don't have images, I'll implement a 'LaneDecorator' to show the 3 lanes.
class LaneDecorator extends PositionComponent with HasGameRef<RunnerGame> {
  double _offset = 0;
  final double dashHeight = 150; // Longer dashes
  final double dashSpace = 50;  // More space

  @override
  void update(double dt) {
    if (game.gameState.isGameOver) return;
    super.update(dt);
    _offset += game.gameSpeed * dt;
    if (_offset > dashHeight + dashSpace) {
      _offset %= (dashHeight + dashSpace);
    }
  }

  @override
  void render(Canvas canvas) {
    final centerX = game.size.x / 2;
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4;
    
    // Lane boundary positions
    final lines = [centerX - 150, centerX - 50, centerX + 50, centerX + 150];
    
    for (int i = 0; i < lines.length; i++) {
      final x = lines[i];
      // Draw solid lines for the outer edges (0 and 3)
      if (i == 0 || i == 3) {
        canvas.drawLine(Offset(x, 0), Offset(x, game.size.y), paint);
      } else {
        // Draw dashed lines for the internal separators (1 and 2)
        double y = -dashHeight + _offset;
        while (y < game.size.y) {
          if (y + dashHeight > 0) {
            canvas.drawLine(Offset(x, y), Offset(x, y + dashHeight), paint);
          }
          y += dashHeight + dashSpace;
        }
      }
    }
  }
}

import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../providers/game_state.dart';
import 'components/player.dart';
import 'components/obstacle.dart';
import 'components/coin.dart';
import 'components/background.dart';

class RunnerGame extends FlameGame with HasCollisionDetection, DragCallbacks, TapCallbacks {
  final GameState gameState;

  RunnerGame({required this.gameState});

  late Player player;
  double gameSpeed = 300.0;
  final double maxSpeed = 800.0;
  final double speedIncrement = 5.0;
  
  double spawnTimer = 0.0;
  final double spawnInterval = 1.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add Background Decorations
    add(LaneDecorator());

    // Add Player
    player = Player();
    add(player);

    // Sync initial audio state
    gameState.updateAudio();
  }

  @override
  void update(double dt) {
    if (gameState.isGameOver) return;

    final cappedDt = dt.clamp(0.0, 0.05);
    super.update(cappedDt);

    if (gameSpeed < maxSpeed) {
      gameSpeed += speedIncrement * cappedDt;
    }

    gameState.updateScore(gameSpeed * cappedDt / 50);

    spawnTimer += dt;
    if (spawnTimer >= (spawnInterval * (300 / gameSpeed))) {
      spawnTimer = 0;
      spawnObject();
    }
  }

  void spawnObject() {
    final random = Random();
    final lane = random.nextInt(3);
    
    if (random.nextDouble() > 0.3) {
      add(Obstacle(lane: lane, speed: gameSpeed));
    } else {
      add(Coin(lane: lane, speed: gameSpeed));
    }
  }

  void gameOver() {
    gameState.setGameOver(true);
  }

  void restart() {
    gameState.setGameOver(false);
    gameState.resetScore();
    gameSpeed = 300.0;
    spawnTimer = 0;
    _clearObstacles();
    player.reset();
  }

  void resume() {
    gameState.resumeGame();
    _clearObstacles();
  }

  void _clearObstacles() {
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    children.whereType<Coin>().forEach((c) => c.removeFromParent());
  }

  bool hasSwiped = false;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    hasSwiped = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (hasSwiped || gameState.isGameOver) return;

    if (event.localDelta.x > 5) {
      player.moveRight();
      hasSwiped = true;
    } else if (event.localDelta.x < -5) {
      player.moveLeft();
      hasSwiped = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    hasSwiped = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    hasSwiped = false;
  }

  @override
  void onRemove() {
    // We let GameState handle global audio stop/pause
    super.onRemove();
  }
}

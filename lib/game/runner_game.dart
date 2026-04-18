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
  final double maxSpeed = 850.0; // Reasonable cap for survivability
  final double speedIncrement = 4.0;
  
  double spawnTimer = 0.0;
  // Lower interval because we spawn single items now, not full waves
  final double baseSpawnInterval = 0.8;
  
  // Track lanes to ensure survival
  final List<int> _recentObstacleLanes = [];

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
    if (gameState.isGameOver || gameState.isPaused) return;

    final cappedDt = dt.clamp(0.0, 0.05);
    super.update(cappedDt);

    if (gameSpeed < maxSpeed) {
      gameSpeed += speedIncrement * cappedDt;
    }

    gameState.updateScore(gameSpeed * cappedDt / 50);

    spawnTimer += dt;
    // Pacing: single items come 'aage piche'
    double currentInterval = baseSpawnInterval * (400 / (gameSpeed * 0.7 + 100));
    if (spawnTimer >= currentInterval) {
      spawnTimer = 0;
      spawnObject();
    }
  }

  /// Spawns objects one-by-one with random vertical spacing
  /// Ensures NO 3-lane traps by tracking recent obstacle placements
  void spawnObject() {
    final random = Random();
    int lane = random.nextInt(3);
    bool isObstacle = random.nextDouble() > 0.35; // 65% chance for car

    if (isObstacle) {
      // Check if adding an obstacle in this lane creates a trap
      // Rule: Never have all 3 lanes occupied by obstacles in the last 2 spawns
      if (_recentObstacleLanes.length >= 2) {
        bool wouldTrap = _recentObstacleLanes.contains(0) && 
                         _recentObstacleLanes.contains(1) && 
                         lane == 2;
        if (!wouldTrap) {
           wouldTrap = _recentObstacleLanes.contains(0) && 
                       _recentObstacleLanes.contains(2) && 
                       lane == 1;
        }
        if (!wouldTrap) {
           wouldTrap = _recentObstacleLanes.contains(1) && 
                       _recentObstacleLanes.contains(2) && 
                       lane == 0;
        }

        if (wouldTrap) {
          // Force it to be a coin instead of a car to keep a lane open
          isObstacle = false;
        }
      }
    }

    if (isObstacle) {
      add(Obstacle(lane: lane, speed: gameSpeed));
      
      // Update memory (keep only last 2 lanes)
      _recentObstacleLanes.add(lane);
      if (_recentObstacleLanes.length > 2) {
        _recentObstacleLanes.removeAt(0);
      }
    } else {
      add(Coin(lane: lane, speed: gameSpeed));
      // Coins don't contribute to traps, but we can clear memory a bit
      if (random.nextDouble() > 0.8 && _recentObstacleLanes.isNotEmpty) {
        _recentObstacleLanes.removeAt(0);
      }
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
    super.onRemove();
  }
}

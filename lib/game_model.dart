import 'dart:math';
import 'package:circle_rush/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EscapeGame {
  final GameLevel level;
  final Random random = Random();
  List<FallingObject> fallingObjects = [];
  double playerX = 0.5;
  int score = 0;
  bool isGameOver = false;

  late final LevelConfig config;

  EscapeGame(this.level) {
    config = GameConstants.levelConfigs[level]!;
  }

  void updatePlayerPosition(double deltaX) {
    playerX = (playerX + deltaX).clamp(0.1, 0.9);
  }

  void spawnObject() {
    if (isGameOver) return;

    fallingObjects.add(
      FallingObject(
        x: random.nextDouble() * 0.8 + 0.1,
        y: -0.1,
        speed: config.baseSpeed + random.nextDouble() * config.speedVariation,
        isGreen: random.nextBool(),
        rotation: random.nextDouble() * pi / 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.05,
      ),
    );
  }

  bool checkCollision(double objectX, double objectY) {
    // Convert the sizes from pixels to relative coordinates (0-1 scale)
    // Making collision box smaller by using a smaller multiplier
    const double squareSize = (GameConstants.obstacleSize * 0.5) /
        100; // Reduced collision box for square
    const double circleRadius =
        (GameConstants.ballSize) / 7500; // Reduced collision radius for ball

    // Player's position (the circle)
    final double circleCenterX = playerX;
    const double circleCenterY = 0.8; // Player's Y position

    // Calculate square corners in relative coordinates
    final double squareLeft = objectX - squareSize / 2;
    final double squareRight = objectX + squareSize / 2;
    final double squareTop = objectY - squareSize / 2;
    final double squareBottom = objectY + squareSize / 2;

    // Find the closest point on the square to the circle's center
    final double closestX = clamp(circleCenterX, squareLeft, squareRight);
    final double closestY = clamp(circleCenterY, squareTop, squareBottom);

    // Calculate the distance between the circle's center and the closest point
    final double distanceX = circleCenterX - closestX;
    final double distanceY = circleCenterY - closestY;

    // Calculate the squared distance
    final double distanceSquared =
        (distanceX * distanceX) + (distanceY * distanceY);

    // Check if the distance is less than the circle's radius
    return distanceSquared < (circleRadius * circleRadius);
  }

  // Helper function to clamp a value between a minimum and maximum
  double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void update() {
    if (isGameOver) return;

    List<FallingObject> remainingObjects = [];

    for (var object in fallingObjects) {
      // Update position and rotation
      object.y += object.speed / 100;
      object.rotation += object.rotationSpeed;

      // Check for collision
      if (checkCollision(object.x, object.y)) {
        if (object.isGreen) {
          // Green square collision - add score
          score += (10 * config.scoreMultiplier);
          continue; // Remove the collected green square
        } else {
          // White square collision - game over
          isGameOver = true;
          _saveHighScore();
          return;
        }
      }

      // Check if object has fallen off screen
      if (object.y > 1.0) {
        if (object.isGreen) {
          // Missed a green square - penalty
          score = max(0, score - (5 * config.scoreMultiplier));
        }
        continue; // Remove the object
      }

      // Keep the object if it hasn't collided or fallen off
      remainingObjects.add(object);
    }

    fallingObjects = remainingObjects;
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentHigh = prefs.getInt('highScore_${level.name}') ?? 0;
      if (score > currentHigh) {
        await prefs.setInt('highScore_${level.name}', score);
      }
    } catch (e) {
      print('Error saving high score: $e');
    }
  }

  void reset() {
    fallingObjects.clear();
    score = 0;
    isGameOver = false;
    playerX = 0.5;
  }
}

class FallingObject {
  double x;
  double y;
  double speed;
  bool isGreen;
  double rotation;
  double rotationSpeed;

  FallingObject({
    required this.x,
    required this.y,
    required this.speed,
    required this.isGreen,
    required this.rotation,
    required this.rotationSpeed,
  });
}

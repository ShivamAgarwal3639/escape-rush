import 'package:flutter/material.dart';

class GameColors {
  // Core theme colors
  static const deepestBlue = Color(0xFF1F2B3E);
  static const neonGreen = Color(0xFF00FF90);
  static const darkGray = Color(0xFF0A0A0A);
  static const white = Colors.white;

  // Component colors
  static const backgroundColor = darkGray;
  static const boardColor = deepestBlue;
  static const playerColor = neonGreen;
  static const obstacleColor = white;
  static const scoreColor = white;
  static const buttonColor = neonGreen;
  static const textColor = white;

  // Level-specific colors
  static const Map<GameLevel, Color> levelColors = {
    GameLevel.easy: Color(0xFF4CAF50), // Green
    GameLevel.medium: Color(0xFFFFA726), // Orange
    GameLevel.hard: Color(0xFFEF5350), // Red
  };
}

class GameConstants {
  static const double ballSize = 22.0;
  static const double obstacleSize = 26.0;
  static const double cornerRadius = 8.0;

// Level-specific configurations with increased frequency and reduced speeds
  static const Map<GameLevel, LevelConfig> levelConfigs = {
    GameLevel.easy: LevelConfig(
      spawnInterval:
          Duration(milliseconds: 750), // Increased frequency (was 1000)
      baseSpeed: 0.75, // Reduced speed (was 1.5)
      speedVariation: 0.5, // Reduced variation (was 0.8)
      scoreMultiplier: 1,
    ),
    GameLevel.medium: LevelConfig(
      spawnInterval:
          Duration(milliseconds: 500), // Increased frequency (was 800)
      baseSpeed: 1.25, // Reduced speed (was 2.0)
      speedVariation: 0.7, // Reduced variation (was 1.0)
      scoreMultiplier: 2,
    ),
    GameLevel.hard: LevelConfig(
      spawnInterval:
          Duration(milliseconds: 250), // Increased frequency (was 600)
      baseSpeed: 1.75, // Reduced speed (was 2.5)
      speedVariation: 0.9, // Reduced variation (was 1.2)
      scoreMultiplier: 3,
    ),
  };
}

enum GameLevel { easy, medium, hard }

class LevelConfig {
  final Duration spawnInterval;
  final double baseSpeed;
  final double speedVariation;
  final int scoreMultiplier;

  const LevelConfig({
    required this.spawnInterval,
    required this.baseSpeed,
    required this.speedVariation,
    required this.scoreMultiplier,
  });
}

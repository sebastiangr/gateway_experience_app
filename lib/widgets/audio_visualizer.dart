import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../utils/app_colors.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Speed of the wave animation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    // We listen to playerStateStream directly for changes in playing status
    // to rebuild the CustomPaint with correct amplitude.
    return StreamBuilder<PlayerState>(
      stream: audioProvider.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final bool isPlaying = snapshot.data?.playing ?? false;
        // A simple way to affect amplitude: larger when playing
        final double baseAmplitude = isPlaying ? 40.0 : 10.0; 
        
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: SineWavePainter(
                animationValue: _controller.value,
                amplitude: baseAmplitude,
                frequency: 2.0, // How many waves
                color: AppColors.mintGreen.withOpacity(0.8),
              ),
              child: Container(), // Ensures CustomPaint has a size
            );
          },
        );
      }
    );
  }
}

class SineWavePainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final double amplitude;
  final double frequency;
  final Color color;

  SineWavePainter({
    required this.animationValue,
    this.amplitude = 40.0,
    this.frequency = 2.0,
    this.color = AppColors.mintGreen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final waveHeight = size.height / 2;
    final waveWidth = size.width;

    // Start from the left edge
    path.moveTo(0, waveHeight);

    for (double x = 0; x <= waveWidth; x++) {
      // Calculate y value of the sine wave
      // animationValue creates a phase shift, making the wave appear to move
      final y = waveHeight +
          amplitude *
              sin((x / waveWidth) * 2 * pi * frequency +
                  animationValue * 2 * pi);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Optional: Draw a second, slightly offset wave for more visual interest
    final paint2 = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path2 = Path();
    path2.moveTo(0, waveHeight);
     for (double x = 0; x <= waveWidth; x++) {
      final y = waveHeight +
          (amplitude * 0.7) * // Smaller amplitude
              sin((x / waveWidth) * 2 * pi * (frequency * 0.8) + // Slightly different frequency
                  animationValue * 2 * pi * 1.2 + pi/4); // Phase shift and offset
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant SineWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.amplitude != amplitude ||
           oldDelegate.color != color;
  }
}
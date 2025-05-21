import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../utils/app_colors.dart';

class AudioControls extends StatelessWidget {
  const AudioControls({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          context,
          icon: Icons.skip_previous_rounded,
          onPressed: audioProvider.playPrevious,
        ),
        _buildPlayPauseButton(context, audioProvider),
        _buildControlButton(
          context,
          icon: Icons.skip_next_rounded,
          onPressed: audioProvider.playNext,
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(BuildContext context, AudioPlayerProvider audioProvider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.mintGreen.withOpacity(0.8), AppColors.mintGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ]
      ),
      child: IconButton(
        icon: Icon(
          audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.darkBlue, // Contrasting color for icon on mint button
        ),
        iconSize: 48.0,
        onPressed: () {
          if (audioProvider.isPlaying) {
            audioProvider.pause();
          } else {
            audioProvider.play();
          }
        },
        splashRadius: 35, // Adjust splash radius
        padding: EdgeInsets.zero, // Remove default padding to make it truly circular
        constraints: const BoxConstraints(minWidth: 70, minHeight: 70), // Ensure button is large enough
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 36.0,
      color: AppColors.lightGray,
      onPressed: onPressed,
      splashRadius: 28,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.lightGray,
        disabledForegroundColor: AppColors.darkGray,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
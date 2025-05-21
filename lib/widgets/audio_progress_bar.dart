import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../utils/app_colors.dart';

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if (hours > 0) hours.toString(),
      minutes,
      seconds,
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            activeTrackColor: AppColors.mintGreen,
            inactiveTrackColor: AppColors.darkGray.withOpacity(0.5),
            thumbColor: AppColors.mintGreen,
            overlayColor: AppColors.mintGreen.withAlpha(0x29),
          ),
          child: Slider(
            min: 0.0,
            max: audioProvider.totalDuration.inMilliseconds.toDouble() > 0
                ? audioProvider.totalDuration.inMilliseconds.toDouble()
                : 1.0, // Avoid division by zero if duration is 0
            value: audioProvider.currentPosition.inMilliseconds.toDouble().clamp(
                  0.0,
                  audioProvider.totalDuration.inMilliseconds.toDouble(),
                ),
            onChanged: (value) {
              audioProvider.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(audioProvider.currentPosition),
                style: const TextStyle(color: AppColors.lightGray, fontSize: 12),
              ),
              Text(
                _formatDuration(audioProvider.totalDuration),
                style: const TextStyle(color: AppColors.lightGray, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
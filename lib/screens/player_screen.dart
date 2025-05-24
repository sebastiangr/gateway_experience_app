import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/audio_controls.dart';
import '../widgets/audio_progress_bar.dart';
import '../widgets/audio_visualizer.dart'; // Ensure this is created

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final track = audioProvider.currentTrack;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.playerGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
            child: Column(
              children: [
                // Custom App Bar-like section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.lightGray, size: 30),
                      onPressed: () => Navigator.pop(context), // Go back to library
                      tooltip: "Back to Library",
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkBlue.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
                      ),
                    ),
                    const Text(
                      "NOW PLAYING",
                      style: TextStyle(color: AppColors.darkGray, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    SizedBox(width: 48), // Placeholder to balance the back button
                  ],
                ),
                const Spacer(flex: 1),
                // Track Info
                if (track != null) ...[
                  Text(
                    track.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.waveName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lightGray,
                    ),
                  ),
                ] else ... [
                  const Text(
                    "No Track Loaded",
                    style: TextStyle(fontSize: 22, color: AppColors.white),
                  ),
                  const SizedBox(height: 8),
                   const Text(
                    "Please select a track from the library.",
                    style: TextStyle(fontSize: 16, color: AppColors.lightGray),
                  ),
                ],

                const Spacer(flex: 2),

                // Audio Visualizer
                SizedBox(
                  height: 150, // Give the visualizer a defined height
                  child: track != null ? const AudioVisualizer() : Container(
                    decoration: BoxDecoration(
                      // border: Border.all(color: AppColors.darkGray.withOpacity(0.5)),
                      // borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Center(child: Text("Visual wave", style: TextStyle(color: AppColors.darkGray))),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress Bar
                if (track != null) const AudioProgressBar(),

                const SizedBox(height: 20),

                // Controls
                if (track != null) const AudioControls(),
                
                const Spacer(flex: 1),

                // "Access Library" button (though the top-left arrow also does this)
                // This is more of an example of custom button styling
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: AppColors.mintGreen.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: AppColors.mintGreen.withOpacity(0.3)),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "BACK TO LIBRARY",
                    style: TextStyle(color: AppColors.mintGreen, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
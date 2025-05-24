import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track_model.dart';
import '../providers/audio_player_provider.dart';
import '../providers/track_library_provider.dart';
import '../screens/player_screen.dart';
import '../utils/app_colors.dart';
import '../widgets/track_list_item.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Request permissions on first load if needed
    // You might want to call this in main.dart or a splash screen
    // Provider.of<PermissionProvider>(context, listen: false).requestPermissions();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Consumer<TrackLibraryProvider>(
          builder: (context, libraryProvider, child) {
            if (libraryProvider.waves.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.mintGreen),
                    SizedBox(height: 16),
                    Text("Loading tracks...", style: TextStyle(color: AppColors.lightGray)),
                  ],
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.darkBlue.withOpacity(0.8), // Semi-transparent
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Gateway Tapes',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 1.1
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
                    ),
                  ),
                  elevation: 0, // No shadow for a cleaner look
                ),
                ...libraryProvider.waves.map((wave) {
                  return SliverMainAxisGroup(slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverWaveHeaderDelegate(wave.name),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = wave.tracks[index];
                          return TrackListItem(
                            track: track,
                            onTap: () {
                              if (track.downloadStatus == DownloadStatus.downloaded) {
                                // Prepare playlist of all downloaded tracks from this wave for Next/Prev
                                List<TrackModel> currentWaveDownloadedTracks = wave.tracks
                                    .where((t) => t.downloadStatus == DownloadStatus.downloaded)
                                    .toList();
                                int trackIndexInWavePlaylist = currentWaveDownloadedTracks.indexOf(track);

                                if (trackIndexInWavePlaylist != -1) {
                                  Provider.of<AudioPlayerProvider>(context, listen: false)
                                      .setPlaylist(currentWaveDownloadedTracks, trackIndexInWavePlaylist);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const PlayerScreen(),
                                    ),
                                  );
                                } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Error: Track not found in playlist.")),
                                  );
                                }
                              }
                            },
                          );
                        },
                        childCount: wave.tracks.length,
                      ),
                    ),
                  ]);
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 20)), // Bottom padding
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SliverWaveHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String waveTitle;

  _SliverWaveHeaderDelegate(this.waveTitle);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 50.0,
      color: AppColors.slateGray.withOpacity(0.95), // Solid color for header background
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        waveTitle,
        style: const TextStyle(
          color: AppColors.mintGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant _SliverWaveHeaderDelegate oldDelegate) {
    return waveTitle != oldDelegate.waveTitle;
  }
}
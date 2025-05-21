import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
//import 'package:just_audio_background/just_audio_background.dart';
import '../models/track_model.dart';

class AudioPlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  TrackModel? _currentTrack;
  List<TrackModel> _playlist = [];
  int _currentIndex = -1;

  TrackModel? get currentTrack => _currentTrack;
  AudioPlayer get audioPlayer => _audioPlayer; // Expose player for advanced controls if needed
  bool get isPlaying => _audioPlayer.playing;
  Duration get currentPosition => _audioPlayer.position;
  Duration get bufferedPosition => _audioPlayer.bufferedPosition;
  Duration get totalDuration => _audioPlayer.duration ?? Duration.zero;

  // Stream for visualization (amplitude)
  Stream<double> get amplitudeStream => _audioPlayer.icyMetadataStream
      .map((metadata) => metadata?.info?.title == 'amplitude' ? double.tryParse(metadata!.info!.title!) ?? 0.5 : 0.5)
      .asBroadcastStream(); // This is a placeholder. Real amplitude needs FFT or similar.
                                // For a simpler visual, you can just check if it's playing.

  AudioPlayerProvider() {
    _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners(); // Notify on any player state change
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });
    _audioPlayer.positionStream.listen((_) => notifyListeners());
    _audioPlayer.bufferedPositionStream.listen((_) => notifyListeners());
    _audioPlayer.durationStream.listen((_) => notifyListeners());
  }

  Future<void> setPlaylist(List<TrackModel> tracks, int initialIndex) async {
    _playlist = tracks.where((t) => t.downloadStatus == DownloadStatus.downloaded && t.localPath != null).toList();
    if (_playlist.isEmpty) return;

    // Find the actual index in the filtered (downloaded) playlist
    TrackModel initialTrack = tracks[initialIndex];
    _currentIndex = _playlist.indexWhere((t) => t.id == initialTrack.id);

    if (_currentIndex != -1) {
       await _loadTrack(_playlist[_currentIndex]);
    } else if (_playlist.isNotEmpty) {
      // If the initially selected track wasn't downloaded, play the first downloaded one
      _currentIndex = 0;
      await _loadTrack(_playlist[_currentIndex]);
    } else {
      _currentTrack = null;
      _currentIndex = -1;
    }
    notifyListeners();
  }

  Future<void> _loadTrack(TrackModel track) async {
    _currentTrack = track;
    if (track.localPath == null || track.downloadStatus != DownloadStatus.downloaded) {
      print("Track not downloaded or path is null: ${track.title}");
      _currentTrack = null; // or handle error
      return;
    }
    try {
      // Modificado: Ya no se usa MediaItem para just_audio_background
      final source = AudioSource.uri(Uri.file(track.localPath!));
      // final source = AudioSource.uri(
      //   Uri.file(track.localPath!),
      //   tag: MediaItem( // For just_audio_background
      //     id: track.id,
      //     album: track.waveName,
      //     title: track.title,
      //     artUri: Uri.parse("https://example.com/placeholder.png"), // Replace with actual art if you have it
      //   ),
      // );
      await _audioPlayer.setAudioSource(source);
    } catch (e) {
      print("Error loading audio source: $e");
      _currentTrack = null;
    }
    notifyListeners();
  }

  Future<void> play() async {
    if (_currentTrack != null) {
      await _audioPlayer.play();
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _loadTrack(_playlist[_currentIndex]);
    await play();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _loadTrack(_playlist[_currentIndex]);
    await play();
  }
  
  // Call this when the app is closing
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
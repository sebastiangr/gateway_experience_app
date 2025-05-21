import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p; // Alias for path package
import '../models/track_model.dart';
import '../models/wave_model.dart';
import '../services/download_service.dart';
import '../utils/constants.dart'; // For AppConstants

// Dummy Data - Replace with your actual track list, potentially fetched from a server manifest
List<WaveModel> _initialWavesData = [
  WaveModel(name: "Wave I: Discovery", tracks: [  
    TrackModel(id: "w1_t1", title: "Orientation", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_01_Orientation.flac"),
    TrackModel(id: "w1_t2", title: "Intro Focus 10", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_02_Introduction_to_Focus_10.flac"),
    TrackModel(id: "w1_t3", title: "Advanced Focus 10", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_03_Advanced_Focus_10.flac"),
    TrackModel(id: "w1_t4", title: "Release and Recharge", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_04_Release_and_Recharge.flac"),
    TrackModel(id: "w1_t5", title: "Exploration Sleep", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_05_Exploration_Sleep.flac"),
    TrackModel(id: "w1_t6", title: "Free Flow 10", waveName: "Wave I", trackUrl: "Wave_I_Discovery/wave-I_06_Free_Flow_10.flac")
  ]),
  WaveModel(name: "Wave II: Threshold", tracks: [
    TrackModel(id: "w2_t1", title: "Intro Focus 12", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_01_Introduction_to_Focus_12.flac"),
    TrackModel(id: "w2_t2", title: "Problem Solving", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_02_Problem_Solving.flac"),
    TrackModel(id: "w2_t3", title: "One Month Patterning", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_03_One-Month_Patterning.flac"),
    TrackModel(id: "w2_t4", title: "Color Breathing", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_04_Color_Breathing.flac"),
    TrackModel(id: "w2_t5", title: "Energy Bar Tool", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_05_Energy_Bar_Tool.flac"),
    TrackModel(id: "w2_t6", title: "Living Body Map", waveName: "Wave II", trackUrl: "Wave_II_Threshold/wave-II_06_Living_Body_Map.flac"),
  ]),
  // Add all your waves and tracks here
];


class TrackLibraryProvider with ChangeNotifier {
  List<WaveModel> _waves = [];
  final DownloadService _downloadService = DownloadService();
  SharedPreferences? _prefs;

  List<WaveModel> get waves => _waves;

  TrackLibraryProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTracksFromSource(); // This could be from a local manifest or a server call
  }

  Future<void> _loadTracksFromSource() async {
    // For MVP, we use the hardcoded list.
    // In a real app, you might fetch this list from a server as a JSON file.
    List<WaveModel> loadedWaves = [];
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String audioBasePath = p.join(appDir.path, 'gateway_audio');

    for (var waveData in _initialWavesData) {
      List<TrackModel> updatedTracks = [];
      for (var trackData in waveData.tracks) {
        String fileName = trackData.trackUrl.replaceAll('/', '_'); // wave1_discovery_01.flac
        String localPath = p.join(audioBasePath, fileName);
        bool isDownloaded = _prefs?.getBool(trackData.id) ?? false; // Check persistent storage
        
        DownloadStatus status = DownloadStatus.none;
        if (isDownloaded) {
            // Double check if file actually exists, in case it was deleted manually
            if (await File(localPath).exists()) {
                status = DownloadStatus.downloaded;
            } else {
                // File marked as downloaded but doesn't exist, reset status
                await _prefs?.setBool(trackData.id, false);
                isDownloaded = false; // update local flag
                status = DownloadStatus.none; 
            }
        }

        updatedTracks.add(trackData.copyWith(
          localPath: isDownloaded ? localPath : null,
          downloadStatus: status,
        ));
      }
      loadedWaves.add(WaveModel(name: waveData.name, tracks: updatedTracks));
    }
    _waves = loadedWaves;
    notifyListeners();
  }


  TrackModel? getTrackById(String id) {
    for (var wave in _waves) {
      for (var track in wave.tracks) {
        if (track.id == id) return track;
      }
    }
    return null;
  }

  Future<void> downloadTrack(TrackModel track) async {
    if (track.downloadStatus == DownloadStatus.downloading || track.downloadStatus == DownloadStatus.downloaded) {
      return;
    }

    // Opcional: Obtiene el tamaño del archivo con HEAD antes de descargar
    // Si no se hace esto, el 'total' vendrá del onReceiveProgress de dio.download
    // int initialTotalSize = await _downloadService.getFileSize(track.fullDownloadUrl);
    // Si se usa getFileSize, se puede pasar initialTotalSize a _updateTrackStatus

    _updateTrackStatus(track.id, DownloadStatus.downloading, 0, 0, 0); // progress, received, total

    String fileName = track.trackUrl.replaceAll('/', '_'); // e.g., wave1_discovery_01.flac
    final String? downloadedPath = await _downloadService.downloadFile(
      url: track.fullDownloadUrl,
      fileName: fileName,     
      onProgress: (received, total) { // Recibimos bytes
        double progress = (total > 0) ? received / total : 0.0;
        // Si 'total' del onReceiveProgress es -1 o 0, y se un 'initialTotalSize' con HEAD,
        // podría usarse 'initialTotalSize' aquí para calcular el progreso.
        // Por ahora, confiamos en el 'total' de onReceiveProgress.        
        _updateTrackStatus(track.id, DownloadStatus.downloading, progress, received, total > 0 ? total : track.totalSizeBytes);
      },
    );

    if (downloadedPath != null) {
      // Asegurarse que al final el progreso sea 1, y received sea igual a total
      _updateTrackStatus(track.id, DownloadStatus.downloaded, 1.0, track.totalSizeBytes, track.totalSizeBytes, localPath: downloadedPath);
      await _prefs?.setBool(track.id, true);
    } else {
      _updateTrackStatus(track.id, DownloadStatus.failed, track.downloadProgress, track.receivedSizeBytes, track.totalSizeBytes);
      await _prefs?.setBool(track.id, false);
    }
  }

  void _updateTrackStatus(String trackId, DownloadStatus status, double progress, int receivedBytes, int totalBytes, {String? localPath}) {
    _waves = _waves.map((wave) {
      return WaveModel(
        name: wave.name,
        tracks: wave.tracks.map((t) {
          if (t.id == trackId) {
            return t.copyWith(
              downloadStatus: status,
              downloadProgress: progress,
              receivedSizeBytes: receivedBytes,
              // Solo actualiza totalSizeBytes si es un valor válido y mayor que el actual,
              // o si estamos iniciando la descarga (totalBytes puede ser 0 inicialmente).
              totalSizeBytes: (totalBytes > 0 && totalBytes >= t.totalSizeBytes) ? totalBytes : t.totalSizeBytes,
              localPath: localPath ?? t.localPath,
            );
          }
          return t;
        }).toList(),
      );
    }).toList();
    notifyListeners();
  }

  // Optional: Function to delete a track
  Future<void> deleteTrack(TrackModel track) async {
    if (track.localPath != null && track.downloadStatus == DownloadStatus.downloaded) {
      try {
        final file = File(track.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _updateTrackStatus(track.id, DownloadStatus.none, 0.0, 0, 0, localPath: null); // Clear localPath
        await _prefs?.setBool(track.id, false);
      } catch (e) {
        print("Error deleting file: $e");
        // Optionally set to a failed delete status if needed
      }
    }
  }
}
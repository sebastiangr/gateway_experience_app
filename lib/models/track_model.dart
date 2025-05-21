import 'package:equatable/equatable.dart';
import 'package:gateway_experience_app/utils/constants.dart';

enum DownloadStatus { none, downloading, downloaded, failed }

class TrackModel extends Equatable {
  final String id; // Unique ID for the track
  final String title;
  final String waveName;
  final String trackUrl; // Relative path on the server, e.g., "wave1/focus10_01.flac"
  String? localPath;
  DownloadStatus downloadStatus;
  double downloadProgress; // 0.0 a 1.0
  int totalSizeBytes;       // Tamaño total del archivo en bytes
  int receivedSizeBytes;    // Bytes recibidos actualmente

  TrackModel({
    required this.id,
    required this.title,
    required this.waveName,
    required this.trackUrl,
    this.localPath,
    this.downloadStatus = DownloadStatus.none,
    this.downloadProgress = 0.0,
    this.totalSizeBytes = 0, // Inicializar
    this.receivedSizeBytes = 0, // Inicializar
  });

  // Helper to get full download URL
  String get fullDownloadUrl => "${AppConstants.serverBaseUrl}/$trackUrl";

  TrackModel copyWith({
    String? id,
    String? title,
    String? waveName,
    String? trackUrl,
    String? localPath,
    DownloadStatus? downloadStatus,
    double? downloadProgress,
    int? totalSizeBytes,
    int? receivedSizeBytes,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      waveName: waveName ?? this.waveName,
      trackUrl: trackUrl ?? this.trackUrl,
      localPath: localPath ?? this.localPath,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      receivedSizeBytes: receivedSizeBytes ?? this.receivedSizeBytes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        waveName,
        trackUrl,
        localPath,
        downloadStatus,
        downloadProgress,
        totalSizeBytes,
        receivedSizeBytes,
      ];
}
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // Alias for path package

class DownloadService {
  final Dio _dio = Dio();

  // Nueva función para obtener el tamaño del archivo
  Future<int> getFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      if (response.statusCode == 200) {
        final contentLength = response.headers.value(Headers.contentLengthHeader);
        return int.tryParse(contentLength ?? '0') ?? 0;
      }
    } catch (e) {
      print("Error getting file size: $e");
    }
    return 0; // Retorna 0 si hay error o no se puede obtener
  }

  Future<String?> downloadFile({
    required String url,
    required String fileName, // e.g., "wave1_track1.flac"
    required Function(int received, int total) onProgress, // Modificado para pasar byte
  }) async {
    print("Attempting to download from URL: $url");
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String savePath = p.join(appDir.path, 'gateway_audio', fileName); // Use path.join

      // Create directory if it doesn't exist
      final Directory saveDir = Directory(p.dirname(savePath)); // Use path.dirname
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) { // total puede ser -1 si el servidor no envía Content-Length
            onProgress(received, total);
          } else {
            // Si total es -1, no podemos calcular el progreso exacto con esta info
            // Podrías pasar solo 'received' y manejar la UI de forma diferente
            onProgress(received, 0); // O pasar un total conocido si lo obtuviste con HEAD
          }
        },
      );
      return savePath;
    } catch (e) {
      print("Download Error: $e");
      return null;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track_model.dart';
import '../providers/track_library_provider.dart';
import '../utils/app_colors.dart';
import 'dart:math' as math; // Para unidades de tamaño

class TrackListItem extends StatelessWidget {
  final TrackModel track;
  final VoidCallback onTap;

  const TrackListItem({
    super.key,
    required this.track,
    required this.onTap,
  });

  // Función para formatear bytes a KB, MB, GB
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }



  @override
  Widget build(BuildContext context) {
    // No es necesario el Provider aquí si la info de descarga se pasa con `track`
    // Pero si quieres que se actualice en tiempo real mientras está en la lista,
    // necesitas el Consumer o Selector como estaba para el botón.

    return InkWell(
      onTap: track.downloadStatus == DownloadStatus.downloaded ? onTap : null,
      splashColor: AppColors.mintGreen.withOpacity(0.1),
      highlightColor: AppColors.mintGreen.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.slateGray.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: track.downloadStatus == DownloadStatus.downloaded
                          ? AppColors.white
                          : AppColors.lightGray.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.waveName,
                    style: TextStyle(
                      fontSize: 12,
                      color: track.downloadStatus == DownloadStatus.downloaded
                          ? AppColors.darkGray
                          : AppColors.darkGray.withOpacity(0.7),
                    ),
                  ),
                  // NUEVO: Mostrar información de descarga si está descargando
                  Consumer<TrackLibraryProvider>( // Usamos Consumer para obtener el 'liveTrack'
                    builder: (context, libraryProvider, child) {
                      final liveTrack = libraryProvider.getTrackById(track.id) ?? track;
                      if (liveTrack.downloadStatus == DownloadStatus.downloading && liveTrack.totalSizeBytes > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "${_formatBytes(liveTrack.receivedSizeBytes, 1)} / ${_formatBytes(liveTrack.totalSizeBytes, 1)}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.mintGreen,
                            ),
                          ),
                        );
                      } else if (liveTrack.downloadStatus == DownloadStatus.downloaded && liveTrack.totalSizeBytes > 0) {
                         return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatBytes(liveTrack.totalSizeBytes, 1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.darkGray,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink(); // No mostrar nada si no aplica
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10), // Reducir un poco el espacio si es necesario
            // El botón de descarga ahora estará en un Consumer para obtener el liveTrack
             _buildDownloadButtonWithProgress(context),
          ],
        ),
      ),
    );
  }

  // Modificamos el botón para que use Consumer y muestre el porcentaje
  Widget _buildDownloadButtonWithProgress(BuildContext context) {
    final libraryProvider = Provider.of<TrackLibraryProvider>(context, listen: false);

    return Consumer<TrackLibraryProvider>(
      builder: (context, provider, child) {
        // Encuentra la versión más reciente del track desde el provider
        // 'track' aquí es el 'this.track' del widget TrackListItem
        final liveTrack = provider.getTrackById(track.id) ?? track;

        Widget iconContent;
        VoidCallback? onPressedAction = () => libraryProvider.downloadTrack(liveTrack);

        switch (liveTrack.downloadStatus) {
          case DownloadStatus.downloaded:
            iconContent = const Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 28);
            onPressedAction = null; // O para permitir borrar
            break;
          case DownloadStatus.downloading:
            // El porcentaje se calcula a partir de downloadProgress (0.0 a 1.0)
            String percentage = (liveTrack.downloadProgress * 100).toStringAsFixed(0);
            iconContent = SizedBox(
              width: 32, // Ajustar tamaño para que quepa el texto y el progress
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: liveTrack.downloadProgress > 0 && liveTrack.downloadProgress < 1
                        ? liveTrack.downloadProgress
                        : null,
                    strokeWidth: 2.5,
                    color: AppColors.mintGreen,
                    backgroundColor: AppColors.darkGray.withOpacity(0.3),
                  ),
                  Text(
                    "$percentage%",
                    style: const TextStyle(
                      fontSize: 9, // Tamaño pequeño para el porcentaje
                      color: AppColors.mintGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
            onPressedAction = null; // No se puede presionar mientras descarga
            break;
          case DownloadStatus.failed:
            iconContent = const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28);
            // onPressedAction ya está configurado para reintentar
            break;
          default: // DownloadStatus.none
            iconContent = const Icon(Icons.download_for_offline_rounded, color: AppColors.lightGray, size: 28);
            // onPressedAction ya está configurado para iniciar descarga
            break;
        }

        if (liveTrack.downloadStatus == DownloadStatus.downloading || liveTrack.downloadStatus == DownloadStatus.downloaded) {
             // Si está descargando o descargado, solo mostramos el contenido (sin IconButton para evitar splash)
             return Container( // Usar Container para alinear y dar tamaño si es necesario
                width: 40, // Ancho similar al de IconButton
                height: 40,
                alignment: Alignment.center,
                child: iconContent,
             );
        } else {
            return IconButton(
              icon: iconContent,
              onPressed: onPressedAction,
              iconSize: 28, // El tamaño del icono base
              style: IconButton.styleFrom(padding: EdgeInsets.zero),
              tooltip: liveTrack.downloadStatus == DownloadStatus.failed ? "Reintentar descarga" : "Descargar",
            );
        }
      },
    );
  }
}
import 'package:equatable/equatable.dart';
import 'track_model.dart';

class WaveModel extends Equatable {
  final String name;
  final List<TrackModel> tracks;

  const WaveModel({required this.name, required this.tracks});

  @override
  List<Object?> get props => [name, tracks];
}
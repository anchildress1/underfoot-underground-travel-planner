import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

@JsonSerializable()
class Place extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double? distance;
  final String? distanceLabel;
  final double? rating;
  final String? category;
  final String? source;
  final double? confidence;
  final String? historicalPeriod;
  final List<String>? artifacts;

  const Place({
    this.id,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.distance,
    this.distanceLabel,
    this.rating,
    this.category,
    this.source,
    this.confidence,
    this.historicalPeriod,
    this.artifacts,
  });

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  String get confidenceLabel =>
      confidence != null ? '${(confidence! * 100).toStringAsFixed(0)}%' : '';

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    latitude,
    longitude,
    imageUrl,
    distance,
    distanceLabel,
    rating,
    category,
    source,
    confidence,
    historicalPeriod,
    artifacts,
  ];
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
  id: json['id'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  imageUrl: json['imageUrl'] as String?,
  distance: (json['distance'] as num?)?.toDouble(),
  distanceLabel: json['distanceLabel'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  category: json['category'] as String?,
  source: json['source'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
  historicalPeriod: json['historicalPeriod'] as String?,
  artifacts: (json['artifacts'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'imageUrl': instance.imageUrl,
  'distance': instance.distance,
  'distanceLabel': instance.distanceLabel,
  'rating': instance.rating,
  'category': instance.category,
  'source': instance.source,
  'confidence': instance.confidence,
  'historicalPeriod': instance.historicalPeriod,
  'artifacts': instance.artifacts,
};

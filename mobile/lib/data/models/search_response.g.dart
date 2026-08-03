// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchRequest _$SearchRequestFromJson(Map<String, dynamic> json) =>
    SearchRequest(
      chatInput: json['chat_input'] as String,
      userLocation: json['user_location'] as String?,
      force: json['force'] as bool? ?? false,
    );

Map<String, dynamic> _$SearchRequestToJson(SearchRequest instance) =>
    <String, dynamic>{
      'chat_input': instance.chatInput,
      'user_location': ?instance.userLocation,
      'force': instance.force,
    };

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    SearchResponse(
      userIntent: json['user_intent'] as String?,
      userLocation: json['user_location'] as String?,
      response: json['response'] as String,
      places: (json['places'] as List<dynamic>)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList(),
      debug: json['debug'] == null
          ? null
          : DebugInfo.fromJson(json['debug'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResponseToJson(SearchResponse instance) =>
    <String, dynamic>{
      'user_intent': instance.userIntent,
      'user_location': instance.userLocation,
      'response': instance.response,
      'places': instance.places,
      'debug': instance.debug,
    };

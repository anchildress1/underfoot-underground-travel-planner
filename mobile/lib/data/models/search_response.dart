import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'place.dart';
import 'debug_info.dart';

part 'search_response.g.dart';

@JsonSerializable()
class SearchRequest extends Equatable {
  @JsonKey(name: 'chat_input')
  final String chatInput;
  
  @JsonKey(name: 'user_location')
  final String? userLocation;
  
  final bool force;

  const SearchRequest({
    required this.chatInput, 
    this.userLocation,
    this.force = false,
  });

  factory SearchRequest.fromJson(Map<String, dynamic> json) =>
      _$SearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SearchRequestToJson(this);

  @override
  List<Object?> get props => [chatInput, userLocation, force];
}

@JsonSerializable()
class SearchResponse extends Equatable {
  @JsonKey(name: 'user_intent')
  final String? userIntent;

  @JsonKey(name: 'user_location')
  final String? userLocation;

  final String response;
  final List<Place> places;
  final DebugInfo? debug;

  const SearchResponse({
    this.userIntent,
    this.userLocation,
    required this.response,
    required this.places,
    this.debug,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);

  @override
  List<Object?> get props => [
    userIntent,
    userLocation,
    response,
    places,
    debug,
  ];
}

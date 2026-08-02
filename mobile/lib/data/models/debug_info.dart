import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'debug_info.g.dart';

@JsonSerializable()
class DebugInfo extends Equatable {
  @JsonKey(name: 'request_id')
  final String? requestId;

  @JsonKey(name: 'execution_time_ms')
  final int? executionTimeMs;

  final CacheInfo? cache;

  @JsonKey(name: 'upstream_status')
  final Map<String, dynamic>? upstreamStatus;

  @JsonKey(name: 'search_query')
  final String? searchQuery;

  final double? confidence;

  final List<String>? keywords;

  @JsonKey(name: 'geospatial_data')
  final GeospatialData? geospatialData;

  @JsonKey(name: 'llm_reasoning')
  final String? llmReasoning;

  @JsonKey(name: 'data_sources')
  final List<String>? dataSources;

  @JsonKey(name: 'tool_calls')
  final List<ToolCallInfo>? toolCalls;

  const DebugInfo({
    this.requestId,
    this.executionTimeMs,
    this.cache,
    this.upstreamStatus,
    this.searchQuery,
    this.confidence,
    this.keywords,
    this.geospatialData,
    this.llmReasoning,
    this.dataSources,
    this.toolCalls,
  });

  factory DebugInfo.fromJson(Map<String, dynamic> json) =>
      _$DebugInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DebugInfoToJson(this);

  String get processingTimeLabel =>
      executionTimeMs != null ? '${executionTimeMs}ms' : 'N/A';

  String get confidenceLabel =>
      confidence != null ? '${(confidence! * 100).toStringAsFixed(1)}%' : 'N/A';

  @override
  List<Object?> get props => [
    requestId,
    executionTimeMs,
    cache,
    upstreamStatus,
    searchQuery,
    confidence,
    keywords,
    geospatialData,
    llmReasoning,
    dataSources,
    toolCalls,
  ];
}

@JsonSerializable()
class ToolCallInfo extends Equatable {
  final String name;
  final int count;
  final int? durationMs;

  const ToolCallInfo({required this.name, required this.count, this.durationMs});

  factory ToolCallInfo.fromJson(Map<String, dynamic> json) =>
      _$ToolCallInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallInfoToJson(this);

  @override
  List<Object?> get props => [name, count, durationMs];
}

@JsonSerializable()
class CacheInfo extends Equatable {
  final bool? hit;
  final String? key;

  const CacheInfo({this.hit, this.key});

  factory CacheInfo.fromJson(Map<String, dynamic> json) =>
      _$CacheInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CacheInfoToJson(this);

  @override
  List<Object?> get props => [hit, key];
}

@JsonSerializable()
class GeospatialData extends Equatable {
  @JsonKey(name: 'bounding_box')
  final List<double>? boundingBox;

  @JsonKey(name: 'center_point')
  final List<double>? centerPoint;

  @JsonKey(name: 'search_radius')
  final double? searchRadius;

  const GeospatialData({this.boundingBox, this.centerPoint, this.searchRadius});

  factory GeospatialData.fromJson(Map<String, dynamic> json) =>
      _$GeospatialDataFromJson(json);

  Map<String, dynamic> toJson() => _$GeospatialDataToJson(this);

  String get centerLabel => centerPoint != null && centerPoint!.length >= 2
      ? '${centerPoint![0].toStringAsFixed(4)}, ${centerPoint![1].toStringAsFixed(4)}'
      : 'N/A';

  String get radiusLabel =>
      searchRadius != null ? '${searchRadius!.toStringAsFixed(0)}m' : 'N/A';

  @override
  List<Object?> get props => [boundingBox, centerPoint, searchRadius];
}

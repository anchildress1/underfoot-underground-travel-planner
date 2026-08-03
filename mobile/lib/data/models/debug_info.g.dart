// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebugInfo _$DebugInfoFromJson(Map<String, dynamic> json) => DebugInfo(
  requestId: json['request_id'] as String?,
  executionTimeMs: (json['execution_time_ms'] as num?)?.toInt(),
  cache: json['cache'] as String?,
  upstreamStatus: (json['upstream_status'] as num?)?.toInt(),
  upstreamError: json['upstream_error'] as String?,
  searchQuery: json['search_query'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble(),
  keywords: (json['keywords'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  geospatialData: json['geospatial_data'] == null
      ? null
      : GeospatialData.fromJson(
          json['geospatial_data'] as Map<String, dynamic>,
        ),
  llmReasoning: json['llm_reasoning'] as String?,
  dataSources: (json['data_sources'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  toolCalls: (json['tool_calls'] as List<dynamic>?)
      ?.map((e) => ToolCallInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DebugInfoToJson(DebugInfo instance) => <String, dynamic>{
  'request_id': instance.requestId,
  'execution_time_ms': instance.executionTimeMs,
  'cache': instance.cache,
  'upstream_status': instance.upstreamStatus,
  'upstream_error': instance.upstreamError,
  'search_query': instance.searchQuery,
  'confidence': instance.confidence,
  'keywords': instance.keywords,
  'geospatial_data': instance.geospatialData,
  'llm_reasoning': instance.llmReasoning,
  'data_sources': instance.dataSources,
  'tool_calls': instance.toolCalls,
};

ToolCallInfo _$ToolCallInfoFromJson(Map<String, dynamic> json) => ToolCallInfo(
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$ToolCallInfoToJson(ToolCallInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'durationMs': instance.durationMs,
    };

GeospatialData _$GeospatialDataFromJson(Map<String, dynamic> json) =>
    GeospatialData(
      boundingBox: (json['bounding_box'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      centerPoint: (json['center_point'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      searchRadius: (json['search_radius'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$GeospatialDataToJson(GeospatialData instance) =>
    <String, dynamic>{
      'bounding_box': instance.boundingBox,
      'center_point': instance.centerPoint,
      'search_radius': instance.searchRadius,
    };

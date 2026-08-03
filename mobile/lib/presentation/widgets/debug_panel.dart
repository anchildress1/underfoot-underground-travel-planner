import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class DebugPanel extends StatelessWidget {
  final DebugInfo? debugInfo;
  final bool isVisible;
  final VoidCallback onClose;

  const DebugPanel({
    super.key,
    required this.debugInfo,
    required this.isVisible,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: debugInfo == null
                ? _buildEmpty(context)
                : _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Debug',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No data',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (debugInfo!.executionTimeMs != null)
          _buildRow('Time', '${debugInfo!.executionTimeMs}ms'),
        if (debugInfo!.confidence != null)
          _buildRow(
            'Confidence',
            '${(debugInfo!.confidence! * 100).toStringAsFixed(0)}%',
          ),
        if (debugInfo!.searchQuery != null)
          _buildRow('Query', debugInfo!.searchQuery!, mono: true),
        if (debugInfo!.keywords != null && debugInfo!.keywords!.isNotEmpty)
          _buildRow('Keywords', debugInfo!.keywords!.join(', ')),
        if (debugInfo!.toolCalls != null && debugInfo!.toolCalls!.isNotEmpty)
          _buildToolCallsSection(debugInfo!.toolCalls!),
        if (debugInfo!.llmReasoning != null)
          _buildRow('Reasoning', debugInfo!.llmReasoning!),
        if (debugInfo!.dataSources != null &&
            debugInfo!.dataSources!.isNotEmpty)
          _buildRow('Sources', debugInfo!.dataSources!.join(', ')),
        if (debugInfo!.cache != null)
          _buildRow('Cache', debugInfo!.cache!.toUpperCase()),
        if (debugInfo!.geospatialData != null) ...[
          _buildRow('Center', debugInfo!.geospatialData!.centerLabel),
          _buildRow('Radius', debugInfo!.geospatialData!.radiusLabel),
        ],
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontFamily: mono ? 'monospace' : null,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCallsSection(List<ToolCallInfo> toolCalls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOOL CALLS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ...toolCalls.map((tool) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tool.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Text(
                  'x${tool.count}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                if (tool.durationMs != null)
                  Text(
                    ' (${tool.durationMs}ms)',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

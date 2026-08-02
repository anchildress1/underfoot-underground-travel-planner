import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../core/theme/colors.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label:
          '${place.name}. ${place.confidenceLabel.isNotEmpty ? "Confidence ${place.confidenceLabel}." : ""} ${place.distanceLabel ?? ""}. Tap to select.',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 180,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.electricViolet : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: place.imageUrl != null
                          ? Image.network(
                              place.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _PlaceholderImage(
                                    name: place.name,
                                    theme: theme,
                                  ),
                            )
                          : _PlaceholderImage(name: place.name, theme: theme),
                    ),
                  ),
                  if (place.confidence != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _ConfidenceBadge(
                        confidence: place.confidence!,
                        theme: theme,
                      ),
                    ),
                  if (place.category != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          place.category!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (place.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          place.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          if (place.distanceLabel != null) ...[
                            Icon(
                              Icons.directions_walk,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              place.distanceLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (place.historicalPeriod != null) ...[
                            Icon(
                              Icons.history,
                              size: 12,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                place.historicalPeriod!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final ThemeData theme;

  const _ConfidenceBadge({required this.confidence, required this.theme});

  Color get _color {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String name;
  final ThemeData theme;

  const _PlaceholderImage({required this.name, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.place,
        size: 40,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

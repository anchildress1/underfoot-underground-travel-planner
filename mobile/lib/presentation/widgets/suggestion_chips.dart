import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SuggestionChips extends StatelessWidget {
  final List<SuggestionChip> suggestions;
  final ValueChanged<String>? onChipTap;

  const SuggestionChips({super.key, required this.suggestions, this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: suggestions.map((suggestion) {
        return _SuggestionChipWidget(
          suggestion: suggestion,
          onTap: () => onChipTap?.call(suggestion.label),
        );
      }).toList(),
    );
  }
}

class SuggestionChip {
  final IconData icon;
  final String label;
  final Color? color;

  const SuggestionChip({required this.icon, required this.label, this.color});
}

class _SuggestionChipWidget extends StatelessWidget {
  final SuggestionChip suggestion;
  final VoidCallback onTap;

  const _SuggestionChipWidget({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Design: Light/White background with colored icon, rounded
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final iconColor = suggestion.color ?? AppColors.magenta;

    return Semantics(
      button: true,
      label: 'Suggest ${suggestion.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle, // Circular background for icon
                  ),
                  child: Icon(suggestion.icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(
                  suggestion.label, 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultSuggestions {
  static const List<SuggestionChip> all = [
    SuggestionChip(
      icon: Icons.restaurant,
      label: 'Food nearby',
      color: AppColors.info, // Cyan/Blue
    ),
    SuggestionChip(
      icon: Icons.favorite, // Heart icon for Museums/Likes per design often
      label: 'Museums',
      color: AppColors.magenta, // Pink/Magenta
    ),
    // Keeping a couple more useful ones but styled correctly
    SuggestionChip(
      icon: Icons.park, 
      label: 'Parks', 
      color: AppColors.success
    ),
  ];
}

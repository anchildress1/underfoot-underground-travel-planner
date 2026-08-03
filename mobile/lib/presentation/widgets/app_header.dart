import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/colors.dart';
import '../blocs/theme/theme_cubit.dart';
import 'mode_tabs.dart';

class AppHeader extends StatelessWidget {
  final TripMode selectedMode;
  final ValueChanged<TripMode> onModeChanged;
  final VoidCallback? onToggleDebug;
  final bool debugVisible;

  const AppHeader({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.onToggleDebug,
    this.debugVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.electricViolet, AppColors.magenta],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Underfoot',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Underground Travel Planner',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onToggleDebug != null)
                  IconButton(
                    onPressed: onToggleDebug,
                    icon: Icon(
                      Icons.bug_report,
                      color: debugVisible
                          ? AppColors.electricViolet
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    tooltip: debugVisible
                        ? 'Hide debug console (Ctrl+D)'
                        : 'Show debug console (Ctrl+D)',
                  ),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    final isDark = state.mode == ThemeMode.dark;
                    return IconButton(
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      tooltip: isDark
                          ? 'Switch to light mode (Ctrl+K)'
                          : 'Switch to dark mode (Ctrl+K)',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ModeTabs(
                selectedMode: selectedMode,
                onModeChanged: onModeChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

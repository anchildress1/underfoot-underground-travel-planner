import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat/chat.dart';
import '../blocs/theme/theme_cubit.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _debugVisible = false;
  TripMode _selectedMode = TripMode.plan;
  final FocusNode _chatFocusNode = FocusNode();

  @override
  void dispose() {
    _chatFocusNode.dispose();
    super.dispose();
  }

  void _toggleDebug() {
    setState(() => _debugVisible = !_debugVisible);
  }

  void _focusChat() {
    _chatFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.slash, control: true):
              _focusChat,
          const SingleActivator(LogicalKeyboardKey.keyD, control: true):
              _toggleDebug,
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
            context.read<ThemeCubit>().toggleTheme();
          },
          const SingleActivator(LogicalKeyboardKey.slash, meta: true):
              _focusChat,
          const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
              _toggleDebug,
          const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
            context.read<ThemeCubit>().toggleTheme();
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                if (isWide) {
                  return _WideLayout(
                    selectedMode: _selectedMode,
                    onModeChanged: (mode) => setState(() => _selectedMode = mode),
                    debugVisible: _debugVisible,
                    onToggleDebug: _toggleDebug,
                    chatFocusNode: _chatFocusNode,
                  );
                }

                return _NarrowLayout(
                  selectedMode: _selectedMode,
                  onModeChanged: (mode) => setState(() => _selectedMode = mode),
                  debugVisible: _debugVisible,
                  onToggleDebug: _toggleDebug,
                  chatFocusNode: _chatFocusNode,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WideLayout extends StatelessWidget {
  final TripMode selectedMode;
  final ValueChanged<TripMode> onModeChanged;
  final bool debugVisible;
  final VoidCallback onToggleDebug;
  final FocusNode chatFocusNode;

  const _WideLayout({
    required this.selectedMode,
    required this.onModeChanged,
    required this.debugVisible,
    required this.onToggleDebug,
    required this.chatFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final latestDebugInfo =
            state.messages.isNotEmpty ? state.messages.last.debug : null;

        return Row(
          children: [
            // Chat Panel - Solid Background
            Container(
              width: 400,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AppHeader(
                    selectedMode: selectedMode,
                    onModeChanged: onModeChanged,
                    onToggleDebug: onToggleDebug,
                    debugVisible: debugVisible,
                  ),
                  Expanded(
                    child: ChatPanel(chatFocusNode: chatFocusNode),
                  ),
                ],
              ),
            ),
            // Map View
            Expanded(
              child: const MapView(),
            ),
            // Debug Panel Overlay
            if (debugVisible)
              DebugPanel(
                debugInfo: latestDebugInfo,
                isVisible: debugVisible,
                onClose: onToggleDebug,
              ),
          ],
        );
      },
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final TripMode selectedMode;
  final ValueChanged<TripMode> onModeChanged;
  final bool debugVisible;
  final VoidCallback onToggleDebug;
  final FocusNode chatFocusNode;

  const _NarrowLayout({
    required this.selectedMode,
    required this.onModeChanged,
    required this.debugVisible,
    required this.onToggleDebug,
    required this.chatFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final latestDebugInfo =
            state.messages.isNotEmpty ? state.messages.last.debug : null;

        return Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  selectedMode: selectedMode,
                  onModeChanged: onModeChanged,
                  onToggleDebug: onToggleDebug,
                  debugVisible: debugVisible,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Map background
                      const Positioned.fill(child: MapView()),
                      // Chat overlay with solid background
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: ChatPanel(chatFocusNode: chatFocusNode),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Debug Panel Overlay
            if (debugVisible)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: DebugPanel(
                  debugInfo: latestDebugInfo,
                  isVisible: debugVisible,
                  onClose: onToggleDebug,
                ),
              ),
          ],
        );
      },
    );
  }
}

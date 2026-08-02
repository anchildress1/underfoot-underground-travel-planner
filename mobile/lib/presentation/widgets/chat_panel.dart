import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';
import '../blocs/chat/chat.dart';
import 'message_bubble.dart';
import 'chat_input.dart';
import 'place_card.dart';
import 'suggestion_chips.dart';

class ChatPanel extends StatelessWidget {
  final FocusNode? chatFocusNode;

  const ChatPanel({super.key, this.chatFocusNode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: state.messages.isEmpty
                  ? const _EmptyState()
                  : _MessageList(
                      messages: state.messages,
                      isLoading: state.status == ChatStatus.loading,
                    ),
            ),
            if (state.allPlaces.isNotEmpty)
              _PlacesCarousel(
                places: state.allPlaces,
                selectedPlace: state.selectedPlace,
              ),
            ChatInput(
              onSend: (message) {
                context.read<ChatBloc>().add(
                  ChatMessageSent(
                    message, 
                    userLocation: 'Grundy, VA',
                  ),
                );
              },
              enabled: state.status != ChatStatus.loading,
              focusNode: chatFocusNode,
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore,
                size: 48,
                color: AppColors.magenta,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'Where to next?', 
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'I can help you plan the perfect trip to Grundy, VA or find hidden gems nearby.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUGGESTIONS', 
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SuggestionChips(
              suggestions: DefaultSuggestions.all,
              onChipTap: (label) {
                context.read<ChatBloc>().add(
                  ChatMessageSent(
                    'Find $label',
                    userLocation: 'Grundy, VA',
                  ),
                );
              },
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isLoading;

  const _MessageList({required this.messages, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return const _LoadingIndicator();
        }
        return MessageBubble(message: messages[index]);
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
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
            SizedBox(
              width: 12, 
              height: 12, 
              child: CircularProgressIndicator(
                strokeWidth: 2, 
                color: AppColors.magenta,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thinking...', 
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}

class _PlacesCarousel extends StatelessWidget {
  final List<dynamic> places;
  final dynamic selectedPlace;

  const _PlacesCarousel({required this.places, this.selectedPlace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Icon(Icons.place, size: 16, color: AppColors.magenta),
              const SizedBox(width: 8),
              Text(
                'Places to Consider', 
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return PlaceCard(
                place: place,
                isSelected: place == selectedPlace,
                onTap: () {
                  context.read<ChatBloc>().add(ChatPlaceSelected(index));
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

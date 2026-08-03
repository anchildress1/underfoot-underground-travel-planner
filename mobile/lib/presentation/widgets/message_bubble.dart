import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';
import '../blocs/chat/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isUser 
        ? (isDark ? AppColors.userBubbleDark : AppColors.userBubbleLight)
        : (isDark ? AppColors.assistantBubbleDark : AppColors.assistantBubbleLight);
        
    final textColor = isUser 
        ? Colors.white 
        : (isDark ? AppColors.darkText : AppColors.lightText);

    return Semantics(
      label: '${isUser ? "You" : "Assistant"}: ${message.content}',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isUser ? null : bgColor, // Gradient for user, solid for assistant
            gradient: isUser ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? AppColors.electricViolet : Colors.black).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SelectableText(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ).animate()
          .fade(duration: 300.ms)
          .slideY(
            begin: 0.1, 
            end: 0, 
            curve: Curves.easeOut,
            duration: 300.ms
          ),
      ),
    );
  }
}

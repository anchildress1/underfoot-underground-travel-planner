import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/core/theme/colors.dart';

void main() {
  group('AppColors', () {
    test('electricViolet has correct value', () {
      expect(AppColors.electricViolet, const Color(0xFF7953FC));
    });

    test('magenta has correct value', () {
      expect(AppColors.magenta, const Color(0xFF3E5CFF));
    });

    test('lightBackground has correct value', () {
      expect(AppColors.lightBackground, const Color(0xFFF9DFFC));
    });

    test('darkBackground has correct value', () {
      expect(AppColors.darkBackground, const Color(0xFF0A0E1A));
    });

    test('accent has correct value', () {
      expect(AppColors.accent, const Color(0xFF9D4EDD));
    });

    test('success has correct value', () {
      expect(AppColors.success, const Color(0xFF34A853));
    });

    test('error has correct value', () {
      expect(AppColors.error, const Color(0xFFEA4335));
    });

    test('chatUserBubble has correct value', () {
      expect(AppColors.chatUserBubble, const Color(0xFF7953FC));
    });

    test('chatAssistantBubbleLight has correct value', () {
      expect(AppColors.chatAssistantBubbleLight, const Color(0xFFE8DEF8));
    });

    test('chatAssistantBubbleDark has correct value', () {
      expect(AppColors.chatAssistantBubbleDark, const Color(0xFF2D2D44));
    });
  });
}

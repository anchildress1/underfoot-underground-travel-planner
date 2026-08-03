import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/core/theme/colors.dart';

void main() {
  group('AppColors', () {
    test('Dream Horizon palette values are correct', () {
      expect(AppColors.darkBackground, const Color(0xFF080A12));
      expect(AppColors.lightBackground, const Color(0xFFF5F6FA));
      expect(AppColors.electricViolet, const Color(0xFF7953FC));
      expect(AppColors.magenta, const Color(0xFF3E5CFF));
      expect(AppColors.cyan, const Color(0xFF00E5FF));
    });

    test('semantic colors map to theme', () {
      expect(AppColors.primary, AppColors.electricViolet);
      expect(AppColors.accent, AppColors.cyan);
      expect(AppColors.success, const Color(0xFF00E096));
    });

    test('chat bubble colors are correct', () {
      expect(AppColors.userBubbleLight, AppColors.electricViolet);
      expect(AppColors.assistantBubbleLight, Colors.white);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:family_task_app/helpers/zodiac_helper.dart';

void main() {
  group('Zodiac Helper Tests', () {
    test('Calculates zodiac correctly for known years', () {
      expect(ZodiacHelper.getName(2024), contains("Thìn")); // 2024 % 12 = 8
      expect(ZodiacHelper.getName(2025), contains("Tỵ")); // 2025 % 12 = 9
      expect(ZodiacHelper.getName(2026), contains("Ngọ")); // 2026 % 12 = 10
    });

    test('Returns correct emoji', () {
      expect(ZodiacHelper.getEmoji(2024), equals("🐉"));
      expect(ZodiacHelper.getEmoji(2026), equals("🐎"));
    });
  });
}

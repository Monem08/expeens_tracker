import 'package:expeens_tracker/data/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('defaults to dollar symbol with two decimals and thousands separators', () {
      expect(formatMoney(1234567.89), r'$1,234,567.89');
      expect(formatMoney(0), r'$0.00');
    });

    test('prefixes negative values with minus outside the symbol', () {
      expect(formatMoney(-42.5), r'-$42.50');
    });

    test('uses custom symbol', () {
      expect(formatMoney(100, symbol: '€'), '€100.00');
      expect(formatMoney(-3, symbol: '৳'), '-৳3.00');
    });
  });
}

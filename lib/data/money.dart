/// Centralised currency formatting so the symbol chosen in Profile flows
/// through every screen (Home balance, Bills card, tiles, details, etc.).
///
/// Negative numbers render as `-$500.00` — the minus sign sits outside the
/// symbol so it doesn't get caught up in the thousands-separator logic.
String formatMoney(double value, {String symbol = '\$'}) {
  final negative = value < 0;
  final s = value.abs().toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final formatted = '$symbol${buf.toString()}.${parts[1]}';
  return negative ? '-$formatted' : formatted;
}

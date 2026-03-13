String formatCurrency(double amount, String currency) {
  if (currency == 'USD') {
    return '\$${amount.toStringAsFixed(2)}';
  }

  final whole = amount.round().toString();
  final buffer = StringBuffer();

  for (var index = 0; index < whole.length; index++) {
    final reverseIndex = whole.length - index;
    buffer.write(whole[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${buffer.toString()}đ';
}

String formatSold(int soldCount) {
  if (soldCount >= 1000000) {
    return '${(soldCount / 1000000).toStringAsFixed(1)}m';
  }

  if (soldCount >= 1000) {
    return '${(soldCount / 1000).toStringAsFixed(1)}k';
  }

  return soldCount.toString();
}

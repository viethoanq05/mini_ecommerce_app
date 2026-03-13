class CurrencyModel {
  final String code;
  final String symbol;
  final double exchangeRate; // Rate relative to USD (base)

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.exchangeRate,
  });
}

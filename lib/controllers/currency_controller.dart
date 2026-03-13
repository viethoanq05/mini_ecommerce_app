import 'package:flutter/material.dart';
import '../models/currency_model.dart';

class CurrencyController extends ChangeNotifier {
  static final Map<String, CurrencyModel> currencies = {
    'USD': const CurrencyModel(code: 'USD', symbol: '\$', exchangeRate: 1.0),
    'VND': const CurrencyModel(code: 'VND', symbol: 'đ', exchangeRate: 24500.0),
    'EUR': const CurrencyModel(code: 'EUR', symbol: '€', exchangeRate: 0.92),
  };

  CurrencyModel _currentCurrency = currencies['USD']!;

  CurrencyModel get currentCurrency => _currentCurrency;

  void changeCurrency(String code) {
    if (currencies.containsKey(code)) {
      _currentCurrency = currencies[code]!;
      notifyListeners();
    }
  }

  double convert(double amount) {
    return amount * _currentCurrency.exchangeRate;
  }

  String formatPrice(double amount) {
    double converted = convert(amount);
    if (_currentCurrency.code == 'VND') {
      return '${converted.toStringAsFixed(0)} ${_currentCurrency.symbol}';
    }
    return '${_currentCurrency.symbol}${converted.toStringAsFixed(2)}';
  }
}

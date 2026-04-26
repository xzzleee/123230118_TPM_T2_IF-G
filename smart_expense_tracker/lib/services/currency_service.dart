import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.frankfurter.app/latest?from=IDR';

  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'JPY',
    'GBP',
    'SGD',
    'MYR',
    'AUD',
  ];

  Future<Map<String, double>> fetchRates() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawRates = data['rates'] as Map<String, dynamic>;
      return rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } else {
      throw Exception('Gagal mengambil data kurs: ${response.statusCode}');
    }
  }

  double convert({
    required double amountIDR,
    required double rate,
  }) {
    return amountIDR * rate;
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';
import 'add_transaction_screen.dart' show ThousandSeparatorFormatter;

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountController = TextEditingController();
  final _currencyService = CurrencyService();

  String _selectedCurrency = 'USD';
  Map<String, double> _rates = {};
  double? _convertedResult;
  bool _isLoading = false;
  bool _isFetching = false;
  String? _errorMessage;
  String? _lastUpdated;

  final Map<String, String> _currencyNames = {
    'USD': '🇺🇸 Dolar Amerika',
    'EUR': '🇪🇺 Euro',
    'JPY': '🇯🇵 Yen Jepang',
    'GBP': '🇬🇧 Pound Sterling',
    'SGD': '🇸🇬 Dolar Singapura',
    'MYR': '🇲🇾 Ringgit Malaysia',
    'AUD': '🇦🇺 Dolar Australia',
  };

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isFetching = true;
      _errorMessage = null;
    });
    try {
      final rates = await _currencyService.fetchRates();
      setState(() {
        _rates = rates;
        _isFetching = false;
        _lastUpdated = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
      });
    } catch (e) {
      setState(() {
        _isFetching = false;
        _errorMessage = 'Gagal memuat kurs. Periksa koneksi internet Anda.';
      });
    }
  }

  void _convert() {
    final raw = _amountController.text.trim().replaceAll('.', '');
    if (raw.isEmpty) {
      setState(() => _errorMessage = 'Masukkan jumlah rupiah terlebih dahulu');
      return;
    }

    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'Jumlah tidak valid');
      return;
    }

    if (!_rates.containsKey(_selectedCurrency)) {
      setState(
          () => _errorMessage = 'Kurs tidak tersedia, coba refresh ulang');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final rate = _rates[_selectedCurrency]!;
      setState(() {
        _convertedResult = _currencyService.convert(
          amountIDR: amount,
          rate: rate,
        );
        _isLoading = false;
      });
    });
  }

  String _formatResult(double value) {
    if (_selectedCurrency == 'JPY') {
      return NumberFormat('#,##0', 'en_US').format(value);
    }
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Konversi Mata Uang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: _isFetching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
            onPressed: _isFetching ? null : _fetchRates,
            tooltip: 'Refresh kurs',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastUpdated != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF00897B), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Kurs diperbarui: $_lastUpdated',
                      style: const TextStyle(
                          color: Color(0xFF00897B), fontSize: 12),
                    ),
                  ],
                ),
              ),

            if (_isFetching)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.orange),
                    ),
                    SizedBox(width: 10),
                    Text('Mengambil data kurs...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            const Text('Jumlah Rupiah (IDR)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandSeparatorFormatter()],
              onChanged: (_) => setState(() => _convertedResult = null),
              decoration: InputDecoration(
                hintText: 'Contoh: 1.000.000',
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                    color: Color(0xFF00897B), fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF00897B), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Mata Uang Tujuan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCurrency,
                  onChanged: (val) {
                    setState(() {
                      _selectedCurrency = val!;
                      _convertedResult = null;
                    });
                  },
                  items: CurrencyService.supportedCurrencies.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(
                        _currencyNames[code] ?? code,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isFetching ? null : _convert,
                icon: const Icon(Icons.currency_exchange_rounded),
                label: const Text(
                  'Konversi Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                            color: Colors.red.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _convertedResult != null
                      ? Container(
                          key: ValueKey(_convertedResult),
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00897B), Color(0xFF004D40)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00897B).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Hasil Konversi',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_formatResult(_convertedResult!)} $_selectedCurrency',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '1 IDR = ${NumberFormat('#,##0.######').format(_rates[_selectedCurrency] ?? 0)} $_selectedCurrency',
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Hasil Konversi',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '0.00 $_selectedCurrency',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),

            const SizedBox(height: 24),

            if (_rates.isNotEmpty) ...[
              const Text(
                'Tabel Kurs (dari IDR)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: CurrencyService.supportedCurrencies
                      .where((c) => _rates.containsKey(c))
                      .map((code) {
                    final rate = _rates[code]!;
                    return ListTile(
                      dense: true,
                      title: Text(
                        _currencyNames[code] ?? code,
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Text(
                        '${NumberFormat('#,##0.######').format(rate)} $code',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00897B),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
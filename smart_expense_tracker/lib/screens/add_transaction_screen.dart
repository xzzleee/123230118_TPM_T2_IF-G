import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final digits = newValue.text.replaceAll('.', '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) return oldValue;

    final formatted = NumberFormat('#,##0', 'id_ID').format(int.parse(digits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory _selectedCategory = TransactionCategory.makan;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00897B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text.replaceAll('.', '')),
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    await context.read<TransactionProvider>().addTransaction(transaction);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaksi berhasil disimpan!'),
        backgroundColor: const Color(0xFF00897B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedType = TransactionType.expense;
      _selectedCategory = TransactionCategory.makan;
      _selectedDate = DateTime.now();
    });
  }

  List<TransactionCategory> get _availableCategories {
    if (_selectedType == TransactionType.income) {
      return [
        TransactionCategory.gaji,
        TransactionCategory.lainnya,
      ];
    }
    return TransactionCategory.values
        .where((c) =>
            c != TransactionCategory.gaji)
        .toList();
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
          'Tambah Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jenis Transaksi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = TransactionCategory.makan;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? Colors.red.shade400
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                color: _selectedType == TransactionType.expense
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pengeluaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == TransactionType.expense
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = TransactionCategory.gaji;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? Colors.green.shade500
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                color: _selectedType == TransactionType.income
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pemasukan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedType == TransactionType.income
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Nominal (Rp)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandSeparatorFormatter()],
                decoration: InputDecoration(
                  hintText: 'Contoh: 50.000',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  final clean = value.replaceAll('.', '');
                  final amount = double.tryParse(clean);
                  if (amount == null || amount <= 0) {
                    return 'Nominal harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TransactionCategory>(
                    isExpanded: true,
                    value: _selectedCategory,
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                    items: _availableCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text(cat.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Tanggal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Color(0xFF00897B), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMMM yyyy', 'id_ID')
                            .format(_selectedDate),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Catatan (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan...',
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
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
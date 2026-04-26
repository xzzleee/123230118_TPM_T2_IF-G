import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  void _showDetail(BuildContext context, Transaction tx) {
    final isExpense = tx.type == TransactionType.expense;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(tx.category.emoji,
                      style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tx.category.label,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${isExpense ? '-' : '+'} ${_formatRupiah(tx.amount)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.red.shade600 : Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 20),
              _DetailRow(
                label: 'Jenis',
                value: isExpense ? 'Pengeluaran' : 'Pemasukan',
                valueColor:
                    isExpense ? Colors.red.shade600 : Colors.green.shade600,
              ),
              _DetailRow(
                label: 'Tanggal',
                value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tx.date),
              ),
              _DetailRow(
                label: 'Kategori',
                value: tx.category.label,
              ),
              if (tx.note.isNotEmpty)
                _DetailRow(
                  label: 'Catatan',
                  value: tx.note,
                ),
              _DetailRow(
                label: 'ID Transaksi',
                value: '#${tx.id}',
                valueColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context
                        .read<TransactionProvider>()
                        .deleteTransaction(tx.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Transaksi dihapus'),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Hapus Transaksi'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat transaksi',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final grouped = <String, List<Transaction>>{};
          for (final tx in provider.transactions) {
            final key =
                DateFormat('dd MMMM yyyy', 'id_ID').format(tx.date);
            grouped.putIfAbsent(key, () => []).add(tx);
          }

          final dateKeys = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dateKeys.length,
            itemBuilder: (context, i) {
              final dateLabel = dateKeys[i];
              final txList = grouped[dateLabel]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...txList.map((tx) {
                    final isExpense = tx.type == TransactionType.expense;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showDetail(context, tx),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isExpense
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(tx.category.emoji,
                                      style: const TextStyle(fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.category.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    if (tx.note.isNotEmpty)
                                      Text(
                                        tx.note,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${isExpense ? '-' : '+'} ${_formatRupiah(tx.amount)}',
                                    style: TextStyle(
                                      color: isExpense
                                          ? Colors.red.shade600
                                          : Colors.green.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isExpense ? 'Pengeluaran' : 'Pemasukan',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? const Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

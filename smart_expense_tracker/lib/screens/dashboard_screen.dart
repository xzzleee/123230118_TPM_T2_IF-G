import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';
import 'currency_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardBody(),
    AddTransactionScreen(),
    CurrencyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF00897B),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange_rounded),
            label: 'Kurs API',
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            tooltip: 'Riwayat Transaksi',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00897B), Color(0xFF004D40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    children: [
                      const Text(
                        'Total Saldo',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(provider.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Pemasukan',
                              amount: _formatRupiah(provider.totalIncome),
                              icon: Icons.arrow_downward_rounded,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Pengeluaran',
                              amount: _formatRupiah(provider.totalExpense),
                              icon: Icons.arrow_upward_rounded,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HistoryScreen()),
                          );
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(color: Color(0xFF00897B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                if (provider.transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada transaksi.\nTekan (+) untuk menambahkan!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.recentTransactions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final tx = provider.recentTransactions[index];
                      return _TransactionTile(transaction: tx);
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(
                  amount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isExpense
                ? Colors.red.shade50
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              transaction.category.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          transaction.category.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'} ${_formatRupiah(transaction.amount)}',
          style: TextStyle(
            color: isExpense ? Colors.red.shade600 : Colors.green.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

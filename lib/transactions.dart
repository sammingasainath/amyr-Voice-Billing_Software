import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: LastTransactionsPage(),
    ),
  );
}

class LastTransactionsPage extends StatelessWidget {
  const LastTransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Last Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionCard(transaction: transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Transaction {
  final String date;
  final String description;
  final double amount;
  final String modeOfPayment;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.modeOfPayment,
  });
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            transaction.modeOfPayment == 'Cash'
                ? Icons.money
                : transaction.modeOfPayment == 'Card'
                    ? Icons.credit_card
                    : Icons.account_balance_wallet,
            color: Colors.white,
          ),
        ),
        title: Text(
          '${transaction.description} - \$${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.date} - ${transaction.modeOfPayment}',
        ),
      ),
    );
  }
}

final List<Transaction> transactions = [
  Transaction(
    date: '2022-01-01',
    description: 'Groceries',
    amount: 50.0,
    modeOfPayment: 'Card',
  ),
  Transaction(
    date: '2022-01-05',
    description: 'Dinner',
    amount: 30.0,
    modeOfPayment: 'Cash',
  ),
  Transaction(
    date: '2022-01-10',
    description: 'Electronics',
    amount: 120.0,
    modeOfPayment: 'Card',
  ),
  Transaction(
    date: '2022-01-15',
    description: 'Lunch',
    amount: 25.0,
    modeOfPayment: 'Cash',
  ),
];

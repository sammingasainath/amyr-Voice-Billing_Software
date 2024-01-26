import 'package:circular_menu/circular_menu.dart';
import 'account.dart';
import 'package:flutter/material.dart';
import 'billing.dart';
import 'transactions.dart';
import 'add_product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AmyR - Automate my Retail'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
            label: Text('Log Out'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularMenu(
          alignment: Alignment.center,
          radius: 100,
          toggleButtonColor: Theme.of(context).primaryColor,
          items: [
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountPage(),
                  ),
                );
              },
              icon: Icons.account_circle,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                // Handle Reports button tap
              },
              icon: Icons.bar_chart,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LastTransactionsPage(),
                  ),
                );
              },
              icon: Icons.history,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                // Handle Inventory button tap
              },
              icon: Icons.inventory,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                // Handle AmyR Assistant button tap
              },
              icon: Icons.assistant,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BillingPage(),
                  ),
                );
              },
              icon: Icons.receipt_long,
              color: Theme.of(context).primaryColor,
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpeechSampleApp(),
                  ),
                );
              },
              icon: Icons.receipt_long,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

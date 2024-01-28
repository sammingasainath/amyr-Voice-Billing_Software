import 'package:circular_menu/circular_menu.dart';
import 'package:trial_voice/reminder.dart';
import 'account.dart';
import 'package:flutter/material.dart';
import 'transactions.dart';
import 'add_product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'billing2.dart';
import 'products_list.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);
  final TextEditingController billingNameController = TextEditingController();

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
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
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
              color: Colors.blue, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                // Handle Reports button tap
              },
              icon: Icons.bar_chart,
              color: Colors.green, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BillListPage(),
                  ),
                );
              },
              icon: Icons.history,
              color: Colors.orange, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddReminderPage(),
                  ),
                );
              },
              icon: Icons.add_alarm,
              color: Colors.purple, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListViewScreen1(),
                  ),
                );
                // Handle Inventory button tap
              },
              icon: Icons.inventory,
              color: Colors.red, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                // Handle AmyR Assistant button tap
              },
              icon: Icons.assistant,
              color: Colors.teal, // Change the color here
            ),
            CircularMenuItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpeechSampleApp1(),
                  ),
                );
              },
              icon: Icons.receipt_long,
              color: Color.fromARGB(255, 221, 54, 236), // Change the color here
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
              icon: Icons.add,
              color: Colors.cyan, // Change the color here
            ),
          ],
        ),
      ),
    );
  }
}

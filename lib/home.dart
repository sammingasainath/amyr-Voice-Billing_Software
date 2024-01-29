import 'package:flutter/material.dart';
import 'package:trial_voice/chatbot.dart';
import 'package:trial_voice/reminder.dart';
import 'package:trial_voice/reports.dart';
import 'account.dart';
import 'transactions.dart';
import 'add_product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'billing2.dart';
import 'products_list.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);
  final TextEditingController billingNameController = TextEditingController();

  // Function to navigate to different pages based on the menu items
  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AmyR- Automate my Retail',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
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
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2, // Adjusted aspect ratio
          children: [
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const AccountPage());
              },
              icon: Icons.account_circle,
              title: 'Account',
              color: Colors.blue,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const FullScreenImagePage());
              },
              icon: Icons.bar_chart,
              title: 'Reports',
              color: Colors.green,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const BillListPage());
              },
              icon: Icons.history,
              title: 'History',
              color: Colors.orange,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const AddReminderPage());
              },
              icon: Icons.add_alarm,
              title: 'Add Reminder',
              color: Colors.purple,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, ProductListViewScreen1());
              },
              icon: Icons.inventory,
              title: 'Inventory',
              color: Colors.red,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const ChatBotPage());
              },
              icon: Icons.assistant,
              title: 'Chatbot',
              color: Colors.teal,
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, SpeechSampleApp1());
              },
              icon: Icons.receipt_long,
              title: 'Quick Billing',
              color: Color.fromARGB(255, 221, 54, 236),
            ),
            MenuItemCard(
              onTap: () {
                navigateToPage(context, const SpeechSampleApp());
              },
              icon: Icons.add,
              title: 'Add Products',
              color: Colors.cyan,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for menu item as a card
class MenuItemCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final Color color;

  const MenuItemCard({
    required this.onTap,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

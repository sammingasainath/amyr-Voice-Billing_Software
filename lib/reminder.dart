import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

class AddReminderPage extends StatefulWidget {
  const AddReminderPage({Key? key}) : super(key: key);

  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _customerNumberController = TextEditingController();

  List<String> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reminders = prefs.getStringList('reminders') ?? [];
    });
  }

  Future<void> _saveReminder(String reminder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reminders.add(reminder);
    prefs.setStringList('reminders', reminders);
  }

  Future<void> _deleteReminder(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reminders.removeAt(index);
    prefs.setStringList('reminders', reminders);
    setState(() {}); // Refresh the UI after deleting the reminder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reminders'),
      ),
      body: SingleChildScrollView(
        // Wrap the entire body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerNumberController,
                decoration: InputDecoration(
                  labelText: 'Customer Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // ... same as before
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add Reminder'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Reminders:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap:
                    true, // Ensure the ListView does not take more space than needed
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(reminders[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          // ... same as before
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

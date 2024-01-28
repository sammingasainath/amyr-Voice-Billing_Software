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
        title: const Text('Add Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerNumberController,
              decoration: InputDecoration(
                labelText: 'Customer Number',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                String itemName = _itemNameController.text;
                String customerName = _customerNameController.text;
                String customerNumber = _customerNumberController.text;

                if (itemName.isNotEmpty &&
                    customerName.isNotEmpty &&
                    customerNumber.isNotEmpty) {
                  String reminder =
                      'Item: $itemName, Customer: $customerName, Number: $customerNumber';
                  _saveReminder(reminder);

                  // Display a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder added successfully.'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Clear the text fields
                  _itemNameController.clear();
                  _customerNameController.clear();
                  _customerNumberController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Add Reminder'),
            ),
            const SizedBox(height: 32),
            Text(
              'Reminders:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(reminders[index]),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        List<String> extractedValues =
                            extractValues(reminders[index]);
                        await WhatsappShare.share(
                          text: 'Hello ' +
                              '' +
                              extractedValues[1] +
                              ', We Have Brought Back ' +
                              extractedValues[0] +
                              ', For You ' +
                              ' . Thank You For Shopping With Us. Have A Nice Day!',
                          phone: extractedValues[2],
                        );

                        // Delete the reminder after sending the message
                        _deleteReminder(index);
                      },
                      child: Text('Send Message'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> extractValues(String inputString) {
  // Define a regular expression pattern to extract values
  RegExp regExp = RegExp(r'Item: (\w.*?), Customer: (\w.*?), Number: (\d+)');

  // Extract matches from the input string
  Match? match = regExp.firstMatch(inputString);

  // Check if a match is found
  if (match != null) {
    // Extract individual components from the match
    String itemName = match.group(1)!;
    String customerName = match.group(2)!;
    String customerNumber = match.group(3)!;

    // Create a list of extracted values
    List<String> extractedValues = [itemName, customerName, customerNumber];

    return extractedValues;
  } else {
    // Return an empty list if no match is found
    return [];
  }
}

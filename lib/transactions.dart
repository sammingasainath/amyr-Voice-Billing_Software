import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(
    const MaterialApp(
      home: BillListPage(),
    ),
  );
}

class BillListPage extends StatefulWidget {
  const BillListPage({Key? key}) : super(key: key);

  @override
  _BillListPageState createState() => _BillListPageState();
}

class _BillListPageState extends State<BillListPage> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<DocumentSnapshot>> _getBills() async {
    CollectionReference billsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('Bills');

    QuerySnapshot querySnapshot = await billsCollection.get();
    return querySnapshot.docs;
  }

  void _showBillDetails(BuildContext context, Map<dynamic, dynamic> billData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Use Map<String, dynamic>.from to create a new map with the correct type
        Map<String, dynamic> typedBillData =
            Map<String, dynamic>.from(billData);

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bill Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Customer Name: ${typedBillData['customerName']}'),
              Text('Customer Number: ${typedBillData['customerNumber']}'),
              Text('Payment Mode: ${typedBillData['paymentMode']}'),
              Text('Total Amount: ₹${typedBillData['totalAmount']}'),
              // Add more details as needed
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill List'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getBills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bills found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var billData = snapshot.data![index].data() as Map;
                return ListTile(
                  title: Text('Bill ID: ${snapshot.data![index].id}'),
                  subtitle: Text('Total Amount: ₹${billData['totalAmount']}'),
                  onTap: () {
                    _showBillDetails(context, billData);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

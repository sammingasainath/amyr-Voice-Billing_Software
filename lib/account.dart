import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trial_voice/api/firebase_options.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  TextEditingController shopNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController shopDescriptionController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Fetch data from Firebase when the page loads
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the document reference for the current user
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

      // Debugging print statement
      print('Document Snapshot Data: ${documentSnapshot.data()}');

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Debugging print statement
        print('Document Exists');

        // Populate the text controllers with data from the document
        setState(() {
          shopNameController.text = documentSnapshot['shopName'];
          addressController.text = documentSnapshot['address'];
          mobileNumberController.text = documentSnapshot['mobileNumber'];
          pincodeController.text = documentSnapshot['pincode'];
          gstNumberController.text = documentSnapshot['gstNumber'];
          panNumberController.text = documentSnapshot['panNumber'];
          shopDescriptionController.text = documentSnapshot['shopDescription'];
        });

        // Debugging print statements
        print('Fetched Shop Name: ${documentSnapshot['shopName']}');
        print('Fetched Address: ${documentSnapshot['address']}');
        // Add similar print statements for other fields
      } else {
        // Debugging print statement
        print('Document Does Not Exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle the error appropriately
    }
  }

  Future<void> _updateUserData() async {
    try {
      // Debugging print statements
      print('Updating Shop Name: ${shopNameController.text}');
      print('Updating Address: ${addressController.text}');
      // Add similar print statements for other fields

      // Update the document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'shopName': shopNameController.text,
        'address': addressController.text,
        'mobileNumber': mobileNumberController.text,
        'pincode': pincodeController.text,
        'gstNumber': gstNumberController.text,
        'panNumber': panNumberController.text,
        'shopDescription': shopDescriptionController.text,
      });
    } catch (e) {
      print('Error updating data: $e');
      // Handle the error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
              if (!isEditing) {
                _updateUserData();
              }
            },
          ),
        ],
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard('Shop Name', shopNameController),
              _buildCard('Address', addressController),
              _buildCard('Mobile Number', mobileNumberController),
              _buildCard('Pincode', pincodeController),
              _buildCard('GST Number', gstNumberController),
              _buildCard('PAN Number', panNumberController),
              _buildCard('Shop Description', shopDescriptionController),
            ],
          ),
        ),
      ),
      backgroundColor:
          Color.fromARGB(255, 255, 255, 255), // Set background color
    );
  }

  Widget _buildCard(String label, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20.0, // Changed font size
                fontWeight: FontWeight.bold,
                color:
                    const Color.fromARGB(255, 8, 77, 133), // Changed text color
              ),
            ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Enter $label',
                    ),
                  )
                : Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16.0, // Changed font size
                      color: Colors.black, // Changed text color
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

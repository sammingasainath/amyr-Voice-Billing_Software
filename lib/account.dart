import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      // Check if the document exists
      if (documentSnapshot.exists) {
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
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle the error appropriately
    }
  }

  Future<void> _updateUserData() async {
    try {
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
              _buildCard(
                'Shop Name',
                Icons.store,
                shopNameController,
              ),
              _buildCard(
                'Address',
                Icons.location_on,
                addressController,
              ),
              _buildCard(
                'Mobile Number',
                Icons.phone,
                mobileNumberController,
              ),
              _buildCard(
                'Pincode',
                Icons.pin_drop,
                pincodeController,
              ),
              _buildCard(
                'GST Number',
                Icons.format_list_numbered,
                gstNumberController,
              ),
              _buildCard(
                'PAN Number',
                Icons.credit_card,
                panNumberController,
              ),
              _buildCard(
                'Shop Description',
                Icons.description,
                shopDescriptionController,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.lightBlue[50],
    );
  }

  Widget _buildCard(
      String label, IconData icon, TextEditingController controller) {
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
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.lightBlue, // Icon color
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue, // Label text color
                  ),
                ),
              ],
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
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

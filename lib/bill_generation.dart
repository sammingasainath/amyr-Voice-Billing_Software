import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trial_voice/billing2.dart' as billing;
import 'package:whatsapp_share/whatsapp_share.dart';

class BillScreen1 extends StatefulWidget {
  @override
  _BillScreen1State createState() => _BillScreen1State();
}

class _BillScreen1State extends State<BillScreen1> {
  GlobalKey _globalKey = GlobalKey();
  String imagePath = '';

  String customerName = '';
  String customerNumber = '';
  String selectedPaymentMode = '';
  late List<billing.Item> items;
  double totalAmount = 0.0;

  @override
  void initState() {
    recoverBillingDetails();
    super.initState();
  }

  Future<void> recoverBillingDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      customerName = prefs.getString('customerName') ?? '';
      customerNumber = prefs.getString('customerNumber') ?? '';
      selectedPaymentMode = prefs.getString('selectedPaymentMode') ?? '';
      items = (prefs.getStringList('items') ?? [])
          .map((jsonString) => billing.Item.fromJson(jsonDecode(jsonString)))
          .toList();
      totalAmount = prefs.getDouble('totalAmount') ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Generator'),
      ),
      body: RepaintBoundary(
        key: _globalKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Display recovered billing details
              Text('Customer Name: $customerName'),
              Text('Customer Number: $customerNumber'),
              Text('Payment Mode: $selectedPaymentMode'),

              // Display recovered items
              Text('Items:'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items.map((item) {
                  double itemAmount = item.price * item.quantity;
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${item.quantity}'),
                        Text('Item Amount: ₹${itemAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Display total amount
              Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),

              // Button to generate and share bill
              ElevatedButton(
                onPressed: () => captureAndShare(),
                child: Text('Generate and Share Bill'),
              ),

              // Display the captured image
              if (imagePath.isNotEmpty)
                Image.file(
                  File(imagePath),
                  width: 200,
                  height: 200,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> captureAndShare() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('Error: RenderRepaintBoundary is null');
        return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('Error: ByteData is null');
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/bill.png';
      final imagePath1 = directory.absolute.path;

      File(imagePath).writeAsBytesSync(pngBytes);

      print(imagePath);
      print(imagePath1);

      setState(() {
        this.imagePath = imagePath;
      });

      await WhatsappShare.shareFile(
          filePath: [imagePath], phone: customerNumber);
      print('shared');
    } catch (e) {
      print(e);
    }
  }
}

import 'form.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:trial_voice/form.dart';
// import 'package:alan_voice/alan_voice.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
  MyHomePage(
      {Key? key,
      required this.barcode,
      required this.cP,
      required this.mRP,
      required this.productName,
      required this.quantity,
      required this.sP,
      required this.context2})
      : super(key: key);

  var barcode;
  var productName;
  var mRP;
  var cP;
  var sP;
  var quantity;
  final BuildContext context2;
}

class _MyHomePageState extends State<MyHomePage> {
  final productName;
  final MRP;
  final CP;

  final SP;
  final Stock;
  _MyHomePageState({this.productName, this.MRP, this.CP, this.SP, this.Stock});
  late QRViewController controller;
  String scannedData = "";
  bool isScannerActive = true; // Add this boolean flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing..."),
        actions: [
          IconButton(
            icon: Icon(Icons.blinds_closed_rounded),
            onPressed: () {
              /// Activate Alan Button
              // AlanVoice.playText("See The Bill Now");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 200, // Adjust the height as needed
            child: isScannerActive ? _buildQrView(context) : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: scannedData),
              decoration: InputDecoration(
                labelText: "Scanned Data",
              ),
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: GlobalKey(debugLabel: 'QR'),
      onQRViewCreated: (QRViewController controller) {
        this.controller = controller;

        controller.scannedDataStream.listen((scanData) {
          setState(() {
            isScannerActive = false;
            String barcode1 = scanData.code!;
            // Disable the scanner
            Navigator.of(context).pop();
            showModalBottomSheet(
              isScrollControlled: true,
              isDismissible: true,
              context: context,
              builder: (BuildContext context) {
                return AddProductModal(
                    context1: widget.context2,
                    barcode: barcode1,
                    productName: widget.productName,
                    mRP: widget.mRP,
                    cP: widget.cP,
                    sP: widget.sP,
                    quantity: widget.quantity);
              },
            );

            scannedData = scanData.code!;
          });
        });
        // Navigator.pop(context);
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 200,
      ),
    );
  }

  @override
  void dispose() {
    if (isScannerActive) {
      controller.dispose();
    }
    super.dispose();
  }
}

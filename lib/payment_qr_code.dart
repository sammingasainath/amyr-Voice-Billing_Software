import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';





class MyQRCodeScreen extends StatelessWidget {
  const MyQRCodeScreen({Key? key, required this.amount}) : super(key: key);

  final String? amount;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        
        title: Text(
          'QR Code ',
          textAlign: TextAlign.center,
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Text(
            'You Are Paying $amount Rs.', //amount.toStringAsFixed(2),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Center(
            child: QrImageView(
              data:
                  'upi://pay?pa=sammingas2002@oksbi&pn=Samminga Sainath Rao&am=$amount&cu=INR&aid=uGICAgMCY-5zZXg',
              version: QrVersions.auto,
              size: 320,
              gapless: false,
              embeddedImage: AssetImage('assets/logo2.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(100, 100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

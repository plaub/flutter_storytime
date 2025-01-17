import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
    return Scaffold(
      body: Center(
        child: Image.network(
            'https://fastly.picsum.photos/id/732/200/200.jpg?hmac=-1Xf4hDrUp28fyFDvesIbVP0judK8XABC6MYEnxTdyw'),
      ),
    );
  }
}

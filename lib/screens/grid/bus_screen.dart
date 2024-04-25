import 'package:flutter/material.dart';

class BusScreen extends StatelessWidget {
  const BusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Routes'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'The Bus Routes feature is currently not available due to limited development resources. '
            'We are working to allocate more developers and will update this feature as soon as possible.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red, // Optional: to make the text stand out
            ),
          ),
        ),
      ),
    );
  }
}

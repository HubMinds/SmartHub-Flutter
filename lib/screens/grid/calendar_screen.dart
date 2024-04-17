import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarScreen extends StatelessWidget {
  CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: const Center(child: Text('Calendar Screen')),
    );
  }
}



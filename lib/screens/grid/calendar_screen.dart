import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  final String uid; //declare uid

  const CalendarScreen({required this.uid, Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController _eventController = TextEditingController();
  TimeOfDay? _selectedTime;
  //store the events
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Load events from Firebase when the screen initializes
    _loadEventsFromFirebase();
  }

  void _loadEventsFromFirebase() async {
    List<Event> firebaseEvents = await getEventsFromFirestore(widget.uid, _selectedDay!);
    setState(() {
      events[_selectedDay!] = firebaseEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(now.year - 5, now.month - 1, now.day);
    final DateTime lastDay = DateTime(now.year + 5, now.month + 1, now.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text("Event Name"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _eventController,
                      decoration: InputDecoration(labelText: 'Event Name'),
                      maxLength: 2000,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _selectTime,
                      child: Text(_selectedTime != null
                          ? 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute}'
                          : 'Select Time'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedDay != null && _eventController.text.isNotEmpty && _selectedTime != null) {
                        // Save event to Firestore
                        saveEventToFirestore(
                          widget.uid, // Pass the UID of the user
                          _selectedDay!, // Pass the selected day
                          Event(_eventController.text, _selectedTime!), // Pass the event
                        );
                        Navigator.of(context).pop();
                        _eventController.clear();
                        setState(() {
                          _selectedTime = null;
                        });
                      }
                    },
                    child: const Text("Submit"),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            // Add parameters
            focusedDay: _focusedDay,
            firstDay: firstDay,
            lastDay: lastDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false
            ),
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _loadEventsFromFirebase();
              });
            },
            // Add more customization as needed
            // Add callback functions for event handling
            // Example: onDaySelected, onVisibleDaysChanged, etc.
            // Refer to the package documentation for more options
          ),
          SizedBox(height: 8.0,),
          Expanded(
            child: _buildEventList(),
          )
        ],
      ),
    );
  }

  Widget _buildEventList() {
    List<Event> selectedEvents = events[_selectedDay!] ?? [];
    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () => print(""), // Handle onTap event if needed
            title: Text('${selectedEvents[index].title}'), // Display event name
            subtitle: Text(
              'Time: ${selectedEvents[index].time.hour}:${selectedEvents[index].time.minute.toString().padLeft(2, '0')}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteEvent(selectedEvents[index]),
            ),
          ),
        );
      },
    );
  }

  void _deleteEvent(Event event) {
    FirebaseFirestore.instance
        .collection('users') // Root collection for users
        .doc(widget.uid) // Document ID is the user's UID
        .collection('events') // Subcollection for events
        .doc(_formattedDate(_selectedDay!)) // Document ID is the formatted date
        .update({
      'events': FieldValue.arrayRemove([
        {
          'title': event.title,
          'time': '${event.time.hour}:${event.time.minute}'
        }
      ])
    }).then((_) {
      print("Event deleted successfully!");
      _loadEventsFromFirebase(); // Reload events after deleting an event
    }).catchError((error) {
      print("Failed to delete event: $error");
    });
  }

  String _formattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _loadEventsFromFirebase(); // Load events for the selected day
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Save event to Firestore
  void saveEventToFirestore(String uid, DateTime day, Event event) {
    String formattedDate = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    FirebaseFirestore.instance
        .collection('users') // Root collection for users
        .doc(uid) // Document ID is the user's UID
        .collection('events') // Subcollection for events
        .doc(formattedDate) // Document ID is the formatted date
        .set({
      'day': formattedDate,
      'events': FieldValue.arrayUnion([{
        'title': event.title,
        'time': '${event.time.hour}:${event.time.minute}'
      }]),
    }, SetOptions(merge: true)).then((_) {
      print("Event added successfully!");
      _loadEventsFromFirebase(); // Reload events after adding an event
    }).catchError((error) {
      print("Failed to add event: $error");
    });
  }

  // Retrieve events from Firestore
  Future<List<Event>> getEventsFromFirestore(String uid, DateTime day) async {
    String formattedDate = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('users') // Root collection for users
        .doc(uid) // Document ID is the user's UID
        .collection('events') // Subcollection for events
        .doc(formattedDate) // Document ID is the day's timestamp
        .get();

    if (snapshot.exists) {
      List<dynamic> eventData = snapshot.data()!['events'];
      List<Event> events = eventData.map((event) {
        return Event(event['title'], TimeOfDay(
          hour: int.parse(event['time'].split(':')[0]),
          minute: int.parse(event['time'].split(':')[1]),
        ));
      }).toList();
      return events;
    } else {
      return [];
    }
  }

  List<Event> _getEventsForDay(DateTime day){
    return events[day] ?? [];
  }
}

class Event {
  final String title;
  final TimeOfDay time;

  Event(this.title, this.time);
}

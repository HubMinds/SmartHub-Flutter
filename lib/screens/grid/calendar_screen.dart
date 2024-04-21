import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Events.dart';

class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController _eventController = TextEditingController();
  //store the events
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>>_selectedEvents;

 @override
 void initState() {
  super.initState();
  _selectedDay = _focusedDay;
  _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
 }

 @override
 void dispose() {
  super.dispose();
 }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day){
    return events[day] ?? [];
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
        onPressed: (){
          showDialog(
            context: context,
            builder: (context){
              return  AlertDialog(
                scrollable: true,
                title: const Text("Event Name"),
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                  ),
                  actions: [
                    ElevatedButton(onPressed: (){
                      //stores event into map
                      events.addAll({
                        _selectedDay!: [Event(_eventController.text)]
                      });
                      Navigator.of(context).pop();
                      _selectedEvents.value =
                      _getEventsForDay(_selectedDay!);
                    },
                     child: const Text("submit"))
                  ]
              );
            } );
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
            _focusedDay = focusedDay;
          }
          // Add more customization as needed
          // Add callback functions for event handling
          // Example: onDaySelected, onVisibleDaysChanged, etc.
          // Refer to the package documentation for more options
        ),
        SizedBox(height: 8.0,),

        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents, 
            builder: (context, value, _){
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index){
              return Container(
                margin: 
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => print(""),
                  title: Text('${value[index]}'),
                )
              );
            });
          }),
        )
      ],
      ),
    );
  }
}



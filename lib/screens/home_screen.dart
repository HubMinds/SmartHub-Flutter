// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smarthub_flutter/screens/login_screen.dart';
import '../extensions/animated_list_state_extension.dart';
import 'package:logger/logger.dart';
import 'grid/calendar_screen.dart';
import 'grid/news_screen.dart';
import 'grid/weather_screen.dart';

var logger = Logger();

class HomeScreen extends StatefulWidget {
  // Declare a named parameter called uid
  final String uid;

  // Use a default value to make the parameter optional
  const HomeScreen({this.uid = '', Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> items = ['News', 'Weather', 'Calendar'];
  final List<IconData> icons = [
    Icons.article,
    Icons.wb_sunny,
    Icons.calendar_today
  ]; // Add a list of icons for each item

  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey<AnimatedListState>(); // Add a key for the animated list

  void signOutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
    print("User signed out");
  } catch (e) {
    print("Error signing out: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use MaterialApp widget to define the app theme
      title: 'SmartHub App',
      theme: ThemeData(
        // Define the light theme
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 30,
            fontFamily: 'Roboto', // Specify the font family
          ),
          bodyMedium: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 16,
            fontFamily: 'MyFont', // Specify the font family
          ),
          displaySmall: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 24,
            fontFamily: 'Roboto', // Specify the font family
          ),
        ),
      ),
      darkTheme: ThemeData(
        // Define the dark theme
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 30,
            color: Colors.white,
            fontFamily: 'Roboto', // Specify the font family
          ),
          bodyMedium: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'MyFont', // Specify the font family
          ),
          displaySmall: TextStyle(
            // Use the default font family or a custom font family
            fontSize: 24,
            color: Colors.white,
            fontFamily: 'Roboto', // Specify the font family
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Use the system theme setting
      home: Scaffold(
        // Use Scaffold widget to define the app layout
        appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                signOutUser();
              },
            ),
            const Text('SmartHub App'),
          ],
        ),
      ),
      body: GridView.count(
        // Use a GridView instead of an AnimatedList
        key: _listKey, // Add the key for the animated list
        crossAxisCount: 2, // Specify the number of columns in the grid
        children: List.generate(items.length, (index) {
          return _buildItem(index);
        }),
      ),
    ),
  );
}

  Widget _buildItem(int index) {
    return DragTarget<int>(
      // Wrap each Draggable with a DragTarget
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          // Wrap each Card with a Draggable
          data: index, // Use the index as the data to identify the card
          feedback: Card(
            // Use a Card as the feedback while dragging
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[index], size: 48, color: Colors.lightBlueAccent),
                  const SizedBox(height: 8),
                  Text(
                    items[index],
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface, // Use the color scheme to change the color according to the theme mode
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          childWhenDragging: Container(
            // Use an empty Container as the child when dragging
            margin: const EdgeInsets.all(8),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onDragEnd: (details) {
            // Perform some actions when the drag is finished
            logger.i('Dragged ${items[index]} to ${details.offset}');
          },
          child: GestureDetector(
            onTap: () {
              switch (items[index]) {
                case 'News':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsScreen()),
                  );
                  break;
                case 'Weather':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WeatherScreen()),
                  );
                  break;
                case 'Calendar':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen(uid: widget.uid)),
                  );
                  break;
                default:
                  break;
              }
            },
            child: Card(
              // Use a Card as the child when not dragging
              margin: const EdgeInsets.all(8),
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[index], size: 48, color: Colors.lightBlueAccent),
                    const SizedBox(height: 8),
                    Text(
                      items[index],
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface, // Use the color scheme to change the color according to the theme mode
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      onWillAcceptWithDetails: (DragTargetDetails<int> details) {
        // Determine whether the drop is valid
        return details.data !=
            index; // Reject the drop if the data is the same as the index
      },
      onAcceptWithDetails: (DragTargetDetails<int> details) {
        // Perform the swap logic
        setState(() {
          // Update the state of the lists
          final tempItem = items[index];
          final tempIcon = icons[index];
          items[index] = items[details.data];
          icons[index] = icons[details.data];
          items[details.data] = tempItem;
          icons[details.data] = tempIcon;
          _listKey.currentState?.moveItem(details.data,
              index); // Use the null-aware operator to avoid the error
        });
      },
    );
  }
}

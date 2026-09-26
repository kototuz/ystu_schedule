import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Lack',
        scaffoldBackgroundColor: Colors.grey[600],
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: Colors.orange,
              brightness: Brightness.light,
            ).copyWith(
              surface: Colors.grey[300],
              surfaceContainerLowest: Colors.grey[400],
              surfaceContainerLow: Colors.grey[300],
              surfaceContainer: Colors.grey[200],
              surfaceContainerHigh: Colors.grey[100],
              surfaceContainerHighest: Colors.white,
            ),
      ),

      darkTheme: ThemeData(
        fontFamily: 'Lack',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),

      themeMode: ThemeMode.light,

      home: const WeekSchedule(),
    );
  }
}

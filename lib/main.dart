import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/schedule/page.dart';
import 'package:ystu_schedule/settings/app_theme_model.dart';
import 'package:ystu_schedule/settings/page.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final themeModel = AppThemeModel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeModel,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            fontFamily: 'Lack',
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeModel.color,
              brightness: Brightness.light,
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
              seedColor: themeModel.color,
              brightness: Brightness.dark,
            ), //colorScheme.copyWith(brightness: Brightness.dark),
          ),

          themeMode: themeModel.mode,

          home: Home(themeModel),
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  final AppThemeModel themeModel;

  const Home(this.themeModel, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Widget> pages;
  late ScheduleModel model;

  var selectedPageIdx = 0;

  @override
  void initState() {
    super.initState();
    model = ScheduleModel();
    pages = [SchedulePage(model), SettingsPage(model, widget.themeModel)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPageIdx],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
        currentIndex: selectedPageIdx,
        onTap: (index) => setState(() => selectedPageIdx = index),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

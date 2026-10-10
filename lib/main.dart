import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/schedule/page.dart';
import 'package:ystu_schedule/settings/app_theme_model.dart';
import 'package:ystu_schedule/settings/page.dart';
import 'package:ystu_schedule/setup/page.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late AppThemeModel themeModel;
  late ScheduleModel scheduleModel;

  @override
  void initState() {
    super.initState();
    themeModel = AppThemeModel();
    scheduleModel = ScheduleModel();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeModel,
      builder: (context, child) {
        return MaterialApp(
          title: 'ЯГТУ Расписание',
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
            ),
          ),

          themeMode: themeModel.mode,

          home: SetupPage(
            model: scheduleModel,
            child: Home(scheduleModel, themeModel),
          ),
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  final AppThemeModel themeModel;
  final ScheduleModel scheduleModel;

  const Home(this.scheduleModel, this.themeModel, {super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Widget> pages;
  late PageController pageViewController;

  var selectedPageIdx = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
    pages = [
      SchedulePage(widget.scheduleModel),
      SettingsPage(widget.scheduleModel, widget.themeModel),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageViewController,
        children: pages,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: selectedPageIdx,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withAlpha(40),
                offset: const Offset(0, -1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: '',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
            ],
            currentIndex: selectedPageIdx.value,
            onTap: (pageIdx) {
              selectedPageIdx.value = pageIdx;
              pageViewController.animateToPage(
                pageIdx,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule/lesson_view.dart';
import 'package:ystu_schedule/week_schedule/model.dart';
import 'package:ystu_schedule/week_schedule/navigator.dart';

class WeekSchedulePage extends StatefulWidget {
  const WeekSchedulePage({super.key});

  @override
  State<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends State<WeekSchedulePage> {
  late WeekScheduleModel model;

  @override
  void initState() {
    super.initState();
    model = WeekScheduleModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WeekScheduleNavigator(model, MediaQuery.of(context).size.width),
          LessonView(model),
        ],
      ),
    );
  }
}

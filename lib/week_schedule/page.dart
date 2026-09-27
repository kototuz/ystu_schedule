import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule/lesson_view.dart';
import 'package:ystu_schedule/week_schedule/model.dart';
import 'package:ystu_schedule/week_schedule/navigator.dart';

class WeekSchedulePage extends StatelessWidget {
  final model = WeekScheduleModel();

  WeekSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [WeekScheduleNavigator(model), LessonView(model)]),
    );
  }
}

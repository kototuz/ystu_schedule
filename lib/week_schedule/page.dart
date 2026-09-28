import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule/lesson_view.dart';
import 'package:ystu_schedule/week_schedule/model.dart';
import 'package:ystu_schedule/week_schedule/navigator.dart';

class WeekSchedulePage extends StatefulWidget {
  final WeekScheduleModel model;

  const WeekSchedulePage(this.model, {super.key});

  @override
  State<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends State<WeekSchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WeekScheduleNavigator(widget.model, MediaQuery.of(context).size.width),
        LessonView(widget.model),
      ],
    );
  }
}

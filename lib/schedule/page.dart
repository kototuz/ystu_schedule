import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/lesson_view.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/schedule/navigator.dart';

class SchedulePage extends StatefulWidget {
  final ScheduleModel model;

  const SchedulePage(this.model, {super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScheduleNavigator(widget.model, MediaQuery.of(context).size.width),
        LessonView(widget.model),
      ],
    );
  }
}

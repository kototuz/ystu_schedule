import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ystu_schedule/types/group_schedule.dart';

class WeekSchedule extends StatefulWidget {
  const WeekSchedule({super.key});

  @override
  State<WeekSchedule> createState() => _WeekScheduleState();
}

class _WeekScheduleState extends State<WeekSchedule> {
  static final WEEK_NAMES = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static final MONTH_NAMES = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  late DateTime now;
  late DateTime weekBeginDate;
  late int selectedWeekday;

  GroupSchedule? schedule;
  Week? week;

  @override
  void initState() {
    super.initState();

    now = DateTime.now();
    weekBeginDate = now.subtract(Duration(days: now.weekday - 1));
    selectedWeekday = now.weekday - 1;

    http.get(Uri.parse('http://192.168.1.51:8000/ЦИС-15')).then((resp) {
      if (resp.statusCode == 200) {
        setState(() {
          schedule = GroupSchedule.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>,
          );

          week = schedule!.findWeekByFirstDay(weekBeginDate);
          print(week);
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: CircularProgressIndicator());
    if (schedule != null) {
      if (week != null) {
        final day = week!.findDay(
          weekBeginDate.add(Duration(days: selectedWeekday - 1)),
        );
        if (day == null) {
          body = const Center(child: Text('Нет расписания на этот день'));
        } else {
          var lastLessonNum = 1;
          day.lessons.forEach((l) {
            lastLessonNum = max(lastLessonNum, l.number);
          });

          final placeholder = Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  child: const Text('Окно'),
                ),
              ),
            ],
          );

          final lessonView = List.filled(lastLessonNum, placeholder);
          for (final lesson in day.lessons) {
            lessonView[lesson.number - 1] = Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: Text(lesson.lessonName),
                  ),
                ),
              ],
            );
          }

          body = Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(spacing: 5, children: lessonView),
          );
        }
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Column(
              children: [
                Text(
                  MONTH_NAMES[now.month - 1],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  spacing: 0,
                  children: [
                    for (var i = 0; i < WEEK_NAMES.length; i++)
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.all(10.0),
                            shape: const RoundedRectangleBorder(),
                            backgroundColor: i == selectedWeekday
                                ? Theme.of(context).cardColor
                                : Theme.of(context).colorScheme.inversePrimary,
                          ),
                          onPressed: () => setState(() {
                            selectedWeekday = i;
                          }),
                          child: Container(
                            foregroundDecoration: BoxDecoration(
                              border: now.weekday == i + 1
                                  ? Border(
                                      top: BorderSide(
                                        width: 1.5,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(WEEK_NAMES[i]),
                                Text(
                                  weekBeginDate
                                      .add(Duration(days: i))
                                      .day
                                      .toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(child: body),
        ],
      ),
    );
  }
}

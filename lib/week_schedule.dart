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
          body = Center(
            child: Text(
              'Нет расписания на этот день',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
              ),
            ),
          );
        } else {
          var lastLessonNum = 1;
          day.lessons.forEach((l) {
            lastLessonNum = max(lastLessonNum, l.number);
          });

          final placeholder = Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(50),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  child: Center(
                    child: Text(
                      'Окно',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(80),
                      ),
                    ),
                  ),
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
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      boxShadow: const [
                        const BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${lesson.startAt.hour}:${lesson.startAt.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${lesson.endAt.hour}:${lesson.endAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(90),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        lesson.lessonName,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Text(
                                      lesson.type.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(130),
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        10,
                                        0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(130),
                                          ),
                                          Text(
                                            lesson.auditoryName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(130),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Icon(
                                      Icons.person,
                                      size: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(130),
                                    ),

                                    Text(
                                      lesson.teacherName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(130),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          body = Container(
            padding: const EdgeInsets.all(10),
            child: Column(spacing: 7, children: lessonView),
          );
        }
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Column(
              spacing: 5,
              children: [
                Text(
                  MONTH_NAMES[now.month - 1],
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
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
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.primary,
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
                                        color: i == selectedWeekday
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  WEEK_NAMES[i],
                                  style: TextStyle(
                                    color: i == selectedWeekday
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                  ),
                                ),
                                Text(
                                  weekBeginDate
                                      .add(Duration(days: i))
                                      .day
                                      .toString(),
                                  style: TextStyle(
                                    color: i == selectedWeekday
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                  ),
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

          Expanded(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

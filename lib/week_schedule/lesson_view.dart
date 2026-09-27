import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ystu_schedule/types/group_schedule.dart';
import 'package:ystu_schedule/week_schedule/model.dart';

class LessonView extends StatelessWidget {
  final WeekScheduleModel model;

  const LessonView(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: ColoredBox(
        color: colorScheme.surface,
        child: ListenableBuilder(
          listenable: model,
          builder: (context, child) {
            Widget result = const Center(child: CircularProgressIndicator());
            if (model.schedule != null) {
              if (model.week != null) {
                final day = model.week!.findDay(
                  model.weekBeginDate.add(
                    Duration(days: model.selectedWeekday),
                  ),
                );
                if (day == null) {
                  result = Center(
                    child: Text(
                      'Нет расписания на этот день',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(80),
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
                            color: colorScheme.surface,
                            border: Border.all(
                              color: colorScheme.onSurface.withAlpha(50),
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
                                color: colorScheme.onSurface.withAlpha(80),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                  final List<Widget> lessonView = List.filled(
                    lastLessonNum,
                    placeholder,
                  );

                  for (final lesson in day.lessons) {
                    lessonView[lesson.number - 1] = LessonCard(lesson);
                  }

                  result = Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(spacing: 7, children: lessonView),
                  );
                }
              }
            }

            return result;
          },
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;

  const LessonCard(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              boxShadow: const [
                const BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: colorScheme.primary),
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
                              color: colorScheme.onSurface.withAlpha(90),
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
                                color: colorScheme.onSurface.withAlpha(130),
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 15,
                                    color: colorScheme.onSurface.withAlpha(130),
                                  ),
                                  Text(
                                    lesson.auditoryName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurface.withAlpha(
                                        130,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.person,
                              size: 15,
                              color: colorScheme.onSurface.withAlpha(130),
                            ),

                            Text(
                              lesson.teacherName,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withAlpha(130),
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
}

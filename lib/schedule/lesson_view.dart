import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/types/group_schedule.dart';

class LessonView extends StatelessWidget {
  final ScheduleModel model;

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
            Widget result;
            switch (model.schedule) {
              case PendingResource():
                result = const Center(child: CircularProgressIndicator());

              case null:
                result = const Note('Расписание не скачено');

              case ReadyResource():
                if (model.selectedDay == null) {
                  result = const Note('Нет расписания на этот день');
                } else {
                  var currLessonNum = 1;
                  final placeholder = LessonCard.placeholder(colorScheme);
                  final List<Widget> lessons = [];
                  for (final lesson in model.selectedDay!.lessons) {
                    while (lesson.number > currLessonNum) {
                      lessons.add(placeholder);
                      currLessonNum += 1;
                    }

                    lessons.add(LessonCard(lesson));
                    currLessonNum += lesson.duration ~/ 2;
                  }

                  result = Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      padding: EdgeInsetsGeometry.zero,
                      children: lessons,
                    ),
                  );
                }
            }

            return RefreshIndicator(
              onRefresh: () async {
                try {
                  await model.updateGroupSchedule();
                } on AppError catch (err) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(err.message)));
                }
              },
              child: result,
            );
          },
        ),
      ),
    );
  }
}

class Note extends StatelessWidget {
  final String message;

  const Note(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 300,
          child: Center(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  static const baseHeight = 80.0;

  final Lesson lesson;

  const LessonCard(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            color: colorScheme.surfaceContainerHigh,
            child: Container(
              height: baseHeight * (lesson.duration ~/ 2),
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
                                      color: colorScheme.onSurface.withAlpha(
                                        130,
                                      ),
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
        ),
      ],
    );
  }

  static Widget placeholder(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 0,
            color: colorScheme.surface,
            child: Container(
              height: baseHeight,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.onSurface.withAlpha(50)),
                borderRadius: const BorderRadiusGeometry.all(
                  Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  'Окно',
                  style: TextStyle(color: colorScheme.onSurface.withAlpha(80)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

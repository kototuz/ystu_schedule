import 'dart:math';

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
                  // result = Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: CustomScrollView(
                  //     slivers: [
                  //       SliverToBoxAdapter(
                  //         child: Column(
                  //           children: [
                  //             for (final lesson in model.selectedDay!.lessons)
                  //               LessonCard(lesson),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  result = Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView(
                      padding: EdgeInsetsGeometry.zero,
                      children: [
                        for (final lesson in model.selectedDay!.lessons)
                          LessonCard(lesson),
                      ],
                    ),
                  );
                }
            }

            // Widget result = const Center(child: CircularProgressIndicator());
            // if (model.schedule != null) {
            //   if (model.selectedDay == null) {
            //     result = Center(
            //       child: Text(
            //         'Нет расписания на этот день',
            //         style: TextStyle(
            //           color: colorScheme.onSurface.withAlpha(80),
            //         ),
            //       ),
            //     );
            //   } else {
            //     // var lastLessonNum = 1;
            //     // model.selectedDay!.lessons.forEach((l) {
            //     //   lastLessonNum = max(lastLessonNum, l.number);
            //     // });
            //
            //     // final placeholder = Row(
            //     //   children: [
            //     //     Expanded(
            //     //       child: Container(
            //     //         height: 80,
            //     //         decoration: BoxDecoration(
            //     //           color: colorScheme.surface,
            //     //           border: Border.all(
            //     //             color: colorScheme.onSurface.withAlpha(50),
            //     //           ),
            //     //         ),
            //     //         padding: const EdgeInsets.symmetric(
            //     //           vertical: 20,
            //     //           horizontal: 10,
            //     //         ),
            //     //         child: Center(
            //     //           child: Text(
            //     //             'Окно',
            //     //             style: TextStyle(
            //     //               color: colorScheme.onSurface.withAlpha(80),
            //     //             ),
            //     //           ),
            //     //         ),
            //     //       ),
            //     //     ),
            //     //   ],
            //     // );
            //
            //     // final List<Widget> lessonView = List.filled(
            //     //   lastLessonNum,
            //     //   placeholder,
            //     // );
            //
            //     // for (final lesson in model.selectedDay!.lessons) {
            //     //   lessonView[lesson.number - 1] = LessonCard(lesson);
            //     // }
            //
            //     result = Container(
            //       padding: const EdgeInsets.all(10),
            //       child: Column(
            //         spacing: 7,
            //         children: [
            //           for (final lesson in model.selectedDay!.lessons)
            //             LessonCard(lesson),
            //         ],
            //       ),
            //     );
            //   }
            // }

            return RefreshIndicator(
              onRefresh: () => model.updateGroupSchedule().catchError(
                (err) => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err.message))),
              ),
              // () async {
              //   final messenger = ScaffoldMessenger.of(context);
              //   if (model.groupList case rs.Ok(value: final it)) {
              //     return ScheduleModel.downloadGroupSchedule(
              //       it.getGroupNameByIdx(model.selectedGroupIdx),
              //     ).then((schedule) {
              //       if (schedule case rs.Error(message: final msg)) {
              //         messenger.showSnackBar(SnackBar(content: Text(msg)));
              //       } else {
              //         model.setSchedule(schedule);
              //       }
              //     });
              //   }
              //
              //   messenger.showSnackBar(
              //     const SnackBar(content: Text('Список групп не скачен')),
              //   );
              //
              //   return Future.syncValue(null);
              // },
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
              height: 80,
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
}

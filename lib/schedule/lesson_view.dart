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
                  for (final lessonVariants in model.selectedDay!.lessons) {
                    while (lessonVariants[0].number > currLessonNum) {
                      lessons.add(placeholder);
                      currLessonNum += 1;
                    }

                    lessons.add(
                      LessonCard(
                        lessonVariants,
                        key: Key(
                          '${model.selectedDayDate.weekday}${lessonVariants[0].number}',
                        ),
                      ),
                    );
                    currLessonNum += lessonVariants[0].duration ~/ 2;
                  }

                  result = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
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

class LessonCard extends StatefulWidget {
  const LessonCard(this.lessonVariants, {super.key});

  static const baseHeight = 80.0;
  final List<Lesson> lessonVariants;

  @override
  State<LessonCard> createState() => _LessonCardState();

  static Widget placeholder(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: colorScheme.surface,
              child: Container(
                height: baseHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.onSurface.withAlpha(50),
                  ),
                  borderRadius: const BorderRadiusGeometry.all(
                    Radius.circular(15),
                  ),
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
          ),
        ],
      ),
    );
  }
}

class _LessonCardState extends State<LessonCard> {
  late int selectedVariantIdx;

  @override
  void initState() {
    super.initState();
    selectedVariantIdx = 1;
  }

  @override
  void dispose() {
    super.dispose();
    selectedVariantIdx = 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final variant = widget.lessonVariants[selectedVariantIdx - 1];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          if (widget.lessonVariants.length > 1)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SegmentedButton(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    side: BorderSide(
                      color: colorScheme.onSurface.withAlpha(30),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                  segments: [
                    for (var i = 1; i < widget.lessonVariants.length + 1; i++)
                      ButtonSegment(value: i, label: Text(i.toString())),
                  ],
                  showSelectedIcon: false,
                  selected: {selectedVariantIdx},
                  onSelectionChanged: (sel) {
                    setState(() {
                      selectedVariantIdx = sel.first;
                    });
                  },
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
                  ),
                  color: colorScheme.surfaceContainerHigh,
                  child: TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) {
                          return AdditionalInfoDialogue(variant);
                        },
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(15),
                        ),
                      ),
                    ),
                    child: Container(
                      height: LessonCard.baseHeight * (variant.duration ~/ 2),
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
                                      '${variant.startAt.hour}:${variant.startAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${variant.endAt.hour}:${variant.endAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onSurface.withAlpha(
                                          90,
                                        ),
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
                                          variant.lessonName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Text(
                                        variant.type.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurface
                                              .withAlpha(130),
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
                                              color: colorScheme.onSurface
                                                  .withAlpha(130),
                                            ),
                                            Text(
                                              variant.auditoryName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.onSurface
                                                    .withAlpha(130),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Icon(
                                        Icons.person,
                                        size: 15,
                                        color: colorScheme.onSurface.withAlpha(
                                          130,
                                        ),
                                      ),

                                      Text(
                                        variant.teacherName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurface
                                              .withAlpha(130),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdditionalInfoDialogue extends StatelessWidget {
  const AdditionalInfoDialogue(this.lesson, {super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final textInfo = [
      ('Название: ', lesson.lessonName),
      ('Длительность: ', '${lesson.duration}ч'),
      if (lesson.subInfo != null) ('Комментарий: ', lesson.subInfo),
    ];

    final boolInfo =
        [
              ('В потоке', lesson.isStream),
              ('По подгруппам', lesson.isDivision),
              ('Сокращённая', lesson.isShort),
              ('Дистант', lesson.isDistant),
              ('На нечётной', lesson.parity == 1),
              ('На чётной', lesson.parity == 2),
            ]
            .where((inf) => inf.$2)
            .map(
              (inf) => Chip(
                side: const BorderSide(color: Colors.transparent),
                label: Text(
                  inf.$1,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.all(1),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                // ma,
              ),
            );

    final textStyle = DefaultTextStyle.of(context).style;
    return AlertDialog(
      title: const Text(
        'Доп. Информация',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            for (final field in textInfo)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: field.$1,
                      style: textStyle.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
                    TextSpan(text: field.$2, style: textStyle),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 3,
                runSpacing: 3,
                children: boolInfo.toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:ystu_schedule/utils/date.dart';

class WeekDay {
  final int type;
  final DateTime date;
  final int weekNumber;
  const WeekDay(this.type, this.date, this.weekNumber);
}

class Lesson {
  final int number;
  final DateTime startAt;
  final DateTime endAt;
  final int parity;
  final bool isDistant;
  final String lessonName;
  final String? subInfo;
  final String type;
  final bool isStream;
  final int duration;
  final bool isDivision;
  final bool isShort;
  final bool isLecture;
  final String auditoryName;
  final String teacherName;

  const Lesson({
    required this.number,
    required this.startAt,
    required this.endAt,
    required this.parity,
    required this.isDistant,
    required this.lessonName,
    required this.subInfo,
    required this.type,
    required this.isStream,
    required this.duration,
    required this.isDivision,
    required this.isShort,
    required this.isLecture,
    required this.auditoryName,
    required this.teacherName,
  });

  factory Lesson.fromJson(Map<String, dynamic> json, int index) {
    switch (json) {
      case {
        'startAt': final String startAt,
        'endAt': final String endAt,
        'type': final int type,
        'isStream': final bool isStream,
        'isDivision': final bool isDivision,
      }:
        final subInfo = json['subInfo'];
        return Lesson(
          number: json['number'] ?? index + 1,
          subInfo: subInfo,
          lessonName: json['lessonName'] ?? subInfo ?? '???',
          type: typeToString(type) ?? subInfo ?? '???',

          startAt: DateTime.parse(startAt).toLocal(),
          endAt: DateTime.parse(endAt).toLocal(),

          parity: json['parity'] ?? 0,
          duration: json['duration'] ?? 2,
          auditoryName: json['auditoryName'] ?? '???',
          teacherName: json['teacherName'] ?? '???',

          isDistant: json['isDistant'] ?? false,
          isStream: isStream,
          isDivision: isDivision,
          isShort: json['isShort'] ?? false,
          isLecture: json['isLecture'] ?? false,
        );

      default:
        throw const FormatException('Failed to parse Lesson');
    }
  }

  static final LESSON_TYPE_NAMES = [
    (0, '???'),
    (1 << 1, 'Лекция'),
    (1 << 2, 'Практика'),
    (1 << 3, 'Лабораторная'),
    (1 << 4, 'Курсовая'),
    (1 << 5, 'Консультация'),
    (1 << 6, 'Зачёт'),
    (1 << 7, 'Диф. зачёт'),
    (1 << 8, 'Экзамен'),
    (1 << 9, 'Библиотека'),
    (1 << 10, 'НИР'),
    (1 << 11, 'Орг. собрание'),
    (1 << 12, 'Другое'),
    (1 << 13, 'Практика'),
    (1 << 14, 'Событие'),
    (1 << 15, 'ВУЦ'),
    (1 << 16, 'Физ. культура'),
    (1 << 17, 'Факультатив'),
    (1 << 18, 'Внешнее занятие'),
    (1 << 20, 'Тензор'),
    (1 << 21, 'Школа 21'),
  ];

  static String? typeToString(int type) {
    for (final lessonType in LESSON_TYPE_NAMES) {
      if (type == lessonType.$1) {
        return lessonType.$2;
      }
    }

    return null;
  }
}

class Day {
  final WeekDay info;
  final List<List<Lesson>> lessons = [];

  Day(this.info, List<Lesson> items) {
    if (items.length == 0) return;

    var currLesson = [items[0]];
    for (final l in items.skip(1)) {
      if (l.startAt.equalsHM(currLesson[0].startAt)) {
        currLesson.add(l);
      } else {
        lessons.add(currLesson);
        currLesson = [l];
      }
    }

    lessons.add(currLesson);
  }
}

class Week {
  final int number;
  final List<Day> days;
  const Week(this.number, this.days);

  Day? findDay(DateTime date) {
    for (final day in days) {
      if (day.info.date.year == date.year &&
          day.info.date.weekday == date.weekday) {
        return day;
      }
    }

    return null;
  }
}

class GroupSchedule {
  final List<Week> items;
  const GroupSchedule(this.items);

  Week? findWeekByFirstDay(DateTime firstDay) {
    final lastDay = firstDay.add(const Duration(days: 6));
    for (final week in items) {
      for (final day in week.days) {
        if (day.info.date.year == firstDay.year &&
            day.info.date.month == firstDay.month &&
            day.info.date.day >= firstDay.day &&
            day.info.date.compareTo(firstDay) >= 0 &&
            day.info.date.compareTo(lastDay) <= 0) {
          return week;
        }
      }
    }

    return null;
  }

  factory GroupSchedule.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'items': final List<dynamic> items} => GroupSchedule(
        items.map((w) {
          return switch (w) {
            {'number': final int number, 'days': final List<dynamic> days} =>
              Week(
                number,
                days.map((d) {
                  return switch (d) {
                    {
                      'info': final dynamic info,
                      'lessons': final List<dynamic> lessons,
                    } =>
                      Day(
                        switch (info) {
                          {
                            'type': final int type,
                            'date': final String date,
                            'weekNumber': final int weekNumber,
                          } =>
                            WeekDay(
                              type,
                              DateTime.parse(date).toLocal(),
                              weekNumber,
                            ),

                          _ => throw const FormatException(
                            'Failed to parse WeekDay',
                          ),
                        },
                        lessons
                            .asMap()
                            .entries
                            .map((e) => Lesson.fromJson(e.value, e.key))
                            .toList(),
                      ),

                    _ => throw const FormatException('Failed to parse Day'),
                  };
                }).toList(),
              ),

            _ => throw const FormatException('Failed to parse Week'),
          };
        }).toList(),
      ),

      _ => throw const FormatException('Failed to parse GroupSchedule'),
    };
  }
}

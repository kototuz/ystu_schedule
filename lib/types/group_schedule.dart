class WeekDay {
  final int type;
  final DateTime date;
  final int weekNumber;
  const WeekDay(this.type, this.date, this.weekNumber);
}

class LessonType {
  static final LESSON_TYPE_NAMES = [
    (0     ,  '???'),
    (1 << 1,  'Лекция'),
    (1 << 2,  'Практика'),
    (1 << 3,  'Лабораторная'),
    (1 << 4,  'Курсовая'),
    (1 << 5,  'Консультация'),
    (1 << 6,  'Зачёт'),
    (1 << 7,  'Диф. зачёт'),
    (1 << 8,  'Экзамен'),
    (1 << 9,  'Библиотека'),
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

  final int flags;
  const LessonType(this.flags);

  @override
  String toString() {
    return LESSON_TYPE_NAMES.firstWhere((t) => t.$1 == flags).$2;
  }
}

class Lesson {
  final int number;
  final DateTime startAt;
  final DateTime endAt;
  final int parity;
  final bool isDistant;
  final String lessonName;
  final LessonType type;
  final bool isStream;
  final int duration;
  final bool isDivision;
  final bool isShort;
  final bool isLecture;
  final String auditoryName;
  final String teacherName;

  const Lesson(
    this.number,
    this.startAt,
    this.endAt,
    this.parity,
    this.isDistant,
    this.lessonName,
    this.type,
    this.isStream,
    this.duration,
    this.isDivision,
    this.isShort,
    this.isLecture,
    this.auditoryName,
    this.teacherName,
  );
}

class Day {
  final WeekDay info;
  final List<Lesson> lessons;
  const Day(this.info, this.lessons);
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
                            WeekDay(type, DateTime.parse(date), weekNumber),

                          _ => throw const FormatException(
                            'Failed to parse WeekDay',
                          ),
                        },
                        lessons.asMap().entries.map((e) {
                          final lesson = e.value;
                          return switch (lesson) {
                            {
                              'startAt': final String startAt,
                              'endAt': final String endAt,
                              'type': final int type,
                              'isStream': final bool isStream,
                              'isDivision': final bool isDivision,
                            } =>
                              Lesson(
                                lesson['number'] ?? e.key + 1,
                                DateTime.parse(startAt),
                                DateTime.parse(endAt),
                                lesson['parity'] ?? 0,
                                lesson['isDistant'] ?? false,
                                lesson['lessonName'] ?? lesson['subInfo'] ?? '???',
                                LessonType(type),
                                isStream,
                                lesson['duration'] ?? 0,
                                isDivision,
                                lesson['isShort'] ?? false,
                                lesson['isLecture'] ?? false,
                                lesson['auditoryName'] ?? '???',
                                lesson['teacherName'] ?? '???',
                              ),
                            _ => throw const FormatException(
                              'Failed to parse Lesson',
                            ),
                          };
                        }).toList(),
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

import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';

class ScheduleNavigator extends StatefulWidget {
  final ScheduleModel model;
  final double screenWidth;

  const ScheduleNavigator(this.model, this.screenWidth, {super.key});

  @override
  State<ScheduleNavigator> createState() => _ScheduleNavigatorState();
}

class _ScheduleNavigatorState extends State<ScheduleNavigator>
    with SingleTickerProviderStateMixin {
  static const MIN_SWIPE_DELTA = 100;

  var panStartX = 0.0;
  var currX = 0.0;

  // 3 weeks to create effect of infinite scrolling
  late List<DateTime> weekBuffer;

  late AnimationController controller;
  late CurvedAnimation curve;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    weekBuffer = [
      widget.model.weekBeginDate.subtract(const Duration(days: 7)),
      widget.model.weekBeginDate,
      widget.model.weekBeginDate.add(const Duration(days: 7)),
    ];

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    controller.addListener(() {
      setState(() {
        currX = animation.value;
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (animation.value == widget.screenWidth) {
          weekBuffer[2] = weekBuffer[1];
          weekBuffer[1] = weekBuffer[0];
          weekBuffer[0] = weekBuffer[1].subtract(const Duration(days: 7));
          widget.model.setWeek(weekBuffer[1]);
        } else if (animation.value == -widget.screenWidth) {
          weekBuffer[0] = weekBuffer[1];
          weekBuffer[1] = weekBuffer[2];
          weekBuffer[2] = weekBuffer[1].add(const Duration(days: 7));
          widget.model.setWeek(weekBuffer[1]);
        }

        setState(() {
          currX = 0;
        });
      }
    });

    curve = CurvedAnimation(parent: controller, curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenWidth,
      height: 120,
      child: Stack(
        children: [
          Positioned(
            left: currX - widget.screenWidth,
            child: GestureDetector(
              onPanStart: (details) {
                panStartX = details.globalPosition.dx;
              },
              onPanUpdate: (details) {
                setState(() {
                  currX = details.globalPosition.dx - panStartX;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  final delta = details.globalPosition.dx - panStartX;
                  if (delta > MIN_SWIPE_DELTA) {
                    animation = Tween<double>(
                      begin: currX,
                      end: widget.screenWidth,
                    ).animate(curve);
                  } else if (delta < -MIN_SWIPE_DELTA) {
                    animation = Tween<double>(
                      begin: currX,
                      end: -widget.screenWidth,
                    ).animate(curve);
                  } else {
                    animation = Tween<double>(
                      begin: currX,
                      end: 0,
                    ).animate(curve);
                  }

                  controller.reset();
                  controller.forward();
                });
              },
              child: Row(
                children: [
                  for (final week in weekBuffer)
                    WeekCalendar(widget.model, widget.screenWidth, week),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekCalendar extends StatefulWidget {
  final ScheduleModel model;
  final double width;
  final DateTime weekBeginDate;

  const WeekCalendar(this.model, this.width, this.weekBeginDate, {super.key});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
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

  // NOTE: Compares only year, month and day
  bool dateEquals(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> weekdays = [];
    for (var i = 0; i < WEEK_NAMES.length; i++) {
      final date = widget.weekBeginDate.add(Duration(days: i));

      final (bgColor, fgColor) = date == widget.model.selectedDayDate
          ? (colorScheme.surface, colorScheme.onSurface)
          : (colorScheme.primary, colorScheme.onPrimary);

      weekdays.add(
        Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.all(10.0),
              shape: const RoundedRectangleBorder(),
              backgroundColor: bgColor,
            ),
            onPressed: () => setState(() => widget.model.setSelectedDay(date)),
            child: Container(
              foregroundDecoration: BoxDecoration(
                border: dateEquals(date, widget.model.now)
                    ? Border(top: BorderSide(width: 1.5, color: fgColor))
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(WEEK_NAMES[i], style: TextStyle(color: fgColor)),
                  Text(style: TextStyle(color: fgColor), date.day.toString()),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      color: colorScheme.primary,
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Text(
            MONTH_NAMES[widget.weekBeginDate.month - 1] +
                ' ' +
                widget.weekBeginDate.year.toString(),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(children: weekdays),
        ],
      ),
    );
  }
}

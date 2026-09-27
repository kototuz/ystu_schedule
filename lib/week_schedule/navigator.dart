import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule/model.dart';

class WeekScheduleNavigator extends StatefulWidget {
  final WeekScheduleModel model;

  const WeekScheduleNavigator(this.model, {super.key});

  @override
  State<WeekScheduleNavigator> createState() => _WeekScheduleNavigatorState();
}

class _WeekScheduleNavigatorState extends State<WeekScheduleNavigator> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final List<Widget> weekdays = [];
    for (var i = 0; i < WEEK_NAMES.length; i++) {
      final (bgColor, fgColor) = i == widget.model.selectedWeekday
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
            onPressed: () => setState(() => widget.model.setSelectedWeekday(i)),
            child: Container(
              foregroundDecoration: BoxDecoration(
                border: widget.model.now.weekday == i + 1
                    ? Border(top: BorderSide(width: 1.5, color: fgColor))
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(WEEK_NAMES[i], style: TextStyle(color: fgColor)),
                  Text(
                    style: TextStyle(color: fgColor),
                    widget.model.weekBeginDate
                        .add(Duration(days: i))
                        .day
                        .toString(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Column(
        spacing: 5,
        children: [
          Text(
            MONTH_NAMES[widget.model.now.month - 1],
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(spacing: 0, children: weekdays),
        ],
      ),
    );
  }
}

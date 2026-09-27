import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ystu_schedule/types/group_schedule.dart';

class WeekScheduleModel with ChangeNotifier {
  late DateTime now;
  late DateTime weekBeginDate;
  late int selectedWeekday;

  GroupSchedule? schedule;
  Week? week;

  WeekScheduleModel() {
    now = DateTime.now();
    weekBeginDate = now.subtract(Duration(days: now.weekday - 1));
    selectedWeekday = now.weekday - 1;

    http.get(Uri.parse('http://192.168.1.51:8000/ЦИС-15')).then((resp) {
      if (resp.statusCode == 200) {
        schedule = GroupSchedule.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );

        week = schedule!.findWeekByFirstDay(weekBeginDate);
        notifyListeners();
      } else {
        throw Exception('Failed to load schedule');
      }
    });
  }

  void setSelectedWeekday(int day) {
    selectedWeekday = day;
    notifyListeners();
  }
}

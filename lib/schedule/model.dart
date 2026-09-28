import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ystu_schedule/resource_state.dart' as rs;
import 'package:ystu_schedule/types/group_list.dart';
import 'package:ystu_schedule/types/group_schedule.dart';

class ScheduleModel with ChangeNotifier {
  late DateTime now;
  late DateTime weekBeginDate;
  late DateTime selectedDayDate;

  rs.State<GroupList>? groupList;
  var selectedGroupIdx = 0;

  rs.State<GroupSchedule>? schedule;
  Week? week;
  Day? selectedDay;

  ScheduleModel() {
    now = DateTime.now();
    weekBeginDate = now.subtract(Duration(days: now.weekday - 1));
    selectedDayDate = now;
  }

  static Future<rs.State<GroupSchedule>> downloadGroupSchedule(String grpName) {
    return http
        .get(Uri.parse('http://192.168.1.51:8000/${grpName}'))
        .then(
          (resp) => resp.statusCode == 200
              ? rs.Ok(
                  GroupSchedule.fromJson(
                    jsonDecode(resp.body) as Map<String, dynamic>,
                  ),
                )
              : rs.Error('Не удалось загрузить расписание'),
        );
  }

  static Future<rs.State<GroupList>> downloadGroupList() {
    return http
        .get(Uri.parse('http://192.168.1.51:8000/actual_groups'))
        .then(
          (resp) => resp.statusCode == 200
              ? rs.Ok(
                  GroupList.fromJson(
                    jsonDecode(resp.body) as Map<String, dynamic>,
                  ),
                )
              : rs.Error('Не удалось загрузить список групп'),
        );
  }

  void setSchedule(rs.State<GroupSchedule>? newSchedule) {
    if (newSchedule case rs.Ok(value: final it)) {
      week = it.findWeekByFirstDay(weekBeginDate);
      selectedDay = week?.findDay(selectedDayDate);
      schedule = newSchedule;
      notifyListeners();
    }
  }

  void setSelectedDay(DateTime day) {
    selectedDayDate = day;
    selectedDay = week?.findDay(day);
    notifyListeners();
  }

  void setWeek(DateTime weekFirstDayDate) {
    weekBeginDate = weekFirstDayDate;
    if (schedule case rs.Ok(value: final val)) {
      week = val.findWeekByFirstDay(weekBeginDate);
      notifyListeners();
    }
  }
}

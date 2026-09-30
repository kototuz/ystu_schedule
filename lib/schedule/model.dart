import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ystu_schedule/error.dart';
import 'package:ystu_schedule/resource_state.dart' as rs;
import 'package:ystu_schedule/types/group_list.dart';
import 'package:ystu_schedule/types/group_schedule.dart';

class ScheduleModel with ChangeNotifier {
  late DateTime now;
  late DateTime weekBeginDate;
  late DateTime selectedDayDate;

  rs.State<GroupList>? groupList = rs.Downloading();
  var selectedGroupIdx = 0;

  rs.State<GroupSchedule>? schedule = rs.Downloading();
  Week? week;
  Day? selectedDay;

  late SharedPreferences prefs;
  late File groupListFile;
  late File scheduleFile;

  ScheduleModel() {
    now = DateTime.now();
    weekBeginDate = now.subtract(Duration(days: now.weekday - 1));
    selectedDayDate = now;

    initResources();
  }

  void initResources() async {
    final dir = await getApplicationDocumentsDirectory();

    groupListFile = File('${dir.path}/group_list.json');
    if (groupListFile.existsSync()) {
      final content = await groupListFile.readAsString();
      groupList = rs.Ok(
        GroupList.fromJson(jsonDecode(content) as Map<String, dynamic>),
      );
    } else {
      groupList = null;
    }

    scheduleFile = File('${dir.path}/schedule.json');
    if (scheduleFile.existsSync()) {
      final content = await scheduleFile.readAsString();
      setSchedule(
        GroupSchedule.fromJson(jsonDecode(content) as Map<String, dynamic>),
      );
    } else {
      schedule = null;
    }

    prefs = await SharedPreferences.getInstance();
    selectedGroupIdx = prefs.getInt('group') ?? 0;

    notifyListeners();
  }

  Future<void> updateGroupSchedule(Function(String) onError) async {
    try {
      if (groupList case rs.Ok(value: final gl)) {
        final groupName = gl.getGroupNameByIdx(selectedGroupIdx);
        final resp = await httpGet('http://192.168.1.51:8000/$groupName');

        final newSchedule = GroupSchedule.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );

        scheduleFile.writeAsBytes(resp.bodyBytes);

        setSchedule(newSchedule);
        notifyListeners();
      } else {
        onError('Список групп не скачен');
      }
    } on AppError catch (e) {
      onError(e.message);
    } on FormatException {
      onError('Неожиданный формат расписания');
    }
  }

  void updateGroupList(Function(String) onError) async {
    final oldGroupList = groupList;
    try {
      groupList = rs.Downloading();
      notifyListeners();

      final resp = await httpGet('http://192.168.1.51:8000/actual_groups');

      groupList = rs.Ok(
        GroupList.fromJson(jsonDecode(resp.body) as Map<String, dynamic>),
      );

      selectedGroupIdx = 0;
      groupListFile.writeAsBytes(resp.bodyBytes);
    } on AppError catch (e) {
      groupList = oldGroupList;
      onError(e.message);
    } on FormatException {
      groupList = oldGroupList;
      onError('Неожиданный формат списка групп');
    } finally {
      notifyListeners();
    }
  }

  static Future<http.Response> httpGet(String url) async {
    try {
      final resp = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (resp.statusCode != 200) {
        throw AppError('Сервер ответил с ошибкой ${resp.statusCode}');
      }

      return resp;
    } on SocketException {
      throw const AppError('Не удалось подключиться к серверу');
    } on TimeoutException {
      throw const AppError('Сервер не отвечает');
    }
  }

  void setSchedule(GroupSchedule newSchedule) {
    week = newSchedule.findWeekByFirstDay(weekBeginDate);
    selectedDay = week?.findDay(selectedDayDate);
    schedule = rs.Ok(newSchedule);
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
    }
  }

  void setGroup(int idx) {
    selectedGroupIdx = idx;
    prefs.setInt('group', selectedGroupIdx);
  }
}

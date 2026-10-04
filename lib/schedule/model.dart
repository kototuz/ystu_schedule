import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ystu_schedule/types/group_list.dart';
import 'package:ystu_schedule/types/group_schedule.dart';

sealed class Resource<T> {}

final class PendingResource<T> extends Resource<T> {}

final class ReadyResource<T> extends Resource<T> {
  final T value;
  ReadyResource(this.value);
}

class AppError implements Exception {
  final String message;
  const AppError(this.message);
}

class ScheduleModel with ChangeNotifier {
  late DateTime now;
  late DateTime weekBeginDate;
  late DateTime selectedDayDate;

  Resource<GroupList>? groupList = PendingResource();
  var selectedGroupIdx = 0;

  Resource<GroupSchedule>? schedule = PendingResource();
  Week? week;
  Day? selectedDay;

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
      groupList = ReadyResource(
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

    final prefs = await SharedPreferences.getInstance();
    selectedGroupIdx = prefs.getInt('group') ?? 0;

    notifyListeners();
  }

  Future<GroupSchedule> updateGroupSchedule() async {
    try {
      if (groupList case ReadyResource(value: final gl)) {
        final groupName = gl.getGroupNameByIdx(selectedGroupIdx);
        final resp = await httpGet('http://192.168.1.51:8000/$groupName');

        final newSchedule = GroupSchedule.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );

        scheduleFile.writeAsBytes(resp.bodyBytes);

        setSchedule(newSchedule);
        notifyListeners();

        return newSchedule;
      } else {
        throw const AppError('Список групп не скачен');
      }
    } on FormatException {
      throw const AppError('Неожиданный формат расписания');
    }
  }

  Future<GroupList> updateGroupList() async {
    final oldGroupList = groupList;
    try {
      groupList = PendingResource();
      notifyListeners();

      final resp = await httpGet('http://192.168.1.51:8000/actual_groups');

      final newGroupList = GroupList.fromJson(
        jsonDecode(resp.body) as Map<String, dynamic>,
      );

      groupList = ReadyResource(newGroupList);

      selectedGroupIdx = 0;
      groupListFile.writeAsBytes(resp.bodyBytes);

      return newGroupList;
    } on AppError {
      groupList = oldGroupList;
      rethrow;
    } on FormatException {
      groupList = oldGroupList;
      throw const AppError('Неожиданный формат списка групп');
    } finally {
      notifyListeners();
    }
  }

  void setSchedule(GroupSchedule newSchedule) {
    week = newSchedule.findWeekByFirstDay(weekBeginDate);
    selectedDay = week?.findDay(selectedDayDate);
    schedule = ReadyResource(newSchedule);
  }

  void setSelectedDay(DateTime day) {
    selectedDayDate = day;
    selectedDay = week?.findDay(day);
    notifyListeners();
  }

  void setWeek(DateTime weekFirstDayDate) {
    weekBeginDate = weekFirstDayDate;
    if (schedule case ReadyResource(value: final val)) {
      week = val.findWeekByFirstDay(weekBeginDate);
    }
  }

  void setGroup(int idx) {
    selectedGroupIdx = idx;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt('group', selectedGroupIdx),
    );
  }

  static Future<int> presentFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    var result = 0;

    if (File('${dir.path}/group_list.json').existsSync()) {
      result += 1;
    }

    if (File('${dir.path}/schedule.json').existsSync()) {
      result += 1;
    }

    return result;
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
}

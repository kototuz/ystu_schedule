import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeModel extends ChangeNotifier {
  static const modes = [
    (ThemeMode.system, 'Системная'),
    (ThemeMode.dark, 'Тёмная'),
    (ThemeMode.light, 'Светлая'),
  ];

  static const colors = [
    (Colors.red, 'Красный'),
    (Colors.green, 'Зелёный'),
    (Colors.blue, 'Синий'),
    (Colors.pink, 'Розовый'),
    (Colors.orange, 'Оранжевый'),
    (Colors.yellow, 'Жёлтый'),
    (Colors.brown, 'Коричневый'),
    (Colors.purple, 'Фиолетовый'),
    (Colors.cyan, 'Голубой'),
    (Colors.teal, 'Сине-зелёный'),
    (Colors.indigo, 'Индиго'),
    (Colors.lime, 'Лайм'),
    (Colors.amber, 'Янтарный'),
  ];

  late int modeIdx;
  late int colorIdx;

  Color get color => colors[colorIdx].$1;
  ThemeMode get mode => modes[modeIdx].$1;

  AppThemeModel() {
    SharedPreferences.getInstance().then((prefs) {
      modeIdx = prefs.getInt('theme_mode') ?? 0;
      colorIdx = prefs.getInt('theme_color') ?? 10;
      notifyListeners();
    });
  }

  void setMode(int idx) {
    modeIdx = idx;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('theme_mode', modeIdx);
      notifyListeners();
    });
  }

  void setColor(int idx) {
    colorIdx = idx;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('theme_color', colorIdx);
      notifyListeners();
    });
  }
}

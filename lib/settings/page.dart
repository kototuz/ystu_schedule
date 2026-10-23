import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/settings/app_theme_model.dart';
import 'package:ystu_schedule/settings/group.dart';

class SettingsPage extends StatelessWidget {
  final ScheduleModel model;
  final AppThemeModel themeModel;

  const SettingsPage(this.model, this.themeModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
      child: Column(
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Align(
              alignment: AlignmentGeometry.topStart,
              child: Text(
                'Настройки',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          SettingsGroup(model),

          DropdownMenu(
            inputDecorationTheme: const InputDecorationTheme(filled: true),
            expandedInsets: .zero,
            label: const Text('Тема'),
            initialSelection: themeModel.modeIdx,
            dropdownMenuEntries: [
              for (var i = 0; i < AppThemeModel.modes.length; i++)
                DropdownMenuEntry(value: i, label: AppThemeModel.modes[i].$2),
            ],
            onSelected: (value) {
              themeModel.setMode(value!);
            },
          ),

          DropdownMenu(
            inputDecorationTheme: const InputDecorationTheme(filled: true),
            expandedInsets: .zero,
            label: const Text('Цвет темы'),
            initialSelection: themeModel.colorIdx,
            dropdownMenuEntries: [
              for (var i = 0; i < AppThemeModel.colors.length; i++)
                DropdownMenuEntry(value: i, label: AppThemeModel.colors[i].$2),
            ],
            onSelected: (value) {
              themeModel.setColor(value!);
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 10,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadiusGeometry.all(
                    Radius.circular(3),
                  ),
                ),
                padding: const EdgeInsets.all(5),
                child: Text(
                  const String.fromEnvironment('VERSION_TAG', defaultValue: 'debug'),
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
                ),
              ),
              ElevatedButton(
                child: const Text('Посмотреть обновления'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/kototuz/ystu_schedule/releases/latest'), mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

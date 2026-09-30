import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/settings/group.dart';

class SettingsPage extends StatelessWidget {
  final ScheduleModel model;

  const SettingsPage(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
      child: Column(
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
        ],
      ),
    );
  }
}

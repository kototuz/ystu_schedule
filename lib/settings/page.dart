import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ystu_schedule/resource_state.dart' as rs;
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/types/group_list.dart';

class SettingsPage extends StatefulWidget {
  final ScheduleModel model;

  const SettingsPage(this.model, {super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  rs.State<GroupList>? oldGroupList;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.model.groupList case rs.Downloading()) {
      widget.model.groupList = oldGroupList;
    }
  }

  @override
  Widget build(BuildContext context) {
    var groupMenuEnabled = true;
    final List<DropdownMenuEntry<int>> groupMenuEntries = [];
    final colorScheme = Theme.of(context).colorScheme;

    Widget updateButton = RawMaterialButton(
      elevation: Theme.of(context).brightness == Brightness.light ? 1 : 0,
      highlightElevation: 0,
      fillColor: colorScheme.surfaceContainerHigh,
      constraints: const BoxConstraints(minWidth: 0.0),
      child: const Icon(Icons.update, size: 20.0),
      padding: const EdgeInsets.all(10.0),
      shape: const CircleBorder(),
      onPressed: () {
        setState(() {
          oldGroupList = widget.model.groupList;
          widget.model.groupList = rs.Downloading();
          ScheduleModel.downloadGroupList().then((groupList) {
            if (!mounted) return;

            if (groupList case rs.Error(message: final msg)) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
              widget.model.groupList = oldGroupList;
            } else {
              widget.model.groupList = groupList;
              widget.model.selectedGroupIdx = 0;
            }

            setState(() {});
          });
        });
      },
    );

    switch (widget.model.groupList) {
      case null:
        groupMenuEnabled = false;

      case rs.Downloading():
        groupMenuEnabled = false;
        updateButton = const Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        );

      case rs.Ok(value: final value):
        var groupIdx = 0;
        for (final insituteGroupList in value.items) {
          for (final groupName in insituteGroupList.groups) {
            groupMenuEntries.add(
              DropdownMenuEntry(value: groupIdx++, label: groupName),
            );
          }
        }
    }

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
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox(width: 50, child: updateButton),
              Expanded(
                child: DropdownMenu(
                  menuHeight: 400,
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                  ),
                  enabled: groupMenuEnabled,
                  initialSelection: widget.model.selectedGroupIdx,
                  expandedInsets: .zero,
                  label: const Text('Группа'),
                  dropdownMenuEntries: groupMenuEntries,
                  onSelected: (value) {
                    widget.model.selectedGroupIdx = value as int;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

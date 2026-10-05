import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';

class SettingsGroup extends StatefulWidget {
  final ScheduleModel model;

  const SettingsGroup(this.model, {super.key});

  @override
  State<SettingsGroup> createState() => _SettingsGroupState();
}

class _SettingsGroupState extends State<SettingsGroup> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, child) {
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
          onPressed: () async {
            try {
              await widget.model.updateGroupList();
            } on AppError catch (err) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err.message)));
              }
            }
          },
        );

        switch (widget.model.groupList) {
          case null:
            groupMenuEnabled = false;

          case PendingResource():
            groupMenuEnabled = false;
            updateButton = const Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            );

          case ReadyResource(value: final value):
            var groupIdx = 0;
            for (final insituteGroupList in value.items) {
              for (final groupName in insituteGroupList.groups) {
                groupMenuEntries.add(
                  DropdownMenuEntry(value: groupIdx++, label: groupName),
                );
              }
            }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: [
            SizedBox(width: 50, child: updateButton),
            Expanded(
              child: DropdownMenu(
                menuHeight: 400,
                inputDecorationTheme: const InputDecorationTheme(filled: true),
                enabled: groupMenuEnabled,
                initialSelection: widget.model.selectedGroupIdx,
                expandedInsets: .zero,
                label: const Text('Группа'),
                dropdownMenuEntries: groupMenuEntries,
                onSelected: (value) {
                  widget.model.setGroup(value as int);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

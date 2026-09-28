import 'package:flutter/material.dart';
import 'package:ystu_schedule/week_schedule/model.dart';

class SettingsPage extends StatefulWidget {
  final WeekScheduleModel model;

  const SettingsPage(this.model, {super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              RawMaterialButton(
                elevation: 0,
                highlightElevation: 0,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                constraints: const BoxConstraints(minWidth: 0.0),
                child: const Icon(Icons.update, size: 20.0),
                padding: const EdgeInsets.all(10.0),
                shape: const CircleBorder(),
                onPressed: () {},
              ),
              Expanded(
                child: DropdownMenu(
                  menuHeight: 400,
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                  ),
                  // initialSelection: widget.model.selectedGroupIdx,
                  expandedInsets: .zero,
                  label: const Text('Группа'),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 0, label: 'First'),
                    DropdownMenuEntry(value: 0, label: 'Second'),
                    DropdownMenuEntry(value: 0, label: 'Third'),
                  ],
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

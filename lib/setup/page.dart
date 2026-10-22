import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/setup/guide.dart';
import 'package:ystu_schedule/setup/model.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({required this.child, required this.model, super.key});

  final Widget child;
  final ScheduleModel model;

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late SetupModel setupModel;

  @override
  void initState() {
    super.initState();
    setupModel = SetupModel(widget.model);
    setupModel.startOrContinue();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: setupModel,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        switch (setupModel.state) {
          case SetupStateDownloading():
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case SetupStateError(message: final msg):
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Text(msg),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: const Text('Повторить'),
                        onPressed: () {
                          setupModel.retry();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );

          case SetupStateSelectingGroup(groups: final groups):
            return Scaffold(
              appBar: AppBar(title: const Text('Выберите группу')),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    for (final group in groups)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainer,
                        ),
                        onPressed: () {
                          setupModel.selectGroup(group.idx);
                        },
                        child: Text(
                          group.name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );

          case SetupStateDone():
            return widget.child;

          case SetupStateGuide():
            return Guide(setupModel);
        }
      },
    );
  }
}

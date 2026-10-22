import 'package:flutter/material.dart';
import 'package:ystu_schedule/schedule/model.dart';
import 'package:ystu_schedule/types/group_list.dart';

sealed class SetupState {}

final class SetupStateDownloading extends SetupState {}

final class SetupStateGuide extends SetupState {}

final class SetupStateDone extends SetupState {}

final class SetupStateSelectingGroup extends SetupState {
  final List<({int idx, String name})> groups;

  SetupStateSelectingGroup(this.groups);

  factory SetupStateSelectingGroup.fromGroupList(GroupList gl) {
    final List<({int idx, String name})> items = [];
    var groupIdx = 0;
    for (final instututeGroupList in gl.items) {
      for (final groupName in instututeGroupList.groups) {
        items.add((idx: groupIdx++, name: groupName));
      }
    }

    return SetupStateSelectingGroup(items);
  }
}

final class SetupStateError extends SetupState {
  final String message;
  SetupStateError(this.message);
}

class SetupModel extends ChangeNotifier {
  final ScheduleModel model;

  SetupModel(this.model);

  SetupState state = SetupStateDownloading();
  var stage = 0;

  void startOrContinue() async {
    loop:
    while (true) {
      switch (stage) {
        case 0:
          state = SetupStateDownloading();
          notifyListeners();
          stage = (await ScheduleModel.presentFiles()) + 1;

        case 1:
          try {
            state = SetupStateDownloading();
            notifyListeners();
            final gl = await model.updateGroupList();
            state = SetupStateSelectingGroup.fromGroupList(gl);
          } on AppError catch (e) {
            state = SetupStateError(e.message);
          }
          notifyListeners();
          break loop;

        case 2:
          try {
            state = SetupStateDownloading();
            notifyListeners();
            await model.updateGroupSchedule();
            stage = 4;
          } on AppError catch (e) {
            state = SetupStateError(e.message);
            notifyListeners();
            break loop;
          }

        case 3:
          state = SetupStateDone();
          notifyListeners();
          break loop;

        case 4:
          state = SetupStateGuide();
          notifyListeners();
          break loop;
      }
    }
  }

  void retry() {
    if (stage == 2) {
      stage = 1;
    }

    startOrContinue();
  }

  void selectGroup(int idx) {
    model.setGroup(idx);
    stage = 2;
    startOrContinue();
  }

  void finishSetup() {
    stage = 3;
    startOrContinue();
  }
}

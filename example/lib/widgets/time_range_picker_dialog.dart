import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

void showTimeRangePickerDialog(BuildContext context, void Function(int beigin, int end) onConfirm, {int beginTime, int endTime}) {
  if (beginTime >= 24) {
    beginTime = 0;
  }
  if (endTime <= beginTime) {
    endTime = beginTime + 1;
  }
  var picker = Picker(
    hideHeader: true,
    cancelText: "取消",
    confirmText: "确定",
    adapter: PickerDataAdapter(
      data: pickerItems()
    ),
    onConfirm: (picker, selected) {
      onConfirm(selected[0], selected[1] + selected[0] + 1);
    },
    selecteds: [beginTime, endTime - beginTime - 1]
  );
  picker.showDialog(context);
}

List<PickerItem> pickerItems() {
  List<PickerItem> first = [];
  for (var i = 0; i < 24; i ++) {
    List<PickerItem> second = [];
    for (var j = i + 1; j <= 24; j ++) {
      second.add(
        PickerItem(
          text: Text("$j:00")
        )
      );
    }
    first.add(
      PickerItem(
        text: Text("$i:00"),
        children: second
      )
    );
  }
  return first;
}

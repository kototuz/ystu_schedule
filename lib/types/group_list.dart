class InstituteGroupList {
  final List<String> groups;
  const InstituteGroupList(this.groups);
}

class GroupList {
  final List<InstituteGroupList> items;
  const GroupList(this.items);

  factory GroupList.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'items': final List<dynamic> items} => GroupList(
        items.map((igl) {
          return switch (igl) {
            {'groups': final List<dynamic> groups} => InstituteGroupList(
              groups.map((s) => s as String).toList(),
            ),
            _ => throw const FormatException(
              'Failed to parse InstituteGroupList',
            ),
          };
        }).toList(),
      ),
      _ => throw const FormatException('Failed to parse GroupList'),
    };
  }

  static Map<String, dynamic> toJson(GroupList gl) {
    return {
      'items': gl.items.map((igl) => {'groups': igl.groups}).toList(),
    };
  }

  String getGroupNameByIdx(int idx) {
    var instituteIdx = 0;
    var grpIdx = 0;
    while (idx >= grpIdx + items[instituteIdx].groups.length) {
      grpIdx += items[instituteIdx].groups.length;
      instituteIdx += 1;
    }

    return items[instituteIdx].groups[idx - grpIdx];
  }
}

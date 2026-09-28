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
}

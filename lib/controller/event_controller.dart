import 'package:get/get.dart';
import 'package:vibe_now/model/category.dart';

class EventController extends GetxController {
  final RxSet<String> expandedParents = <String>{}.obs;

  final RxSet<String> selectedSubcategories = <String>{}.obs;

  final List<CategoryGroup> categoryGroups = [
    CategoryGroup(
      parent: 'Social & Connection',
      children: [
        'Meetups',
        'New Friends',
        'Expats',
        'Language Exchange',
        'Hangouts',
      ],
    ),
    CategoryGroup(
      parent: 'Sports & Movement',
      children: [
        'Running',
        'Gym',
        'Yoga / Pilates',
        'Team Sports',
        'Hiking',
        'Cycling',
      ],
    ),
    CategoryGroup(
      parent: 'Food & Drink',
      children: ['Dinner', 'Lunch', 'Desserts', 'Drinks', 'Snacks'],
    ),
  ];

  void toggleExpand(String parent) {
    expandedParents.contains(parent)
        ? expandedParents.remove(parent)
        : expandedParents.add(parent);
  }

  void toggleParent(CategoryGroup group) {
    final allSelected = group.children.every(
      (c) => selectedSubcategories.contains(c),
    );

    if (allSelected) {
      selectedSubcategories.removeAll(group.children);
    } else {
      selectedSubcategories.addAll(group.children);
      expandedParents.add(group.parent);
    }
  }

  void toggleSubcategory(String sub, String parent) {
    selectedSubcategories.contains(sub)
        ? selectedSubcategories.remove(sub)
        : selectedSubcategories.add(sub);

    expandedParents.add(parent);
  }

  void clear() {
    expandedParents.clear();
    selectedSubcategories.clear();
  }

  bool isParentSelected(CategoryGroup group) {
    return group.children.every((c) => selectedSubcategories.contains(c));
  }

  bool isParentPartiallySelected(CategoryGroup group) {
    final selectedCount = group.children
        .where((c) => selectedSubcategories.contains(c))
        .length;

    return selectedCount > 0 && selectedCount < group.children.length;
  }
}

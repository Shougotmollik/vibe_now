import 'package:get/get.dart';
import 'package:vibe_now/model/category.dart';

class EventController extends GetxController {
  
  final RxSet<String> expandedParents = <String>{}.obs;

  final RxSet<String> selectedSubcategories = <String>{}.obs;

  final RxList<CategoryGroup> categoryGroups = [
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
  ].obs;

  void addParentCategory(String name) {
    final exists = categoryGroups.any((e) => e.parent == name);
    if (exists) return;

    categoryGroups.add(CategoryGroup(parent: name, children: []));
  }

  void addSubCategory({required String parent, required String subCategory}) {
    final index = categoryGroups.indexWhere((e) => e.parent == parent);
    if (index == -1) return;

    final children = categoryGroups[index].children;

    if (!children.contains(subCategory)) {
      children.add(subCategory);
      categoryGroups.refresh();
    }
  }

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

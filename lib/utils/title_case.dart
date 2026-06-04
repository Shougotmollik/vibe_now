part of '../utils.dart';

String titleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map(
        (word) => word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : ''),
      )
      .join(' ');
}

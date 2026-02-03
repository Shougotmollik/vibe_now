import 'package:flutter/material.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class Interest {
  final String parent;

  final List<SubInterest> children;

  Interest({required this.parent, required this.children});
}

class SubInterest {
  final String name;
  final SvgGenImage icon;

  SubInterest({required this.name, required this.icon});
}

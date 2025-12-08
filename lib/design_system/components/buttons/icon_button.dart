import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;

  const AppIconButton({super.key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      color: AppColors.primary,
    );
  }
}

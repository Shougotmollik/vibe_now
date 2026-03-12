import 'package:flutter/material.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/design_system.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=1'),
      ),

      title: Text(
        'Jenny Smith',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),

      subtitle: Text(
        'Member',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),

      trailing: PopupMenuButton<String>(
        color: AppColors.background,
        icon: const Icon(Icons.more_horiz, color: Colors.grey),
        onSelected: (value) {
          print("Selected: $value");

          AppSnackbar.show(
            message: "You removed Jenny Smith from the event",
            type: SnackType.info,
          );
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Text(
              'Remove from event',
              style: TextStyle(color: AppColors.primaryVariant),
            ),
          ),
        ],
      ),
    );
  }
}

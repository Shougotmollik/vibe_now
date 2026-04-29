import 'package:flutter/material.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/views/common/member_confirmation_dialog.dart';

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
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),

      subtitle: Text(
        'Member',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
      ),

      trailing: PopupMenuButton<String>(
        color: Theme.of(context).colorScheme.surfaceVariant,
        icon: Icon(
          Icons.more_horiz,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        onSelected: (value) {
          showDialog(
            context: context,
            builder: (context) => MemberConfirmationDialog(
              confirmBtnText: "Remove",
              onCancel: () {
                Navigator.pop(context);
              },
              onConfirm: () {
                Navigator.pop(context);
              },
              title: "Give a reason for removing the  member",
            ),
          );
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Text(
              'Remove Member',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

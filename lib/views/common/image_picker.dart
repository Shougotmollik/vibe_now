import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePickerSheet extends StatelessWidget {
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromLibrary;
  final VoidCallback? onRemovePhoto;

  const ImagePickerSheet({
    super.key,
    required this.onTakePhoto,
    required this.onChooseFromLibrary,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Take Photo Option
          _buildOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () {
              Navigator.pop(context);
              onTakePhoto();
            },
          ),

          // Library Option
          _buildOption(
            icon: Icons.image_outlined,
            label: 'Choose from Library',
            onTap: () {
              Navigator.pop(context);
              onChooseFromLibrary();
            },
          ),

          // Remove Photo Option (Only shows if onRemovePhoto is provided)
          if (onRemovePhoto != null)
            _buildOption(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Photo',
              color: Colors.purpleAccent,
              onTap: () {
                Navigator.pop(context);
                onRemovePhoto!();
              },
            ),

          const Divider(height: 30, thickness: 1),

          // Cancel Button
          InkWell(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black54,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24.w),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

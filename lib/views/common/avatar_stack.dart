import 'package:flutter/material.dart';

class AvatarStack extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final int extraCount;

  const AvatarStack({
    super.key,
    required this.imageUrls,
    this.size = 40,
    this.extraCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: double.infinity,
      child: Stack(
        children: [
          for (int i = 0; i < imageUrls.length; i++)
            Positioned(
              left: i * (size * 0.65), // overlap amount
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: CircleAvatar(
                  radius: (size / 2) - 2,
                  backgroundImage: NetworkImage(imageUrls[i]),
                ),
              ),
            ),

          // Extra count
          if (extraCount > 0)
            Positioned(
              left: imageUrls.length * (size * 0.65),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

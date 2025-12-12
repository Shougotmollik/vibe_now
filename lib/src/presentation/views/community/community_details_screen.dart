import 'package:flutter/material.dart';

class CommunityDetailsScreen extends StatefulWidget {
  const CommunityDetailsScreen({super.key});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {
  double headerHeight = 280;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          setState(() {
            headerHeight = (280 - scroll.metrics.pixels).clamp(120, 280);
          });
          return false;
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SingleChildScrollView(child: Container(
              decoration: BoxDecoration(
                
              ),
              child: Column(
                
              ),
            )),
          ],
        ),
      ),
    );
  }
}

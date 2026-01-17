import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_search_bar.dart';
import 'package:vibe_now/src/presentation/views/community/widgets/community_card.dart';
import 'package:vibe_now/src/presentation/views/community/widgets/community_filter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> tabs = ['All', 'My Communities', 'Interested'];
  String selectedTab = 'All';

  final List<Community> allCommunities = [
    Community(
      name: "Coffee Meetup at Central Park",
      description: "Casual coffee and conversation in the park",
      location: "Central Park Cafe",
      distance: "0.3 km",
      dateTime: "Tomorrow at 3:00 PM",
      attending: "5",
      totalAttending: "10",
      image:
          'https://www.sbdcnet.org/wp-content/uploads/2020/07/chuttersnap-aEnH4hJ_Mrs-unsplash-e1594836312246.jpg',
      avatars: [
        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHBlb3BsZXxlbnwwfHwwfHx8MA%3D%3D",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      ],
      extraCount: 5,
      isMyCommunity: false,
      isJoined: false,
      isInterested: false,
      userStatus: CommunityStatus.request, // Request button with dropdown
    ),
    Community(
      name: "Morning Yoga Session",
      description: "Start your day with peaceful yoga",
      location: "Wellness Studio",
      distance: "1.2 km",
      dateTime: "Today at 7:00 AM",
      attending: "8",
      totalAttending: "15",
      image:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=687&auto=format&fit=crop",
      ],
      extraCount: 3,
      isMyCommunity: false,
      isJoined: false,
      isInterested: false,
      userStatus:
          CommunityStatus.requested, // Requested (grey button, no dropdown)
    ),
    Community(
      name: "Book Club Reading",
      description: "Monthly book discussion group",
      location: "City Library",
      distance: "0.8 km",
      dateTime: "Friday at 6:00 PM",
      attending: "12",
      totalAttending: "20",
      image:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop",
      ],
      extraCount: 8,
      isMyCommunity: false,
      isJoined: false,
      isInterested: false,
      userStatus: CommunityStatus.interested, // Interested with dropdown
    ),
    Community(
      name: "Tech Networking Event",
      description: "Connect with fellow tech enthusiasts",
      location: "Innovation Hub",
      distance: "2.5 km",
      dateTime: "Next Monday at 5:00 PM",
      attending: "25",
      totalAttending: "50",
      image:
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop",
      ],
      extraCount: 15,
      isMyCommunity: false,
      isJoined: false,
      isInterested: false,
      userStatus: CommunityStatus.going, // Going with dropdown
    ),
  ];

  final List<Community> myCommunities = [
    Community(
      name: "My Community Event",
      description: "Community I created",
      location: "My Place",
      distance: "0.5 km",
      dateTime: "Next Week",
      attending: "10",
      totalAttending: "20",
      image:
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop",
      ],
      extraCount: 7,
      isMyCommunity: true, // My community - shows "View Details"
      isJoined: false,
      isInterested: false,
    ),
  ];

  final List<Community> interestedCommunities = [
    Community(
      name: "Joined Book Club",
      description: "Book club I'm part of",
      location: "Library",
      distance: "1.0 km",
      dateTime: "Saturday 5PM",
      attending: "15",
      totalAttending: "25",
      image:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop",
      ],
      extraCount: 10,
      isMyCommunity: false,
      isJoined: true, // Joined - shows "View Details"
      isInterested: false,
    ),
    Community(
      name: "Art Gallery Tour",
      description: "Art tour I'm interested in",
      location: "Gallery",
      distance: "2.0 km",
      dateTime: "Sunday 3PM",
      attending: "8",
      totalAttending: "15",
      image:
          'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800&auto=format&fit=crop',
      avatars: [
        "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop",
      ],
      extraCount: 5,
      isMyCommunity: false,
      isJoined: false,
      isInterested: true, // Interested - shows "View Details"
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(context),
                SizedBox(height: 12),
                CustomSearchBar(
                  hintText: 'Search for communities',
                  onFilterTap: () => showDialog(
                    context: context,
                    builder: (context) => const CommunityFilterDialog(),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: tabs.map((tab) {
                    final isSelected = selectedTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTab = tab),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.w,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.primaryGradientRotated
                                : null,
                            color: isSelected ? null : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 14.h),
                if (selectedTab == 'All')
                  Column(
                    children: allCommunities
                        .map(
                          (c) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: CommunityCard(community: c),
                          ),
                        )
                        .toList(),
                  ),
                if (selectedTab == 'My Communities')
                  Column(
                    children: myCommunities
                        .map(
                          (c) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: CommunityCard(community: c),
                          ),
                        )
                        .toList(),
                  ),
                if (selectedTab == 'Interested')
                  Column(
                    children: interestedCommunities
                        .map(
                          (c) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: CommunityCard(community: c),
                          ),
                        )
                        .toList(),
                  ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildAppBar(BuildContext context) {
    return Row(
      children: [
        CustomAppBar(title: 'Community'),
        Spacer(),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.qrVerificationScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Assets.icons.scan.svg(),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.createCommunityScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradientRotated,
            ),
            child: Assets.icons.add.svg(),
          ),
        ),
      ],
    );
  }
}

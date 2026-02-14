import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_search_bar.dart';
import 'package:vibe_now/views/community/widgets/community_card.dart';
import 'package:vibe_now/views/community/widgets/community_filter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> tabs = ['All', 'Joined', 'Organized', 'Interested'];
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
        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop&q=60",
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=764&auto=format&fit=crop",
      ],
      extraCount: 5,
      isMyCommunity: false,
      isJoined: false,
      isInterested: false,
      userStatus: CommunityStatus.interested,
      accessType: CommunityAccessType.private,
      isFavorite: false,
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
      userStatus: CommunityStatus.interested,
      accessType: CommunityAccessType.public,
      isFavorite: false,
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
      isInterested: true,
      userStatus: CommunityStatus.interested,
      accessType: CommunityAccessType.public,
      isFavorite: false,
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
      isJoined: true,
      isInterested: false,
      userStatus: CommunityStatus.going,
      accessType: CommunityAccessType.private,
      isFavorite: true,
    ),
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
      isMyCommunity: true,
      isJoined: false,
      isInterested: false,
      userStatus: CommunityStatus.interested,
      accessType: CommunityAccessType.private,
      isFavorite: false,
    ),
  ];

  // Dynamic filtering based on selected tab
  List<Community> get filteredCommunities {
    switch (selectedTab) {
      case 'Joined':
        return allCommunities.where((c) => c.isJoined).toList();
      case 'Organized':
        return allCommunities.where((c) => c.isMyCommunity).toList();
      case 'Interested':
        return allCommunities.where((c) => c.isInterested).toList();
      case 'All':
      default:
        return allCommunities;
    }
  }

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

                // Horizontal tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                ),

                SizedBox(height: 14.h),

                // Filtered community list
                Column(
                  children: filteredCommunities
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
          onTap: () => context.pushNamed(
            RouteNames.qrVerificationScreen,
            extra: QRContext.community,
          ),
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

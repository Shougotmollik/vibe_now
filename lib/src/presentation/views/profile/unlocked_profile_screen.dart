import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class UnlockedProfileScreen extends StatefulWidget {
  const UnlockedProfileScreen({super.key});

  @override
  State<UnlockedProfileScreen> createState() => _UnlockedProfileScreenState();
}

class _UnlockedProfileScreenState extends State<UnlockedProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ['Photos', 'Posts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Column(
                children: [_buildAppBar(context), _buildProfileHeader()],
              ),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: tabs.map((e) => Tab(text: e)).toList(),
                dividerColor: Colors.transparent,
                automaticIndicatorColorAdjustment: true,
              ),
            ),
          ),
        ],
        body: TabBarView(
          physics: const BouncingScrollPhysics(),
          controller: _tabController,
          children: const [PhotosTab(), PostsTab()],
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight), // AppBar height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Assets.icons.chatting.svg(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -26,
              left: -6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text('Open for coffee'),
                  ),
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Assets.icons.dialogIcon.svg(
                      width: 24.h,
                      height: 24.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          'Jenny Gomes 23',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 16.h),
            const SizedBox(width: 4),
            Text('Approximate 400 km', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.coffeeColor.svg(),
            SizedBox(width: 4.w),
            Text(
              'Coffee enthusiast',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF908F90)),
            ),
            SizedBox(width: 8.w),
            Text('|', style: TextStyle(color: const Color(0xFF908F90))),
            SizedBox(width: 8.w),
            Assets.icons.musicColor.svg(),
            SizedBox(width: 4.w),
            Text(
              'Music lover',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF908F90)),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.h,
            runSpacing: 8.h,
            children: [
              _buildInterestTag(Assets.icons.iceCream, 'Ice-cream'),
              _buildInterestTag(Assets.icons.makeUpBrash, 'Make-up'),
              _buildInterestTag(Assets.icons.kitty, 'Pets'),
              _buildInterestTag(Assets.icons.filmWheel, 'Films'),
              _buildInterestTag(Assets.icons.coffee, 'Coffee'),
              _buildInterestTag(Assets.icons.gift, 'Gifts'),
            ],
          ),
        ),
        // SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildInterestTag(SvgGenImage icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(height: 16.h, width: 16.h),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}

/// Helper for SliverPersistentHeader
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF5F5F5), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class PhotosTab extends StatelessWidget {
  const PhotosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.h),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
            fit: BoxFit.cover,
            height: 300.h,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final List<bool> _isLiked = [false, true];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.h),
      itemCount: 2,
      itemBuilder: (context, index) {
        return PostItem(
          isLiked: _isLiked[index],
          onLikeTap: () {
            setState(() => _isLiked[index] = !_isLiked[index]);
          },
        );
      },
    );
  }
}

class PostItem extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostItem({super.key, required this.isLiked, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenny smith',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  Row(
                    children: [
                      Assets.icons.earth.svg(
                        width: 16,
                        height: 16,
                        color: Color(0xFF9D9D9D),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        ' 20 Oct',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D9D9D),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                spacing: 8.h,
                children: [
                  GestureDetector(
                    onTap: onLikeTap,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.likeScreen),
                    child: Text(
                      '100',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Anybody wants to have coffee?',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

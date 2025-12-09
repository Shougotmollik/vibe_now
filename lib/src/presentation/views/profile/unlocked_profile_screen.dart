import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class UnlockedProfileScreen extends StatefulWidget {
  const UnlockedProfileScreen({super.key});

  @override
  State<UnlockedProfileScreen> createState() => _UnlockedProfileScreenState();
}

class _UnlockedProfileScreenState extends State<UnlockedProfileScreen>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  String _selectedTab = 'Photos';

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = {'Photos': PhotosTab(), 'Posts': PostsTab()};
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {},
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

            // Profile Content
            Column(
              children: [
                // Profile Picture
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                          ),
                          fit: BoxFit.cover,
                        ),
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // child: const Icon(
                      //   Icons.person,
                      //   size: 60,
                      //   color: Colors.white,
                      // ),
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
                            child: Text('Open for coffee'),
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
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),

                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16.h),
                    SizedBox(width: 4),
                    Text(
                      'Approximate 400 km',
                      style: TextStyle(fontSize: 14.sp),
                    ),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF908F90),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF908F90),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    Assets.icons.musicColor.svg(),
                    SizedBox(width: 4.w),
                    Text(
                      'Music lover',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF908F90),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                // Interest Tags
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
                const SizedBox(height: 24),
              ],
            ),
            //-------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ...['Photos', 'Posts'].map(
                    (tab) => InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTab == tab
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(tab),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: children[_selectedTab] as Widget,
              ),
            ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: TabBarView(
            //       controller: _tabController,
            //       children: [const PhotosTab(), PostsTab()],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
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
          // Icon(icon, size: 18, color: Colors.grey.shade700),
          icon.svg(height: 16.h, width: 16.h),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class PhotosTab extends StatelessWidget {
  const PhotosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
            ),
            fit: BoxFit.cover,
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
      padding: EdgeInsets.only(top: 16.h),
      itemCount: 2,
      itemBuilder: (context, index) {
        return PostItem(
          isLiked: _isLiked[index],
          onLikeTap: () {
            setState(() {
              _isLiked[index] = !_isLiked[index];
            });
          },
        );
      },
    );
  }
}

class PostItem extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostItem({Key? key, required this.isLiked, required this.onLikeTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenny smith',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '20 Oct',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: onLikeTap,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '100',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Anybody wants to have coffee?',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

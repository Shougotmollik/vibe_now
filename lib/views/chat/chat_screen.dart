import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/controller/chat_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/chat/chat_list_item.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/widgets/notification_shimmer.dart';
import 'package:vibe_now/views/qr_verification/qr_verification_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatController _chatController = Get.find<ChatController>();

  int _selectedTabIndex = 0;
  static const _tabKeys = ['waves', 'private', 'event', 'community'];

  String _tabLabel(AppLocalizations loc, int index) {
    switch (index) {
      case 0: return loc.translate('waves');
      case 1: return loc.translate('private_tab');
      case 2: return loc.translate('event_tab');
      case 3: return loc.translate('community');
      default: return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _chatController.getWaves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    final tab = _tabKeys[index];
    if (tab == 'waves') {
      _chatController.getWaves();
    } else {
      _chatController.getChatList(type: tab);
    }
  }

  Future<void> _onRefresh() {
    final tab = _tabKeys[_selectedTabIndex];
    if (tab == 'waves') {
      return _chatController.getWaves();
    }
    return _chatController.getChatList(type: tab);
  }

  Future<void> _openChat(Chat chat) async {
    switch (chat.type) {
      case ChatType.event:
        await context.pushNamed(RouteNames.eventChatScreen, extra: chat);
        break;
      case ChatType.community:
        await context.pushNamed(RouteNames.communityChatScreen, extra: chat);
        break;
      case ChatType.private:
        await context.pushNamed(RouteNames.chatInboxScreen, extra: chat);
        break;
    }
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildHeader(loc),
              const SizedBox(height: 12),
              _buildSearchBar(loc),
              const SizedBox(height: 12),
              _buildTabBar(loc),
              const SizedBox(height: 12),
              Expanded(child: _buildTabContent(loc)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Row(
      children: [
        Text(
          loc.translate('chats'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.pushNamed(
            RouteNames.qrVerificationScreen,
            extra: QRContext.chats,
          ),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Assets.icons.scan.svg(
              width: 24.w,
              height: 24.h,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations loc) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: loc.translate('searchConversation'),
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20.sp,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: const Color(0xff9d9d9d)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xff9d9d9d)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xff9d9d9d)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  List<LinearGradient> get _tabGradients => [
    const LinearGradient(
      colors: [Color(0xFF8663F6), Color(0xFFC470F5), Color(0xFF57C2FF)],
      stops: [0.16, 0.54, 0.92],
    ),
    const LinearGradient(colors: [Color(0xfff5a0d6), Color(0xffd494f7)]),
    const LinearGradient(colors: [Color(0xfffbadd8), Color(0xffdeb5fe)]),
    const LinearGradient(colors: [Color(0xff99e2f1), Color(0xffaaccff)]),
  ];

  List<Widget> get _tabIcons => [
    Assets.icons.handWave.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
    Assets.icons.chatting.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
    Assets.icons.calendarColor.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
    Assets.icons.communityColor.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
  ];

  Widget _buildTabBar(AppLocalizations loc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabKeys.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onTabChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                decoration: BoxDecoration(
                  gradient: isSelected ? _tabGradients[index] : null,
                  color: isSelected
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.15),
                          width: 1,
                        ),
                ),
                child: Row(
                  spacing: 6.w,
                  children: [
                    isSelected ? _tabIcons[index] : const SizedBox.shrink(),
                    Text(
                      _tabLabel(loc, index),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black87
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(AppLocalizations loc) {
    final tab = _tabKeys[_selectedTabIndex];
    if (tab == 'waves') return _buildWavesTab(loc);
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Obx(() {
        final list = _chatController.chatsForTab(tab);
        final isLoading = _chatController.isLoadingTab(tab) && list.isEmpty;

        if (isLoading) {
          return const NotificationShimmer();
        }

        if (list.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Text(
                  _emptyMessage(tab, loc),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          itemBuilder: (context, index) => ChatListItem(
            chat: list[index],
            onTap: () => _openChat(list[index]),
          ),
        );
      }),
    );
  }

  Widget _buildWavesTab(AppLocalizations loc) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Obx(() {
        final list = _chatController.incomingWaves;
        final isLoading = _chatController.isLoadingTab('waves') && list.isEmpty;

        if (isLoading) {
          return const NotificationShimmer();
        }

        if (list.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Text(
                  _emptyMessage('waves', loc),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          itemBuilder: (context, index) => _buildWaveItem(list[index], loc),
        );
      }),
    );
  }

  Widget _buildWaveItem(IncomingWave wave, AppLocalizations loc) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        final chat = Chat(
          id: wave.waveId.toString(),
          name: wave.sender.fullName,
          message: wave.vibe.title,
          avatars: [wave.sender.avatar],
        );
        context.pushNamed(RouteNames.waveScreen, extra: chat);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: CachedNetworkImage(
                imageUrl: AppCredentials.fixurl(wave.sender.avatar),
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 50.w,
                  height: 50.w,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wave.sender.fullName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Assets.icons.handWave.svg(
                        width: 14.w,
                        height: 14.h,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${loc.translate('wavedAt')} ${wave.vibe.title}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: wave.status == 'pending'
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                wave.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: wave.status == 'pending'
                      ? AppColors.primary
                      : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _emptyMessage(String tab, AppLocalizations loc) {
    switch (tab) {
      case 'waves':
        return loc.translate('noVibes');
      case 'private':
        return loc.translate('noMessages');
      case 'event':
        return loc.translate('noMessages');
      case 'community':
        return loc.translate('noMessages');
      default:
        return loc.translate('noMessages');
    }
  }
}

class CommunityAvatar extends StatelessWidget {
  final List<String> avatars;
  final double size;

  const CommunityAvatar({super.key, required this.avatars, this.size = 50});

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return _fallback(context);
    }

    if (avatars.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: AppCredentials.fixurl(avatars.first),
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
          placeholder: (_, __) => _fallback(context),
          errorWidget: (_, __, ___) => _fallback(context),
        ),
      );
    }

    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: CachedNetworkImage(
                imageUrl: AppCredentials.fixurl(avatars[0]),
                width: (size * 0.8).w,
                height: (size * 0.8).w,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallback(context),
                errorWidget: (_, __, ___) => _fallback(context),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size / 2),
                child: CachedNetworkImage(
                  imageUrl: AppCredentials.fixurl(avatars[1]),
                  width: (size * 0.7).w,
                  height: (size * 0.7).w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _fallback(context),
                  errorWidget: (_, __, ___) => _fallback(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.group,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: (size * 0.4).w,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/message_model.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.honeycombMedium),
            ),
          );
        }

        if (controller.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.accentGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet'.tr,
                  style: AppText.h3.copyWith(color: AppColors.accentGrey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your messages will appear here'.tr,
                  style: AppText.body1.copyWith(color: AppColors.accentGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadUserChats,
          color: AppColors.honeycombMedium,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = controller.chats[index];
              return _buildChatItem(context, chat);
            },
          ),
        );
      }),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel chat) {
    final String currentUserId =
        Get.find<AuthController>().firebaseUser.value?.uid ?? '';
    final String otherUserName = chat.getChatNameForUser(currentUserId);
    final String? otherUserAvatar = chat.getChatAvatarForUser(currentUserId);
    final bool hasUnread = chat.hasUnreadMessages(currentUserId);
    final int unreadCount = chat.getUnreadCountForUser(currentUserId);
    final bool isLastMessageFromCurrentUser =
        chat.lastMessageSenderId == currentUserId;

    // Determine the other user's ID
    String otherUserId = '';
    for (String userId in chat.participants) {
      if (userId != currentUserId) {
        otherUserId = userId;
        break;
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.accentLightGrey,
        backgroundImage:
            otherUserAvatar != null ? NetworkImage(otherUserAvatar) : null,
        child: otherUserAvatar == null
            ? Text(
                otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                style: AppText.h3,
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUserName,
              style: AppText.body1.copyWith(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTimestamp(chat.lastMessageTime),
            style: AppText.caption.copyWith(
              color: hasUnread ? AppColors.honeycombDark : AppColors.accentGrey,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromCurrentUser)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.done_all,
                size: 16,
                color: AppColors.accentGrey,
              ),
            ),
          Expanded(
            child: Text(
              chat.lastMessageText.isEmpty
                  ? 'Start a conversation'.tr
                  : chat.lastMessageText,
              style: AppText.body2.copyWith(
                color: hasUnread ? AppColors.accentBlack : AppColors.accentGrey,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.honeycombDark,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: AppText.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to chat detail
        Get.toNamed(
          Routes.CHAT_DETAIL,
          arguments: {
            'otherUserId': otherUserId,
            'chatId': chat.id,
            'campaignId': chat.campaignId,
            'campaignName': chat.campaignName,
          },
        );
      },
    );
  }

  // Helper to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      // Today, show time
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday'.tr;
    } else if (now.difference(timestamp).inDays < 7) {
      // Within a week, show day name
      return _getDayName(timestamp.weekday);
    } else {
      // Older messages, show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Helper to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday'.tr;
      case 2:
        return 'Tuesday'.tr;
      case 3:
        return 'Wednesday'.tr;
      case 4:
        return 'Thursday'.tr;
      case 5:
        return 'Friday'.tr;
      case 6:
        return 'Saturday'.tr;
      case 7:
        return 'Sunday'.tr;
      default:
        return '';
    }
  }
}

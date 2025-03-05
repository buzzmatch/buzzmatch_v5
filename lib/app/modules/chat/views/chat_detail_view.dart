import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../data/models/message_model.dart';

class ChatDetailView extends GetView<ChatController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    final String otherUserId = args['otherUserId'] as String;
    final String? chatId = args['chatId'] as String?;
    final String? campaignId = args['campaignId'] as String?;
    final String? campaignName = args['campaignName'] as String?;

    // Open chat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (chatId != null && chatId.isNotEmpty) {
        controller.chatId.value = chatId;
        controller.otherUserId.value = otherUserId;
        await controller.loadMessages();
        controller.setupMessageListener();
      } else {
        bool success = await controller.openChat(
          otherUserId,
          campaignId: campaignId,
          campaignName: campaignName,
        );
        if (success) {
          controller.setupMessageListener();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.accentLightGrey,
                  child: Text(
                    controller.otherUserName.isNotEmpty
                        ? controller.otherUserName.value[0].toUpperCase()
                        : '?',
                    style: AppText.body2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.otherUserName.value,
                        style: AppText.body1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (controller.campaignName.isNotEmpty)
                        Text(
                          controller.campaignName.value,
                          style: AppText.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show chat info
              _showChatInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campaign info banner (if this chat is related to a campaign)
          Obx(() {
            if (controller.campaignName.isNotEmpty) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primaryYellow.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.campaign_outlined,
                      color: AppColors.honeycombDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'Campaign'.tr}: ${controller.campaignName.value}',
                        style: AppText.body2.copyWith(
                          color: AppColors.honeycombDark,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to campaign details
                        if (controller.campaignId.isNotEmpty) {
                          Get.toNamed(
                            '/campaign-detail',
                            arguments: {
                              'campaignId': controller.campaignId.value
                            },
                          );
                        }
                      },
                      child: Text('View'.tr),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.honeycombMedium),
                  ),
                );
              }

              if (controller.messages.isEmpty) {
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
                        'Start a conversation'.tr,
                        style:
                            AppText.body1.copyWith(color: AppColors.accentGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                controller: controller.scrollController,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final bool isCurrentUser = message.senderId ==
                      Get.find<AuthController>().firebaseUser.value?.uid;

                  // Group messages by date
                  final bool showDateHeader = index == 0 ||
                      !_isSameDay(
                        controller.messages[index].timestamp,
                        controller.messages[index - 1].timestamp,
                      );

                  return Column(
                    children: [
                      if (showDateHeader) _buildDateHeader(message.timestamp),
                      _buildMessageItem(context, message, isCurrentUser),
                    ],
                  );
                },
              );
            }),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: AppColors.accentGrey,
                  onPressed: () {
                    _showAttachmentOptions(context);
                  },
                ),

                // Message input field
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.accentLightGrey.withOpacity(0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendTextMessage(),
                    maxLines: null,
                  ),
                ),

                // Send button
                Obx(() => IconButton(
                      icon: controller.isSending.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.honeycombDark,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                      color: AppColors.honeycombDark,
                      onPressed: controller.isSending.value
                          ? null
                          : controller.sendTextMessage,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build date header
  Widget _buildDateHeader(DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDateHeader(timestamp),
              style: AppText.caption.copyWith(
                color: AppColors.accentGrey,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  // Build message item
  Widget _buildMessageItem(
      BuildContext context, MessageModel message, bool isCurrentUser) {
    // Default message container styles
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isCurrentUser ? const Radius.circular(16) : Radius.zero,
      bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(16),
    );

    final bgColor = isCurrentUser ? AppColors.honeycombMedium : Colors.white;

    final textColor = isCurrentUser ? Colors.white : AppColors.accentBlack;

    final alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    Widget messageContent;

    // Handle different message types
    switch (message.type) {
      case MessageType.image:
        messageContent = _buildImageMessage(message, isCurrentUser);
        break;
      case MessageType.file:
        messageContent = _buildFileMessage(message, isCurrentUser);
        break;
      case MessageType.statusUpdate:
        return _buildStatusMessage(message);
      default:
        messageContent = _buildTextMessage(message, textColor);
    }

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender name (only show for other user)
              if (!isCurrentUser && message.senderName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.senderName!,
                    style: AppText.caption.copyWith(
                      color: isCurrentUser
                          ? Colors.white70
                          : AppColors.honeycombDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Message content
              messageContent,

              // Timestamp
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: AppText.caption.copyWith(
                      color:
                          isCurrentUser ? Colors.white70 : AppColors.accentGrey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build text message
  Widget _buildTextMessage(MessageModel message, Color textColor) {
    return Text(
      message.content,
      style: AppText.body2.copyWith(color: textColor),
    );
  }

  // Build image message
  Widget _buildImageMessage(MessageModel message, bool isCurrentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.content != 'Image')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              message.content,
              style: AppText.body2.copyWith(
                color: isCurrentUser ? Colors.white : AppColors.accentBlack,
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            // Show full-screen image
            Get.to(() => Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  backgroundColor: Colors.black,
                  body: Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Image.network(
                        message.fileUrl!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.fileUrl!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser ? Colors.white : AppColors.honeycombDark,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: AppColors.accentLightGrey,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color:
                          isCurrentUser ? Colors.white : AppColors.accentGrey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build file message
  Widget _buildFileMessage(MessageModel message, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.white24 : AppColors.accentLightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: isCurrentUser ? Colors.white : AppColors.accentGrey,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: AppText.body2.copyWith(
                    color: isCurrentUser ? Colors.white : AppColors.accentBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to download',
                  style: AppText.caption.copyWith(
                    color:
                        isCurrentUser ? Colors.white70 : AppColors.accentGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build status update message
  Widget _buildStatusMessage(MessageModel message) {
    final String status = message.metadata?['status'] ?? '';

    Color statusColor;
    IconData statusIcon;

    // Determine color and icon based on status
    switch (status.toLowerCase()) {
      case 'matched':
        statusColor = AppColors.statusMatched;
        statusIcon = Icons.handshake_outlined;
        break;
      case 'contractsigned':
        statusColor = AppColors.statusContractSigned;
        statusIcon = Icons.description_outlined;
        break;
      case 'productshipped':
        statusColor = AppColors.statusShipped;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'contentinprogress':
        statusColor = AppColors.statusInProgress;
        statusIcon = Icons.pending_outlined;
        break;
      case 'submitted':
        statusColor = AppColors.statusSubmitted;
        statusIcon = Icons.upload_outlined;
        break;
      case 'revision':
        statusColor = AppColors.statusRevision;
        statusIcon = Icons.loop_outlined;
        break;
      case 'approved':
        statusColor = AppColors.statusApproved;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'paymentreleased':
        statusColor = AppColors.statusPaymentReleased;
        statusIcon = Icons.payments_outlined;
        break;
      case 'completed':
        statusColor = AppColors.statusCompleted;
        statusIcon = Icons.task_alt_outlined;
        break;
      default:
        statusColor = AppColors.accentGrey;
        statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: AppColors.accentLightGrey,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  message.content,
                  style: AppText.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Divider(
              color: AppColors.accentLightGrey,
            ),
          ),
        ],
      ),
    );
  }

  // Show chat info dialog
  void _showChatInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.accentLightGrey,
                child: Text(
                  controller.otherUserName.value.isNotEmpty
                      ? controller.otherUserName.value[0].toUpperCase()
                      : '?',
                  style: AppText.h2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.otherUserName.value,
                style: AppText.h3,
              ),
              const SizedBox(height: 8),
              if (controller.campaignName.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Campaign'.tr,
                  style: AppText.caption.copyWith(
                    color: AppColors.accentGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.campaignName.value,
                  style: AppText.body1,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    // Navigate to campaign detail
                    if (controller.campaignId.isNotEmpty) {
                      Get.toNamed(
                        '/campaign-detail',
                        arguments: {'campaignId': controller.campaignId.value},
                      );
                    }
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text('View Campaign'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.honeycombDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Show attachment options
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Share Attachment'.tr,
                style: AppText.h3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Image option
                  _buildAttachmentOption(
                    context,
                    Icons.image,
                    'Image'.tr,
                    AppColors.honeycombMedium,
                    () {
                      Get.back();
                      controller.sendImageMessage();
                    },
                  ),

                  // Document option
                  _buildAttachmentOption(
                    context,
                    Icons.insert_drive_file,
                    'Document'.tr,
                    AppColors.honeycombDark,
                    () {
                      Get.back();
                      controller.sendFileMessage();
                    },
                  ),

                  // Status update option
                  if (controller.campaignId.isNotEmpty)
                    _buildAttachmentOption(
                      context,
                      Icons.update,
                      'Status'.tr,
                      AppColors.primaryOrange,
                      () {
                        Get.back();
                        _showStatusUpdateDialog(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Build attachment option item
  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.body2,
          ),
        ],
      ),
    );
  }

  // Show status update dialog
  void _showStatusUpdateDialog(BuildContext context) {
    final List<String> statusOptions = [
      'Matched',
      'Contract Signed',
      'Product Shipped',
      'Content In Progress',
      'Submitted',
      'Revision',
      'Approved',
      'Payment Released',
      'Completed',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Update Status'.tr,
                style: AppText.h3,
              ),
              const SizedBox(height: 16),
              Text(
                'Select the new status for this campaign'.tr,
                style: AppText.body2.copyWith(
                  color: AppColors.accentGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: statusOptions.length,
                  itemBuilder: (context, index) {
                    final status = statusOptions[index];
                    Color statusColor;

                    // Determine color based on status
                    switch (index) {
                      case 0:
                        statusColor = AppColors.statusMatched;
                        break;
                      case 1:
                        statusColor = AppColors.statusContractSigned;
                        break;
                      case 2:
                        statusColor = AppColors.statusShipped;
                        break;
                      case 3:
                        statusColor = AppColors.statusInProgress;
                        break;
                      case 4:
                        statusColor = AppColors.statusSubmitted;
                        break;
                      case 5:
                        statusColor = AppColors.statusRevision;
                        break;
                      case 6:
                        statusColor = AppColors.statusApproved;
                        break;
                      case 7:
                        statusColor = AppColors.statusPaymentReleased;
                        break;
                      case 8:
                        statusColor = AppColors.statusCompleted;
                        break;
                      default:
                        statusColor = AppColors.accentGrey;
                    }

                    return ListTile(
                      title: Text(
                        status.tr,
                        style: AppText.body1,
                      ),
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () {
                        Get.back();
                        // Send status update
                        controller.sendStatusUpdateMessage(
                          status.replaceAll(' ', '').toLowerCase(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to format message time
  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to format date header
  String _formatDateHeader(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return 'Today'.tr;
    } else if (messageDate == yesterday) {
      return 'Yesterday'.tr;
    } else if (now.difference(timestamp).inDays < 7) {
      return _getDayName(timestamp.weekday);
    } else {
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

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

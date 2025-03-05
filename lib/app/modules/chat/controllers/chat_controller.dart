import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/message_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../authentication/controllers/auth_controller.dart';

class ChatController extends GetxController {
  // Firebase service
  final FirebaseService _firebaseService = FirebaseService.to;

  // Auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Chat and message data
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<ChatModel> chats = <ChatModel>[].obs;

  // Current chat details
  final Rx<ChatModel?> currentChat = Rx<ChatModel?>(null);
  final RxString chatId = ''.obs;
  final RxString otherUserId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxString campaignId = ''.obs;
  final RxString campaignName = ''.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  // Message input controller
  late TextEditingController messageController;

  // Scroll controller for message list
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    scrollController = ScrollController();

    // Load user chats
    loadUserChats();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Load user chats
  Future<void> loadUserChats() async {
    if (_authController.firebaseUser.value != null) {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        List<ChatModel> userChats = await _firebaseService.getUserChats(userId);
        chats.value = userChats;
      } catch (e) {
        print('Error loading user chats: $e');
        Get.snackbar(
          'Error',
          'Failed to load chats',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Open chat with another user
  Future<bool> openChat(String otherUserId,
      {String? campaignId, String? campaignName}) async {
    if (_authController.firebaseUser.value != null) {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        // Get or create chat
        String chatRoomId = await _firebaseService.getOrCreateChat(
          userId,
          otherUserId,
          campaignId: campaignId,
          campaignName: campaignName,
        );

        // Set current chat details
        chatId.value = chatRoomId;
        this.otherUserId.value = otherUserId;

        // Load chat details
        DocumentSnapshot chatDoc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatRoomId)
            .get();

        if (chatDoc.exists) {
          ChatModel chat = ChatModel.fromFirestore(chatDoc);
          currentChat.value = chat;

          // Set other user name
          otherUserName.value = chat.getChatNameForUser(userId);

          // Set campaign details if available
          if (chat.campaignId != null) {
            this.campaignId.value = chat.campaignId!;
          }
          if (chat.campaignName != null) {
            this.campaignName.value = chat.campaignName!;
          }

          // Load messages
          await loadMessages();

          // Mark chat as read
          await _firebaseService.markChatAsRead(chatRoomId, userId);

          isLoading.value = false;
          return true;
        }

        isLoading.value = false;
        return false;
      } catch (e) {
        print('Error opening chat: $e');
        Get.snackbar(
          'Error',
          'Failed to open chat',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return false;
      }
    }
    return false;
  }

  // Load messages for current chat
  Future<void> loadMessages() async {
    if (chatId.value.isNotEmpty) {
      try {
        // Get messages from Firestore
        List<MessageModel> chatMessages =
            await _firebaseService.getChatMessages(chatId.value);

        // Sort messages by timestamp (oldest to newest)
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        messages.value = chatMessages;

        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        print('Error loading messages: $e');
      }
    }
  }

  // Send text message
  Future<void> sendTextMessage() async {
    if (messageController.text.trim().isEmpty || chatId.value.isEmpty) {
      return;
    }

    if (_authController.firebaseUser.value != null) {
      isSending.value = true;
      String userId = _authController.firebaseUser.value!.uid;
      String userName = _authController.userRole.value == 'brand'
          ? _authController.currentUser.value?.companyName ?? 'Brand'
          : _authController.currentUser.value?.fullName ?? 'Creator';

      try {
        // Create message model
        MessageModel message = MessageModel.text(
          chatId: chatId.value,
          senderId: userId,
          senderName: userName,
          senderAvatar: _authController.currentUser.value?.profileImageUrl,
          content: messageController.text.trim(),
        );

        // Send message
        await _firebaseService.sendMessage(message);

        // Clear input field
        messageController.clear();

        // Reload messages
        await loadMessages();

        isSending.value = false;
      } catch (e) {
        print('Error sending message: $e');
        Get.snackbar(
          'Error',
          'Failed to send message',
          snackPosition: SnackPosition.BOTTOM,
        );
        isSending.value = false;
      }
    }
  }

  // Send image message
  Future<void> sendImageMessage() async {
    if (_authController.firebaseUser.value != null && chatId.value.isNotEmpty) {
      try {
        // Pick image
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );

        if (image != null) {
          isSending.value = true;
          String userId = _authController.firebaseUser.value!.uid;
          String userName = _authController.userRole.value == 'brand'
              ? _authController.currentUser.value?.companyName ?? 'Brand'
              : _authController.currentUser.value?.fullName ?? 'Creator';

          // Upload image to Firebase Storage
          String imageUrl = await _uploadImage(File(image.path));

          // Create message model
          MessageModel message = MessageModel.image(
            chatId: chatId.value,
            senderId: userId,
            senderName: userName,
            senderAvatar: _authController.currentUser.value?.profileImageUrl,
            content: 'Image',
            imageUrl: imageUrl,
            thumbnailUrl: imageUrl, // Use same URL for thumbnail for simplicity
          );

          // Send message
          await _firebaseService.sendMessage(message);

          // Reload messages
          await loadMessages();
        }
      } catch (e) {
        print('Error sending image message: $e');
        Get.snackbar(
          'Error',
          'Failed to send image',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isSending.value = false;
      }
    }
  }

  // Send file message
  Future<void> sendFileMessage() async {
    if (_authController.firebaseUser.value != null && chatId.value.isNotEmpty) {
      try {
        // TODO: Implement file picking and uploading
        Get.snackbar(
          'Coming Soon',
          'File sharing will be available in the next update',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        print('Error sending file message: $e');
        Get.snackbar(
          'Error',
          'Failed to send file',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Send status update message
  Future<void> sendStatusUpdateMessage(String status,
      {String? additionalInfo}) async {
    if (_authController.firebaseUser.value != null && chatId.value.isNotEmpty) {
      isSending.value = true;
      String userId = _authController.firebaseUser.value!.uid;
      String userName = _authController.userRole.value == 'brand'
          ? _authController.currentUser.value?.companyName ?? 'Brand'
          : _authController.currentUser.value?.fullName ?? 'Creator';

      try {
        // Create status data
        Map<String, dynamic> statusData = {
          'status': status,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'campaignId': campaignId.value,
          'additionalInfo': additionalInfo,
        };

        // Create message model
        MessageModel message = MessageModel.statusUpdate(
          chatId: chatId.value,
          senderId: userId,
          senderName: userName,
          senderAvatar: _authController.currentUser.value?.profileImageUrl,
          content: 'Status updated to: $status',
          statusData: statusData,
        );

        // Send message
        await _firebaseService.sendMessage(message);

        // Reload messages
        await loadMessages();

        isSending.value = false;
      } catch (e) {
        print('Error sending status update: $e');
        Get.snackbar(
          'Error',
          'Failed to send status update',
          snackPosition: SnackPosition.BOTTOM,
        );
        isSending.value = false;
      }
    }
  }

  // Helper method to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile) async {
    try {
      String chatPath = 'chats/$chatId.value/images';
      return await _firebaseService.uploadImage(imageFile, chatPath);
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Set up real-time message listener
  void setupMessageListener() {
    if (chatId.value.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('messages')
          .where('chatId', isEqualTo: chatId.value)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        List<MessageModel> updatedMessages = snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();

        messages.value = updatedMessages;

        // Mark chat as read
        if (_authController.firebaseUser.value != null) {
          _firebaseService.markChatAsRead(
            chatId.value,
            _authController.firebaseUser.value!.uid,
          );
        }

        // Scroll to bottom if new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }
  }

  // Get unread message count for a specific chat
  int getUnreadCount(String chatId) {
    if (_authController.firebaseUser.value != null) {
      String userId = _authController.firebaseUser.value!.uid;

      ChatModel? chat = chats.firstWhereOrNull((c) => c.id == chatId);
      if (chat != null) {
        return chat.getUnreadCountForUser(userId);
      }
    }
    return 0;
  }

  // Get total unread message count across all chats
  int get totalUnreadCount {
    if (_authController.firebaseUser.value != null) {
      String userId = _authController.firebaseUser.value!.uid;

      int count = 0;
      for (var chat in chats) {
        count += chat.getUnreadCountForUser(userId);
      }
      return count;
    }
    return 0;
  }
}

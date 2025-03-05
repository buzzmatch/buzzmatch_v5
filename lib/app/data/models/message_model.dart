import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  file,
  contract,
  payment,
  statusUpdate,
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? fileUrl;
  final String? fileName;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.fileUrl,
    this.fileName,
    this.thumbnailUrl,
    this.metadata,
  });

  // Convert Firestore document to MessageModel
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse message type
    MessageType messageType;
    switch (data['type']) {
      case 'text':
        messageType = MessageType.text;
        break;
      case 'image':
        messageType = MessageType.image;
        break;
      case 'video':
        messageType = MessageType.video;
        break;
      case 'file':
        messageType = MessageType.file;
        break;
      case 'contract':
        messageType = MessageType.contract;
        break;
      case 'payment':
        messageType = MessageType.payment;
        break;
      case 'statusUpdate':
        messageType = MessageType.statusUpdate;
        break;
      default:
        messageType = MessageType.text;
    }

    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'],
      senderAvatar: data['senderAvatar'],
      content: data['content'] ?? '',
      type: messageType,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      thumbnailUrl: data['thumbnailUrl'],
      metadata: data['metadata'],
    );
  }

  // Convert MessageModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert message type to string
    String typeString;
    switch (type) {
      case MessageType.text:
        typeString = 'text';
        break;
      case MessageType.image:
        typeString = 'image';
        break;
      case MessageType.video:
        typeString = 'video';
        break;
      case MessageType.file:
        typeString = 'file';
        break;
      case MessageType.contract:
        typeString = 'contract';
        break;
      case MessageType.payment:
        typeString = 'payment';
        break;
      case MessageType.statusUpdate:
        typeString = 'statusUpdate';
        break;
    }

    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': typeString,
      'timestamp': timestamp,
      'isRead': isRead,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
    };
  }

  // Create a copy of MessageModel with updated fields
  MessageModel copyWith({
    String? content,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      fileUrl: fileUrl,
      fileName: fileName,
      thumbnailUrl: thumbnailUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  // Factory method to create a text message
  factory MessageModel.text({
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderAvatar,
    required String content,
  }) {
    return MessageModel(
      id: '', // Will be set by Firestore
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  // Factory method to create an image message
  factory MessageModel.image({
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderAvatar,
    required String content,
    required String imageUrl,
    String? thumbnailUrl,
  }) {
    return MessageModel(
      id: '', // Will be set by Firestore
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      type: MessageType.image,
      timestamp: DateTime.now(),
      isRead: false,
      fileUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }

  // Factory method to create a file message
  factory MessageModel.file({
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderAvatar,
    required String content,
    required String fileUrl,
    required String fileName,
  }) {
    return MessageModel(
      id: '', // Will be set by Firestore
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      type: MessageType.file,
      timestamp: DateTime.now(),
      isRead: false,
      fileUrl: fileUrl,
      fileName: fileName,
    );
  }

  // Factory method to create a status update message
  factory MessageModel.statusUpdate({
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderAvatar,
    required String content,
    required Map<String, dynamic> statusData,
  }) {
    return MessageModel(
      id: '', // Will be set by Firestore
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      type: MessageType.statusUpdate,
      timestamp: DateTime.now(),
      isRead: false,
      metadata: statusData,
    );
  }
}

// Chat model for representing chat rooms
class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantAvatars;
  final DateTime createdAt;
  final DateTime lastMessageTime;
  final String lastMessageText;
  final String lastMessageSenderId;
  final Map<String, int> unreadCount;
  final String? campaignId;
  final String? campaignName;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantAvatars,
    required this.createdAt,
    required this.lastMessageTime,
    required this.lastMessageText,
    required this.lastMessageSenderId,
    required this.unreadCount,
    this.campaignId,
    this.campaignName,
  });

  // Convert Firestore document to ChatModel
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse participants
    List<String> participants = [];
    if (data['participants'] != null) {
      participants = List<String>.from(data['participants']);
    }

    // Parse participant names
    Map<String, String> participantNames = {};
    if (data['participantNames'] != null) {
      Map<String, dynamic> names = data['participantNames'];
      names.forEach((key, value) {
        participantNames[key] = value.toString();
      });
    }

    // Parse participant avatars
    Map<String, String> participantAvatars = {};
    if (data['participantAvatars'] != null) {
      Map<String, dynamic> avatars = data['participantAvatars'];
      avatars.forEach((key, value) {
        if (value != null) {
          participantAvatars[key] = value.toString();
        }
      });
    }

    // Parse unread count
    Map<String, int> unreadCount = {};
    if (data['unreadCount'] != null) {
      Map<String, dynamic> counts = data['unreadCount'];
      counts.forEach((key, value) {
        unreadCount[key] = (value as num).toInt();
      });
    }

    return ChatModel(
      id: doc.id,
      participants: participants,
      participantNames: participantNames,
      participantAvatars: participantAvatars,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageText: data['lastMessageText'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      unreadCount: unreadCount,
      campaignId: data['campaignId'],
      campaignName: data['campaignName'],
    );
  }

  // Convert ChatModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'createdAt': createdAt,
      'lastMessageTime': lastMessageTime,
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'campaignId': campaignId,
      'campaignName': campaignName,
    };
  }

  // Create a copy of ChatModel with updated fields
  ChatModel copyWith({
    List<String>? participants,
    Map<String, String>? participantNames,
    Map<String, String>? participantAvatars,
    DateTime? lastMessageTime,
    String? lastMessageText,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    String? campaignId,
    String? campaignName,
  }) {
    return ChatModel(
      id: id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      createdAt: createdAt,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
    );
  }

  // Update last message
  ChatModel updateLastMessage({
    required String text,
    required String senderId,
    required DateTime timestamp,
  }) {
    // Update unread count for all participants except sender
    Map<String, int> newUnreadCount = Map.from(unreadCount);
    for (String participant in participants) {
      if (participant != senderId) {
        newUnreadCount[participant] = (newUnreadCount[participant] ?? 0) + 1;
      }
    }

    return copyWith(
      lastMessageText: text,
      lastMessageSenderId: senderId,
      lastMessageTime: timestamp,
      unreadCount: newUnreadCount,
    );
  }

  // Mark as read for a user
  ChatModel markAsReadForUser(String userId) {
    Map<String, int> newUnreadCount = Map.from(unreadCount);
    newUnreadCount[userId] = 0;

    return copyWith(unreadCount: newUnreadCount);
  }

  // Get chat name for a user (returns other participant's name)
  String getChatNameForUser(String userId) {
    for (String participant in participants) {
      if (participant != userId) {
        return participantNames[participant] ?? 'Unknown';
      }
    }
    return 'Chat';
  }

  // Get avatar for a user (returns other participant's avatar)
  String? getChatAvatarForUser(String userId) {
    for (String participant in participants) {
      if (participant != userId) {
        return participantAvatars[participant];
      }
    }
    return null;
  }

  // Check if a user has unread messages
  bool hasUnreadMessages(String userId) {
    return (unreadCount[userId] ?? 0) > 0;
  }

  // Get unread count for a user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }
}

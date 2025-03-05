import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/campaign_model.dart';
import '../models/message_model.dart';
import '../models/transaction_model.dart';

class FirebaseService extends GetxService {
  static FirebaseService get to => Get.find<FirebaseService>();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UUID generator
  final Uuid _uuid = const Uuid();

  // Initialize service
  Future<FirebaseService> init() async {
    return this;
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user model: $e');
      return null;
    }
  }

  // Create or update user model in Firestore
  Future<void> saveUserModel(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving user model: $e');
      rethrow;
    }
  }

  // Get campaign by ID
  Future<CampaignModel?> getCampaign(String campaignId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('campaigns').doc(campaignId).get();
      if (doc.exists) {
        return CampaignModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting campaign: $e');
      return null;
    }
  }

  // Create new campaign
  Future<String> createCampaign(CampaignModel campaign) async {
    try {
      DocumentReference docRef = await _firestore.collection('campaigns').add(
            campaign.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      print('Error creating campaign: $e');
      rethrow;
    }
  }

  // Update campaign
  Future<void> updateCampaign(CampaignModel campaign) async {
    try {
      await _firestore.collection('campaigns').doc(campaign.id).update(
            campaign.toFirestore(),
          );
    } catch (e) {
      print('Error updating campaign: $e');
      rethrow;
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      String fileName = '${_uuid.v4()}.jpg';
      Reference storageRef = _storage.ref().child('$path/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // Get user wallet
  Future<WalletModel?> getUserWallet(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('wallets').doc(userId).get();
      if (doc.exists) {
        return WalletModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user wallet: $e');
      return null;
    }
  }

  // Create or update wallet
  Future<void> saveWallet(WalletModel wallet) async {
    try {
      await _firestore.collection('wallets').doc(wallet.id).set(
            wallet.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving wallet: $e');
      rethrow;
    }
  }

  // Create transaction
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('transactions').add(
                transaction.toFirestore(),
              );
      return docRef.id;
    } catch (e) {
      print('Error creating transaction: $e');
      rethrow;
    }
  }

  // Get transactions for user
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user transactions: $e');
      return [];
    }
  }

  // Get or create chat between users
  Future<String> getOrCreateChat(String userId1, String userId2,
      {String? campaignId, String? campaignName}) async {
    try {
      // Sort user IDs for consistent ordering
      List<String> participants = [userId1, userId2]..sort();

      // Check if chat already exists
      QuerySnapshot existingChats = await _firestore
          .collection('chats')
          .where('participants', isEqualTo: participants)
          .limit(1)
          .get();

      if (existingChats.docs.isNotEmpty) {
        return existingChats.docs.first.id;
      }

      // Create new chat
      UserModel? user1 = await getUserModel(userId1);
      UserModel? user2 = await getUserModel(userId2);

      if (user1 == null || user2 == null) {
        throw Exception('One or both users not found');
      }

      Map<String, String> participantNames = {
        userId1: user1.role == 'brand'
            ? (user1.companyName ?? 'Brand')
            : (user1.fullName ?? 'Creator'),
        userId2: user2.role == 'brand'
            ? (user2.companyName ?? 'Brand')
            : (user2.fullName ?? 'Creator'),
      };

      Map<String, String> participantAvatars = {};
      if (user1.profileImageUrl != null) {
        participantAvatars[userId1] = user1.profileImageUrl!;
      }
      if (user2.profileImageUrl != null) {
        participantAvatars[userId2] = user2.profileImageUrl!;
      }

      // Initial unread count
      Map<String, int> unreadCount = {
        userId1: 0,
        userId2: 0,
      };

      ChatModel chat = ChatModel(
        id: '', // Will be set by Firestore
        participants: participants,
        participantNames: participantNames,
        participantAvatars: participantAvatars,
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
        lastMessageText: '',
        lastMessageSenderId: '',
        unreadCount: unreadCount,
        campaignId: campaignId,
        campaignName: campaignName,
      );

      DocumentReference docRef = await _firestore.collection('chats').add(
            chat.toFirestore(),
          );

      return docRef.id;
    } catch (e) {
      print('Error getting or creating chat: $e');
      rethrow;
    }
  }

  // Send message
  Future<String> sendMessage(MessageModel message) async {
    try {
      // Add message to Firestore
      DocumentReference docRef = await _firestore.collection('messages').add(
            message.toFirestore(),
          );

      // Update chat's last message
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(message.chatId).get();
      ChatModel chat = ChatModel.fromFirestore(chatDoc);

      ChatModel updatedChat = chat.updateLastMessage(
        text: message.content,
        senderId: message.senderId,
        timestamp: message.timestamp,
      );

      await _firestore.collection('chats').doc(message.chatId).update(
            updatedChat.toFirestore(),
          );

      return docRef.id;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages for chat
  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  // Get chats for user
  Future<List<ChatModel>> getUserChats(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }

  // Mark chat as read for user
  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(chatId).get();
      ChatModel chat = ChatModel.fromFirestore(chatDoc);

      if (chat.hasUnreadMessages(userId)) {
        ChatModel updatedChat = chat.markAsReadForUser(userId);

        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount.$userId': 0,
        });
      }
    } catch (e) {
      print('Error marking chat as read: $e');
      rethrow;
    }
  }
}

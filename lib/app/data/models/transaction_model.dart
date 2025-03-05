import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  deposit,
  withdrawal,
  escrow,
  escrowRelease,
  refund,
  fee,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? description;
  final String? paymentMethod;
  final String? campaignId;
  final String? campaignName;
  final String? receiverId;
  final String? receiverName;
  final String? transactionReference;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.description,
    this.paymentMethod,
    this.campaignId,
    this.campaignName,
    this.receiverId,
    this.receiverName,
    this.transactionReference,
    this.metadata,
  });

  // Convert Firestore document to TransactionModel
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse transaction type
    TransactionType transactionType;
    switch (data['type']) {
      case 'deposit':
        transactionType = TransactionType.deposit;
        break;
      case 'withdrawal':
        transactionType = TransactionType.withdrawal;
        break;
      case 'escrow':
        transactionType = TransactionType.escrow;
        break;
      case 'escrowRelease':
        transactionType = TransactionType.escrowRelease;
        break;
      case 'refund':
        transactionType = TransactionType.refund;
        break;
      case 'fee':
        transactionType = TransactionType.fee;
        break;
      default:
        transactionType = TransactionType.deposit;
    }

    // Parse transaction status
    TransactionStatus transactionStatus;
    switch (data['status']) {
      case 'pending':
        transactionStatus = TransactionStatus.pending;
        break;
      case 'completed':
        transactionStatus = TransactionStatus.completed;
        break;
      case 'failed':
        transactionStatus = TransactionStatus.failed;
        break;
      case 'cancelled':
        transactionStatus = TransactionStatus.cancelled;
        break;
      default:
        transactionStatus = TransactionStatus.pending;
    }

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: transactionType,
      status: transactionStatus,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      paymentMethod: data['paymentMethod'],
      campaignId: data['campaignId'],
      campaignName: data['campaignName'],
      receiverId: data['receiverId'],
      receiverName: data['receiverName'],
      transactionReference: data['transactionReference'],
      metadata: data['metadata'],
    );
  }

  // Convert TransactionModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert transaction type to string
    String typeString;
    switch (type) {
      case TransactionType.deposit:
        typeString = 'deposit';
        break;
      case TransactionType.withdrawal:
        typeString = 'withdrawal';
        break;
      case TransactionType.escrow:
        typeString = 'escrow';
        break;
      case TransactionType.escrowRelease:
        typeString = 'escrowRelease';
        break;
      case TransactionType.refund:
        typeString = 'refund';
        break;
      case TransactionType.fee:
        typeString = 'fee';
        break;
    }

    // Convert transaction status to string
    String statusString;
    switch (status) {
      case TransactionStatus.pending:
        statusString = 'pending';
        break;
      case TransactionStatus.completed:
        statusString = 'completed';
        break;
      case TransactionStatus.failed:
        statusString = 'failed';
        break;
      case TransactionStatus.cancelled:
        statusString = 'cancelled';
        break;
    }

    return {
      'userId': userId,
      'amount': amount,
      'type': typeString,
      'status': statusString,
      'timestamp': timestamp,
      'description': description,
      'paymentMethod': paymentMethod,
      'campaignId': campaignId,
      'campaignName': campaignName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'transactionReference': transactionReference,
      'metadata': metadata,
    };
  }

  // Create a copy of TransactionModel with updated fields
  TransactionModel copyWith({
    TransactionStatus? status,
    String? description,
    String? transactionReference,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id,
      userId: userId,
      amount: amount,
      type: type,
      status: status ?? this.status,
      timestamp: timestamp,
      description: description ?? this.description,
      paymentMethod: paymentMethod,
      campaignId: campaignId,
      campaignName: campaignName,
      receiverId: receiverId,
      receiverName: receiverName,
      transactionReference: transactionReference ?? this.transactionReference,
      metadata: metadata ?? this.metadata,
    );
  }

  // Factory method for creating a deposit transaction
  factory TransactionModel.deposit({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? description,
  }) {
    return TransactionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: amount,
      type: TransactionType.deposit,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      description: description ?? 'Deposit to wallet',
      paymentMethod: paymentMethod,
    );
  }

  // Factory method for creating a withdrawal transaction
  factory TransactionModel.withdrawal({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? description,
  }) {
    return TransactionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: amount,
      type: TransactionType.withdrawal,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      description: description ?? 'Withdrawal from wallet',
      paymentMethod: paymentMethod,
    );
  }

  // Factory method for creating an escrow transaction
  factory TransactionModel.escrow({
    required String userId,
    required double amount,
    required String campaignId,
    required String campaignName,
    required String receiverId,
    required String receiverName,
    String? description,
  }) {
    return TransactionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: amount,
      type: TransactionType.escrow,
      status:
          TransactionStatus.completed, // Funds are immediately moved to escrow
      timestamp: DateTime.now(),
      description: description ?? 'Funds held in escrow for campaign',
      campaignId: campaignId,
      campaignName: campaignName,
      receiverId: receiverId,
      receiverName: receiverName,
    );
  }

  // Factory method for creating an escrow release transaction
  factory TransactionModel.escrowRelease({
    required String userId,
    required double amount,
    required String campaignId,
    required String campaignName,
    required String receiverId,
    required String receiverName,
    String? description,
  }) {
    return TransactionModel(
      id: '', // Will be set by Firestore
      userId: userId,
      amount: amount,
      type: TransactionType.escrowRelease,
      status: TransactionStatus.completed,
      timestamp: DateTime.now(),
      description: description ?? 'Funds released from escrow',
      campaignId: campaignId,
      campaignName: campaignName,
      receiverId: receiverId,
      receiverName: receiverName,
    );
  }
}

// Wallet model
class WalletModel {
  final String id; // Same as userId
  final double balance;
  final double escrowBalance;
  final double pendingWithdrawals;
  final DateTime lastUpdated;

  WalletModel({
    required this.id,
    required this.balance,
    required this.escrowBalance,
    required this.pendingWithdrawals,
    required this.lastUpdated,
  });

  // Convert Firestore document to WalletModel
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return WalletModel(
      id: doc.id,
      balance: (data['balance'] ?? 0).toDouble(),
      escrowBalance: (data['escrowBalance'] ?? 0).toDouble(),
      pendingWithdrawals: (data['pendingWithdrawals'] ?? 0).toDouble(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert WalletModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'escrowBalance': escrowBalance,
      'pendingWithdrawals': pendingWithdrawals,
      'lastUpdated': lastUpdated,
    };
  }

  // Create a new wallet
  factory WalletModel.create(String userId) {
    return WalletModel(
      id: userId,
      balance: 0,
      escrowBalance: 0,
      pendingWithdrawals: 0,
      lastUpdated: DateTime.now(),
    );
  }

  // Create a copy of WalletModel with updated fields
  WalletModel copyWith({
    double? balance,
    double? escrowBalance,
    double? pendingWithdrawals,
  }) {
    return WalletModel(
      id: id,
      balance: balance ?? this.balance,
      escrowBalance: escrowBalance ?? this.escrowBalance,
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
      lastUpdated: DateTime.now(),
    );
  }

  // Add funds to wallet
  WalletModel addFunds(double amount) {
    return copyWith(balance: balance + amount);
  }

  // Move funds to escrow
  WalletModel moveToEscrow(double amount) {
    if (balance < amount) {
      throw Exception('Insufficient funds');
    }
    return copyWith(
      balance: balance - amount,
      escrowBalance: escrowBalance + amount,
    );
  }

  // Release funds from escrow
  WalletModel releaseFromEscrow(double amount) {
    if (escrowBalance < amount) {
      throw Exception('Insufficient escrow funds');
    }
    return copyWith(
      escrowBalance: escrowBalance - amount,
    );
  }

  // Withdraw funds
  WalletModel withdrawFunds(double amount) {
    if (balance < amount) {
      throw Exception('Insufficient funds');
    }
    return copyWith(
      balance: balance - amount,
      pendingWithdrawals: pendingWithdrawals + amount,
    );
  }

  // Complete withdrawal
  WalletModel completeWithdrawal(double amount) {
    if (pendingWithdrawals < amount) {
      throw Exception('Invalid withdrawal amount');
    }
    return copyWith(
      pendingWithdrawals: pendingWithdrawals - amount,
    );
  }

  // Cancel withdrawal
  WalletModel cancelWithdrawal(double amount) {
    if (pendingWithdrawals < amount) {
      throw Exception('Invalid withdrawal amount');
    }
    return copyWith(
      balance: balance + amount,
      pendingWithdrawals: pendingWithdrawals - amount,
    );
  }

  // Get total balance (available + escrow + pending)
  double get totalBalance => balance + escrowBalance + pendingWithdrawals;

  // Check if user can withdraw a specific amount
  bool canWithdraw(double amount) => balance >= amount;
}

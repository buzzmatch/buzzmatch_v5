import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../authentication/controllers/auth_controller.dart';

class PaymentController extends GetxController {
  // Firebase service
  final FirebaseService _firebaseService = FirebaseService.to;

  // Auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Wallet data
  final Rx<WalletModel?> wallet = Rx<WalletModel?>(null);

  // Transaction history
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // Deposit amount controller
  late TextEditingController depositAmountController;

  // Withdraw amount controller
  late TextEditingController withdrawAmountController;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isDepositing = false.obs;
  final RxBool isWithdrawing = false.obs;

  // Selected payment method
  final RxString selectedPaymentMethod = 'card'.obs;

  @override
  void onInit() {
    super.onInit();
    depositAmountController = TextEditingController();
    withdrawAmountController = TextEditingController();

    // Load wallet data
    loadWallet();

    // Load transaction history
    loadTransactions();
  }

  @override
  void onClose() {
    depositAmountController.dispose();
    withdrawAmountController.dispose();
    super.onClose();
  }

  // Load wallet data
  Future<void> loadWallet() async {
    if (_authController.firebaseUser.value != null) {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        WalletModel? userWallet = await _firebaseService.getUserWallet(userId);

        if (userWallet == null) {
          // Create a new wallet if one doesn't exist
          userWallet = WalletModel.create(userId);
          await _firebaseService.saveWallet(userWallet);
        }

        wallet.value = userWallet;
      } catch (e) {
        print('Error loading wallet: $e');
        Get.snackbar(
          'Error',
          'Failed to load wallet data',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Load transaction history
  Future<void> loadTransactions() async {
    if (_authController.firebaseUser.value != null) {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        List<TransactionModel> userTransactions =
            await _firebaseService.getUserTransactions(userId);
        transactions.value = userTransactions;
      } catch (e) {
        print('Error loading transactions: $e');
        Get.snackbar(
          'Error',
          'Failed to load transaction history',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Refresh wallet and transaction data
  Future<void> refreshData() async {
    await loadWallet();
    await loadTransactions();
  }

  // Deposit funds
  Future<void> depositFunds() async {
    if (depositAmountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    double amount;
    try {
      amount = double.parse(depositAmountController.text);
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_authController.firebaseUser.value != null) {
      isDepositing.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        // In a real app, this is where you would integrate with a payment gateway
        // For demo purposes, we'll simulate a successful deposit

        // Create a transaction record
        TransactionModel transaction = TransactionModel.deposit(
          userId: userId,
          amount: amount,
          paymentMethod: selectedPaymentMethod.value,
          description: 'Wallet deposit',
        );

        // Update transaction status to completed (simulating successful payment)
        transaction = transaction.copyWith(status: TransactionStatus.completed);

        // Save transaction to Firestore
        await _firebaseService.createTransaction(transaction);

        // Update wallet balance
        if (wallet.value != null) {
          WalletModel updatedWallet = wallet.value!.addFunds(amount);
          await _firebaseService.saveWallet(updatedWallet);
          wallet.value = updatedWallet;
        }

        // Clear input field
        depositAmountController.clear();

        // Refresh data
        await loadTransactions();

        Get.snackbar(
          'Success',
          'Funds added to your wallet',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      } catch (e) {
        print('Error depositing funds: $e');
        Get.snackbar(
          'Error',
          'Failed to add funds',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isDepositing.value = false;
      }
    }
  }

  // Withdraw funds
  Future<void> withdrawFunds() async {
    if (withdrawAmountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    double amount;
    try {
      amount = double.parse(withdrawAmountController.text);
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_authController.firebaseUser.value != null && wallet.value != null) {
      // Check if there are sufficient funds
      if (!wallet.value!.canWithdraw(amount)) {
        Get.snackbar(
          'Error',
          'Insufficient funds',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isWithdrawing.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        // Create a transaction record
        TransactionModel transaction = TransactionModel.withdrawal(
          userId: userId,
          amount: amount,
          paymentMethod: selectedPaymentMethod.value,
          description: 'Wallet withdrawal',
        );

        // Save transaction to Firestore
        await _firebaseService.createTransaction(transaction);

        // Update wallet balance
        WalletModel updatedWallet = wallet.value!.withdrawFunds(amount);
        await _firebaseService.saveWallet(updatedWallet);
        wallet.value = updatedWallet;

        // Clear input field
        withdrawAmountController.clear();

        // Refresh data
        await loadTransactions();

        Get.snackbar(
          'Success',
          'Withdrawal request submitted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      } catch (e) {
        print('Error withdrawing funds: $e');
        Get.snackbar(
          'Error',
          'Failed to process withdrawal',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isWithdrawing.value = false;
      }
    }
  }

  // Move funds to escrow (for brands)
  Future<void> moveToEscrow(
    String campaignId,
    String campaignName,
    String creatorId,
    String creatorName,
    double amount,
  ) async {
    if (_authController.firebaseUser.value != null && wallet.value != null) {
      // Check if there are sufficient funds
      if (!wallet.value!.canWithdraw(amount)) {
        Get.snackbar(
          'Error',
          'Insufficient funds',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        // Create a transaction record
        TransactionModel transaction = TransactionModel.escrow(
          userId: userId,
          amount: amount,
          campaignId: campaignId,
          campaignName: campaignName,
          receiverId: creatorId,
          receiverName: creatorName,
          description: 'Funds moved to escrow for campaign: $campaignName',
        );

        // Save transaction to Firestore
        await _firebaseService.createTransaction(transaction);

        // Update wallet balance
        WalletModel updatedWallet = wallet.value!.moveToEscrow(amount);
        await _firebaseService.saveWallet(updatedWallet);
        wallet.value = updatedWallet;

        // Refresh data
        await loadTransactions();

        Get.snackbar(
          'Success',
          'Funds moved to escrow',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      } catch (e) {
        print('Error moving funds to escrow: $e');
        Get.snackbar(
          'Error',
          'Failed to move funds to escrow',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Release funds from escrow (for brands)
  Future<void> releaseFromEscrow(
    String campaignId,
    String campaignName,
    String creatorId,
    String creatorName,
    double amount,
  ) async {
    if (_authController.firebaseUser.value != null && wallet.value != null) {
      isLoading.value = true;
      String userId = _authController.firebaseUser.value!.uid;

      try {
        // Check if there are sufficient funds in escrow
        if (wallet.value!.escrowBalance < amount) {
          throw Exception('Insufficient funds in escrow');
        }

        // Create a transaction record for the brand
        TransactionModel brandTransaction = TransactionModel.escrowRelease(
          userId: userId,
          amount: amount,
          campaignId: campaignId,
          campaignName: campaignName,
          receiverId: creatorId,
          receiverName: creatorName,
          description: 'Released funds from escrow for campaign: $campaignName',
        );

        // Save brand transaction to Firestore
        await _firebaseService.createTransaction(brandTransaction);

        // Update brand wallet balance
        WalletModel updatedWallet = wallet.value!.releaseFromEscrow(amount);
        await _firebaseService.saveWallet(updatedWallet);
        wallet.value = updatedWallet;

        // Create a transaction record for the creator
        String brandName =
            _authController.currentUser.value?.companyName ?? 'Brand';

        TransactionModel creatorTransaction = TransactionModel(
          id: '',
          userId: creatorId,
          amount: amount,
          type: TransactionType.escrowRelease,
          status: TransactionStatus.completed,
          timestamp: DateTime.now(),
          description:
              'Payment received from $brandName for campaign: $campaignName',
          campaignId: campaignId,
          campaignName: campaignName,
          receiverId: userId,
          receiverName: brandName,
        );

        // Save creator transaction to Firestore
        await _firebaseService.createTransaction(creatorTransaction);

        // Update creator wallet
        WalletModel? creatorWallet =
            await _firebaseService.getUserWallet(creatorId);

        creatorWallet ??= WalletModel.create(creatorId);

        // Add funds to creator wallet
        WalletModel updatedCreatorWallet = creatorWallet.addFunds(amount);
        await _firebaseService.saveWallet(updatedCreatorWallet);

        // Refresh data
        await loadTransactions();

        Get.snackbar(
          'Success',
          'Funds released to creator',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      } catch (e) {
        print('Error releasing funds from escrow: $e');
        Get.snackbar(
          'Error',
          'Failed to release funds from escrow',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Get transactions filtered by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }

  // Get transactions filtered by status
  List<TransactionModel> getTransactionsByStatus(TransactionStatus status) {
    return transactions
        .where((transaction) => transaction.status == status)
        .toList();
  }

  // Get pending withdrawals
  List<TransactionModel> get pendingWithdrawals {
    return transactions
        .where((transaction) =>
            transaction.type == TransactionType.withdrawal &&
            transaction.status == TransactionStatus.pending)
        .toList();
  }

  // Format amount as currency
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

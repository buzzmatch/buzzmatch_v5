import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class WalletView extends GetView<PaymentController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wallet'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.honeycombMedium,
        child: Obx(() {
          if (controller.isLoading.value && controller.wallet.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.honeycombMedium),
              ),
            );
          }

          final wallet = controller.wallet.value;
          if (wallet == null) {
            return Center(
              child: Text(
                'Wallet not available'.tr,
                style: AppText.body1,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Balance card
              _buildBalanceCard(wallet),

              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(),

              const SizedBox(height: 24),

              // Transaction history
              _buildTransactionHistory(),
            ],
          );
        }),
      ),
    );
  }

  // Balance card widget
  Widget _buildBalanceCard(WalletModel wallet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.honeyGradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Balance'.tr,
                  style: AppText.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              controller.formatCurrency(wallet.balance),
              style: AppText.h1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Escrow balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In Escrow'.tr,
                      style: AppText.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatCurrency(wallet.escrowBalance),
                      style: AppText.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Pending withdrawals
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending'.tr,
                      style: AppText.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatCurrency(wallet.pendingWithdrawals),
                      style: AppText.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Total balance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total'.tr,
                      style: AppText.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.formatCurrency(wallet.totalBalance),
                      style: AppText.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action buttons widget
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Add funds button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddFundsDialog(Get.context!);
            },
            icon: const Icon(Icons.add),
            label: Text('Add Funds'.tr),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppColors.honeycombDark,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Withdraw button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _showWithdrawDialog(Get.context!);
            },
            icon: const Icon(Icons.money),
            label: Text('Withdraw'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: AppColors.honeycombDark),
            ),
          ),
        ),
      ],
    );
  }

  // Transaction history widget
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Transaction History'.tr,
          style: AppText.h4,
        ),

        const SizedBox(height: 16),

        // Transaction filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text('All'.tr),
                selected: true,
                onSelected: (selected) {},
                backgroundColor: Colors.white,
                selectedColor: AppColors.primaryYellow.withOpacity(0.2),
                checkmarkColor: AppColors.honeycombDark,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Deposits'.tr),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Withdrawals'.tr),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Escrow'.tr),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Payments'.tr),
                selected: false,
                onSelected: (selected) {},
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Transaction list
        if (controller.transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.accentGrey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet'.tr,
                    style: AppText.h3.copyWith(color: AppColors.accentGrey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transaction history will appear here'.tr,
                    style: AppText.body1.copyWith(color: AppColors.accentGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = controller.transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
      ],
    );
  }

  // Transaction item widget
  Widget _buildTransactionItem(TransactionModel transaction) {
    // Determine icon and colors
    IconData icon;
    Color iconColor;
    Color amountColor;
    String amountPrefix;

    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.add_circle_outline;
        iconColor = AppColors.success;
        amountColor = AppColors.success;
        amountPrefix = '+';
        break;
      case TransactionType.withdrawal:
        icon = Icons.remove_circle_outline;
        iconColor = transaction.status == TransactionStatus.pending
            ? AppColors.warning
            : AppColors.accentGrey;
        amountColor = transaction.status == TransactionStatus.pending
            ? AppColors.warning
            : AppColors.accentGrey;
        amountPrefix = '-';
        break;
      case TransactionType.escrow:
        icon = Icons.lock_outline;
        iconColor = AppColors.honeycombDark;
        amountColor = AppColors.accentGrey;
        amountPrefix = '';
        break;
      case TransactionType.escrowRelease:
        icon = Icons.send;
        iconColor = AppColors.info;
        amountColor = AppColors.accentGrey;
        amountPrefix = '';
        break;
      case TransactionType.refund:
        icon = Icons.replay;
        iconColor = AppColors.success;
        amountColor = AppColors.success;
        amountPrefix = '+';
        break;
      case TransactionType.fee:
        icon = Icons.attach_money;
        iconColor = AppColors.error;
        amountColor = AppColors.error;
        amountPrefix = '-';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        _getTransactionTitle(transaction),
        style: AppText.body1,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatTransactionDate(transaction.timestamp),
        style: AppText.caption.copyWith(
          color: AppColors.accentGrey,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$amountPrefix${controller.formatCurrency(transaction.amount)}',
            style: AppText.body1.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          _buildStatusBadge(transaction.status),
        ],
      ),
      onTap: () {
        _showTransactionDetails(Get.context!, transaction);
      },
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(TransactionStatus status) {
    Color color;
    String text;

    switch (status) {
      case TransactionStatus.pending:
        color = AppColors.warning;
        text = 'Pending'.tr;
        break;
      case TransactionStatus.completed:
        color = AppColors.success;
        text = 'Completed'.tr;
        break;
      case TransactionStatus.failed:
        color = AppColors.error;
        text = 'Failed'.tr;
        break;
      case TransactionStatus.cancelled:
        color = AppColors.accentGrey;
        text = 'Cancelled'.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppText.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Show add funds dialog
  void _showAddFundsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
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
                'Add Funds'.tr,
                style: AppText.h3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.depositAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount'.tr,
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Method'.tr,
                style: AppText.body1,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Obx(() => Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.credit_card),
                            const SizedBox(width: 8),
                            Text('Credit/Debit Card'.tr),
                          ],
                        ),
                        value: 'card',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                        activeColor: AppColors.honeycombDark,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.payment),
                            const SizedBox(width: 8),
                            Text('PayPal'.tr),
                          ],
                        ),
                        value: 'paypal',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                        activeColor: AppColors.honeycombDark,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.account_balance),
                            const SizedBox(width: 8),
                            Text('Bank Transfer'.tr),
                          ],
                        ),
                        value: 'bank',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                        activeColor: AppColors.honeycombDark,
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isDepositing.value
                          ? null
                          : () {
                              Get.back();
                              controller.depositFunds();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.honeycombDark,
                      ),
                      child: controller.isDepositing.value
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Add Funds'.tr),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Show withdraw dialog
  void _showWithdrawDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
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
                'Withdraw Funds'.tr,
                style: AppText.h3,
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    'Available: ${controller.formatCurrency(controller.wallet.value?.balance ?? 0)}',
                    style: AppText.body2.copyWith(
                      color: AppColors.accentGrey,
                    ),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: controller.withdrawAmountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount'.tr,
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Withdrawal Method'.tr,
                style: AppText.body1,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Obx(() => Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.account_balance),
                            const SizedBox(width: 8),
                            Text('Bank Transfer'.tr),
                          ],
                        ),
                        value: 'bank',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                        activeColor: AppColors.honeycombDark,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.payment),
                            const SizedBox(width: 8),
                            Text('PayPal'.tr),
                          ],
                        ),
                        value: 'paypal',
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedPaymentMethod.value = value;
                          }
                        },
                        activeColor: AppColors.honeycombDark,
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isWithdrawing.value
                          ? null
                          : () {
                              Get.back();
                              controller.withdrawFunds();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.honeycombDark,
                      ),
                      child: controller.isWithdrawing.value
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text('Withdraw'.tr),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // Show transaction details dialog
  void _showTransactionDetails(
      BuildContext context, TransactionModel transaction) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
              ),
              Text(
                'Transaction Details'.tr,
                style: AppText.h3,
              ),
              const SizedBox(height: 24),

              // Transaction type & status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTransactionTypeText(transaction.type),
                    style: AppText.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(transaction.status),
                ],
              ),

              const Divider(height: 32),

              // Date & amount
              _buildDetailRow(
                  'Date'.tr, _formatTransactionDate(transaction.timestamp)),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Amount'.tr, controller.formatCurrency(transaction.amount)),

              // Payment method (if available)
              if (transaction.paymentMethod != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Payment Method'.tr,
                    _getPaymentMethodText(transaction.paymentMethod!)),
              ],

              // Campaign details (if available)
              if (transaction.campaignName != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Campaign'.tr, transaction.campaignName!),
              ],

              // Receiver details (if available)
              if (transaction.receiverName != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  transaction.type == TransactionType.escrow ||
                          transaction.type == TransactionType.escrowRelease
                      ? 'Creator'.tr
                      : 'Receiver'.tr,
                  transaction.receiverName!,
                ),
              ],

              // Reference (if available)
              if (transaction.transactionReference != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Reference'.tr, transaction.transactionReference!),
              ],

              // Description (if available)
              if (transaction.description != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow('Description'.tr, transaction.description!,
                    multiline: true),
              ],

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('Close'.tr),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to build detail row
  Widget _buildDetailRow(String label, String value, {bool multiline = false}) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppText.body2.copyWith(
              color: AppColors.accentGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppText.body2,
            maxLines: multiline ? null : 1,
            overflow: multiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper to get transaction title
  String _getTransactionTitle(TransactionModel transaction) {
    switch (transaction.type) {
      case TransactionType.deposit:
        return 'Deposit to Wallet'.tr;
      case TransactionType.withdrawal:
        return 'Withdrawal from Wallet'.tr;
      case TransactionType.escrow:
        if (transaction.campaignName != null) {
          return 'Escrow for ${transaction.campaignName}'.tr;
        }
        return 'Funds to Escrow'.tr;
      case TransactionType.escrowRelease:
        if (transaction.campaignName != null) {
          return 'Payment for ${transaction.campaignName}'.tr;
        }
        return 'Payment Release'.tr;
      case TransactionType.refund:
        return 'Refund'.tr;
      case TransactionType.fee:
        return 'Service Fee'.tr;
    }
  }

  // Helper to get transaction type text
  String _getTransactionTypeText(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit'.tr;
      case TransactionType.withdrawal:
        return 'Withdrawal'.tr;
      case TransactionType.escrow:
        return 'Escrow'.tr;
      case TransactionType.escrowRelease:
        return 'Payment Release'.tr;
      case TransactionType.refund:
        return 'Refund'.tr;
      case TransactionType.fee:
        return 'Service Fee'.tr;
    }
  }

  // Helper to get payment method text
  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'card':
        return 'Credit/Debit Card'.tr;
      case 'paypal':
        return 'PayPal'.tr;
      case 'bank':
        return 'Bank Transfer'.tr;
      default:
        return method;
    }
  }

  // Helper to format transaction date
  String _formatTransactionDate(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }
}

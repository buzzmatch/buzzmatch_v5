import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';

class PaymentMethodView extends GetView<PaymentController> {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Payment Methods'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Saved Payment Methods'.tr,
              style: AppText.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Credit Card
            _buildPaymentMethodCard(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card'.tr,
              subtitle: '**** **** **** 1234',
              isDefault: true,
            ),
            
            const SizedBox(height: 12),
            
            // PayPal
            _buildPaymentMethodCard(
              icon: Icons.payment,
              title: 'PayPal'.tr,
              subtitle: 'user@example.com',
              isDefault: false,
            ),
            
            const SizedBox(height: 24),
            
            // Add Payment Method Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddPaymentMethodSheet(context);
                },
                icon: const Icon(Icons.add),
                label: Text('Add Payment Method'.tr),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.honeycombDark,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section title
            Text(
              'Payment History'.tr,
              style: AppText.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment history list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Sample data
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildPaymentHistoryItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Payment method card widget
  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDefault
            ? const BorderSide(color: AppColors.honeycombDark, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.honeycombMedium.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.honeycombDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppText.body2.copyWith(
                      color: AppColors.accentGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.honeycombMedium.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default'.tr,
                  style: AppText.caption.copyWith(
                    color: AppColors.honeycombDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.accentGrey,
              ),
              onSelected: (value) {
                // Handle menu item selection
                if (value == 'edit') {
                  // Edit payment method
                } else if (value == 'delete') {
                  // Delete payment method
                } else if (value == 'default') {
                  // Set as default
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('Edit'.tr),
                    ],
                  ),
                ),
                if (!isDefault)
                  PopupMenuItem<String>(
                    value: 'default',
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 18),
                        const SizedBox(width: 8),
                        Text('Set as Default'.tr),
                      ],
                    ),
                  ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete'.tr, style: const TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Payment history item widget
  Widget _buildPaymentHistoryItem(int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.honeycombMedium.withOpacity(0.1),
        child: const Icon(
          Icons.payment,
          color: AppColors.honeycombDark,
        ),
      ),
      title: Text(
        'Payment #$index',
        style: AppText.body1.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'Date: 01/01/2022\nAmount: \$100.00',
        style: AppText.body2.copyWith(
          color: AppColors.accentGrey,
        ),
      ),
    );
  }

  // Show add payment method sheet
  void _showAddPaymentMethodSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
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
            const SizedBox(height: 16),
            Text(
              'Add Payment Method'.tr,
              style: AppText.h3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Add credit/debit card
              },
              icon: const Icon(Icons.credit_card),
              label: Text('Add Credit/Debit Card'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.honeycombDark,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Add PayPal
              },
              icon: const Icon(Icons.payment),
              label: Text('Add PayPal'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.honeycombDark,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
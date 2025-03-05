import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:buzzmatch_v5/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:buzzmatch_v5/app/modules/authentication/controllers/auth_controller.dart';
import 'package:buzzmatch_v5/app/theme/app_colors.dart';
import 'package:buzzmatch_v5/app/theme/app_text.dart';
import 'package:buzzmatch_v5/app/routes/app_pages.dart';
import 'package:buzzmatch_v5/app/data/models/campaign_model.dart';
import 'package:buzzmatch_v5/app/data/models/user_model.dart';
import 'package:buzzmatch_v5/app/modules/dashboard/widgets/campaign_card.dart';
import 'package:buzzmatch_v5/app/modules/dashboard/widgets/creator_card.dart';

class BrandDashboardView extends GetView<DashboardController> {
  const BrandDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() => Text(
              controller.currentUser.value?.companyName ?? 'Brand Dashboard'.tr,
              style: AppText.h3,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: controller.tabController,
              labelColor: AppColors.honeycombDark,
              unselectedLabelColor: AppColors.accentGrey,
              indicatorColor: AppColors.honeycombDark,
              tabs: [
                Tab(text: 'Campaigns'.tr),
                Tab(text: 'Creators'.tr),
                Tab(text: 'Messages'.tr),
                Tab(text: 'Wallet'.tr),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _buildCampaignsTab(),
                _buildCreatorsTab(),
                _buildMessagesTab(),
                _buildWalletTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        // Only show FAB on Campaigns tab
        return controller.selectedTabIndex.value == 0
            ? FloatingActionButton(
                backgroundColor: AppColors.honeycombDark,
                child: const Icon(Icons.add),
                onPressed: () {
                  Get.toNamed(Routes.CAMPAIGN_CREATE);
                },
              )
            : const SizedBox.shrink(); // ✅ Fixed `null` issue
      }),
    );
  }

  // Campaigns Tab
  Widget _buildCampaignsTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.campaigns.isEmpty) {
          return _buildEmptyState(
            icon: Icons.campaign_outlined,
            title: 'No campaigns yet'.tr,
            subtitle: 'Create your first campaign'.tr,
            buttonText: 'Create Campaign'.tr,
            onPressed: () => Get.toNamed(Routes.CAMPAIGN_CREATE),
          );
        }

        // Group campaigns by status
        final activeCampaigns =
            controller.getCampaignsByStatus(CampaignStatus.active);
        final draftCampaigns =
            controller.getCampaignsByStatus(CampaignStatus.draft);
        final completedCampaigns =
            controller.getCampaignsByStatus(CampaignStatus.completed);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeCampaigns.isNotEmpty) _buildCampaignList('Active Campaigns'.tr, activeCampaigns),
            if (draftCampaigns.isNotEmpty) _buildCampaignList('Draft Campaigns'.tr, draftCampaigns),
            if (completedCampaigns.isNotEmpty) _buildCampaignList('Completed Campaigns'.tr, completedCampaigns),
          ],
        );
      }),
    );
  }

  Widget _buildCampaignList(String title, List<CampaignModel> campaigns) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.h4),
        const SizedBox(height: 8),
        ...campaigns.map((campaign) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CampaignCard(
                campaign: campaign,
                onTap: () {
                  Get.toNamed(
                    Routes.CAMPAIGN_DETAIL,
                    arguments: {'campaignId': campaign.id},
                  );
                },
trailing: ElevatedButton(
  onPressed: () {
    // Define what happens when pressed
    Get.toNamed(
      Routes.CAMPAIGN_DETAIL,
      arguments: {'campaignId': campaign.id},
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.honeycombDark,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  child: Text('View'.tr),
),
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.accentGrey),
          const SizedBox(height: 16),
          Text(title, style: AppText.h3.copyWith(color: AppColors.accentGrey)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppText.body1.copyWith(color: AppColors.accentGrey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.honeycombDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Creators Tab
  Widget _buildCreatorsTab() {
    return Center(child: Text('Creators Tab'.tr, style: AppText.h3));
  }

  // Messages Tab
  Widget _buildMessagesTab() {
    return Center(child: Text('Messages Tab'.tr, style: AppText.h3));
  }

  // Wallet Tab
  Widget _buildWalletTab() {
    return Center(child: Text('Wallet Tab'.tr, style: AppText.h3));
  }
}

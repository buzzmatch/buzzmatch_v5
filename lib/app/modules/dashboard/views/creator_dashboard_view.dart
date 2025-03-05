import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../routes/app_pages.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../widgets/campaign_card.dart';

class CreatorDashboardView extends GetView<DashboardController> {
  const CreatorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() => Text(
              controller.currentUser.value?.fullName ?? 'Creator Dashboard'.tr,
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
                Tab(text: 'Portfolio'.tr),
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
                _buildPortfolioTab(),
                _buildMessagesTab(),
                _buildWalletTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Campaigns Tab
  Widget _buildCampaignsTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Get different campaign lists
        final activeCampaigns = controller.getActiveCampaignsForCreator();
        final invitedCampaigns = controller.getInvitedCampaignsForCreator();
        final appliedCampaigns = controller.getAppliedCampaignsForCreator();
        final matchedCampaigns = controller.getMatchedCampaignsForCreator();

        final bool hasAnyCampaigns = activeCampaigns.isNotEmpty ||
            invitedCampaigns.isNotEmpty ||
            appliedCampaigns.isNotEmpty ||
            matchedCampaigns.isNotEmpty;

        if (!hasAnyCampaigns) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: AppColors.accentGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No campaigns available'.tr,
                  style: AppText.h3.copyWith(color: AppColors.accentGrey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for new campaigns'.tr,
                  style: AppText.body1.copyWith(color: AppColors.accentGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Matched/Active projects
            if (matchedCampaigns.isNotEmpty) ...[
              Text(
                'Active Projects'.tr,
                style: AppText.h4,
              ),
              const SizedBox(height: 8),
              ...matchedCampaigns.map((campaign) => Padding(
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
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentLightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Active'.tr),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Invited campaigns
            if (invitedCampaigns.isNotEmpty) ...[
              Text(
                'Invited Campaigns'.tr,
                style: AppText.h4,
              ),
              const SizedBox(height: 8),
              ...invitedCampaigns.map((campaign) => Padding(
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
                          controller.applyToCampaign(campaign.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.honeycombDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Apply'.tr),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Applied campaigns
            if (appliedCampaigns.isNotEmpty) ...[
              Text(
                'Applied Campaigns'.tr,
                style: AppText.h4,
              ),
              const SizedBox(height: 8),
              ...appliedCampaigns.map((campaign) => Padding(
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
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentLightGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Applied'.tr,
                          style: AppText.body2,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Discover campaigns
            if (activeCampaigns.isNotEmpty) ...[
              Text(
                'Discover Campaigns'.tr,
                style: AppText.h4,
              ),
              const SizedBox(height: 8),
              ...activeCampaigns.map((campaign) => Padding(
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
                          controller.applyToCampaign(campaign.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.honeycombDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Apply'.tr),
                      ),
                    ),
                  )),
            ],
          ],
        );
      }),
    );
  }

  // Portfolio Tab
  Widget _buildPortfolioTab() {
    return Obx(() {
      final user = controller.currentUser.value;
      final bool hasPortfolio =
          user?.portfolioUrls != null && user!.portfolioUrls!.isNotEmpty;

      if (!hasPortfolio) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: AppColors.accentGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'No portfolio items yet'.tr,
                style: AppText.h3.copyWith(color: AppColors.accentGrey),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your work to showcase your skills'.tr,
                style: AppText.body1.copyWith(color: AppColors.accentGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to add portfolio item
                },
                icon: const Icon(Icons.add),
                label: Text('Add Portfolio Item'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.honeycombDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: user.portfolioUrls!.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == user.portfolioUrls!.length) {
                // Add button
                return InkWell(
                  onTap: () {
                    // Navigate to add portfolio item
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentLightGrey,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: AppColors.accentGrey,
                      ),
                    ),
                  ),
                );
              }

              // Portfolio item
              final String url = user.portfolioUrls![index];
              return InkWell(
                onTap: () {
                  // View portfolio item
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // Add button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.honeycombDark,
              child: const Icon(Icons.add),
              onPressed: () {
                // Navigate to add portfolio item
              },
            ),
          ),
        ],
      );
    });
  }

  // Messages Tab
  Widget _buildMessagesTab() {
    return Center(
      child: Text(
        'Messages Tab'.tr,
        style: AppText.h3,
      ),
    );
  }

  // Wallet Tab
  Widget _buildWalletTab() {
    return Center(
      child: Text(
        'Wallet Tab'.tr,
        style: AppText.h3,
      ),
    );
  }
}

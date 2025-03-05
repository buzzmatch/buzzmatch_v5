import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/campaign_controller.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

class CampaignDetailView extends GetView<CampaignController> {
  const CampaignDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get campaign ID from arguments
    final args = Get.arguments as Map<String, dynamic>;
    final String campaignId = args['campaignId'] as String;
    
    // Load campaign data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCampaign(campaignId);
    });
    
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Campaign Details'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.accentBlack),
        actions: [
          // Only show edit button for brand's own campaigns
          Obx(() {
            final AuthController authController = Get.find<AuthController>();
            final bool isOwnCampaign = controller.currentCampaign.value != null &&
                controller.currentCampaign.value!.brandId == authController.firebaseUser.value?.uid;
            
            if (isOwnCampaign) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      // TODO: Implement edit functionality
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, campaignId);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: AppColors.accentBlack),
                        const SizedBox(width: 8),
                        Text('Edit'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text(
                          'Delete'.tr,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.honeycombMedium),
            ),
          );
        }
        
        final campaign = controller.currentCampaign.value;
        if (campaign == null) {
          return Center(
            child: Text(
              'Campaign not found'.tr,
              style: AppText.body1,
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign header and status
              _buildCampaignHeader(campaign),
              
              const SizedBox(height: 24),
              
              // Campaign details
              _buildCampaignDetails(campaign),
              
              const SizedBox(height: 24),
              
              // Reference materials
              _buildReferenceMaterials(campaign),
              
              const SizedBox(height: 24),
              
              // Collaborators section
              _buildCollaboratorsSection(campaign, context),
              
              const SizedBox(height: 32),
              
              // Action button (Apply or Chat based on user role and status)
              _buildActionButton(campaign, context),
            ],
          ),
        );
      }),
    );
  }

  // Campaign header widget
  Widget _buildCampaignHeader(CampaignModel campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand logo and name
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentLightGrey,
                borderRadius: BorderRadius.circular(8),
                image: campaign.brandLogoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(campaign.brandLogoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: campaign.brandLogoUrl == null
                  ? Center(
                      child: Text(
                        campaign.brandName.substring(0, 1),
                        style: AppText.h3.copyWith(
                          color: AppColors.accentGrey,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.brandName,
                  style: AppText.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Created on ${DateFormat('MMM d, yyyy').format(campaign.createdAt)}',
                  style: AppText.caption.copyWith(
                    color: AppColors.accentGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildStatusBadge(campaign.status),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Campaign title
        Text(
          campaign.campaignName,
          style: AppText.h2,
        ),
        
        const SizedBox(height: 8),
        
        // Product name
        Text(
          campaign.productName,
          style: AppText.body1.copyWith(
            color: AppColors.accentGrey,
          ),
        ),
      ],
    );
  }

  // Campaign details widget
  Widget _buildCampaignDetails(CampaignModel campaign) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Campaign Details'.tr,
              style: AppText.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Budget
            _buildDetailRow(
              icon: Icons.attach_money,
              title: 'Budget'.tr,
              value: '\$${campaign.budget.toStringAsFixed(2)}',
            ),
            
            const SizedBox(height: 12),
            
            // Deadline
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'Deadline'.tr,
              value: DateFormat('MMM d, yyyy').format(campaign.deadline),
            ),
            
            const SizedBox(height: 12),
            
            // Content types
            _buildDetailRow(
              icon: Icons.category,
              title: 'Content Types'.tr,
              value: campaign.requiredContentTypes.map((type) => controller.getContentTypeName(type)).join(', '),
            ),
            
            const SizedBox(height: 16),
            
            // Description title
            Text(
              'Description'.tr,
              style: AppText.body2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description text
            Text(
              campaign.description,
              style: AppText.body2,
            ),
          ],
        ),
      ),
    );
  }

  // Reference materials widget
  Widget _buildReferenceMaterials(CampaignModel campaign) {
    final bool hasReferenceImages = campaign.referenceImageUrls.isNotEmpty;
    final bool hasReferenceVideos = campaign.referenceVideoUrls.isNotEmpty;
    
    if (!hasReferenceImages && !hasReferenceVideos) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Reference Materials'.tr,
              style: AppText.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (hasReferenceImages) ...[
              const SizedBox(height: 16),
              
              // Images title
              Text(
                'Reference Images'.tr,
                style: AppText.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Images grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: campaign.referenceImageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
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
                              campaign.referenceImageUrls[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        campaign.referenceImageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppColors.accentLightGrey,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.honeycombDark,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.accentLightGrey,
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: AppColors.accentGrey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            
            if (hasReferenceVideos) ...[
              const SizedBox(height: 16),
              
              // Videos title
              Text(
                'Reference Videos'.tr,
                style: AppText.body2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Videos list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: campaign.referenceVideoUrls.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.accentLightGrey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: AppColors.honeycombDark,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Video ${index + 1}',
                                style: AppText.body1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to play video'.tr,
                                style: AppText.body2.copyWith(
                                  color: AppColors.accentGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement video playback
                            // This would typically open a video player
                            Get.snackbar(
                              'Coming Soon',
                              'Video playback will be available in the next update',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                          icon: const Icon(
                            Icons.play_circle_outline,
                            color: AppColors.honeycombDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Collaborators section widget
  Widget _buildCollaboratorsSection(CampaignModel campaign, BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final bool isOwnCampaign = campaign.brandId == authController.firebaseUser.value?.uid;
    
    // If it's not the brand's campaign and there are no matched creators, don't show this section
    if (!isOwnCampaign && campaign.matchedCreators.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collaborators'.tr,
                  style: AppText.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOwnCampaign && campaign.appliedCreators.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _showAppliedCreatorsSheet(context, campaign);
                    },
                    child: Text(
                      'View Applications (${campaign.appliedCreators.length})'.tr,
                      style: AppText.body2.copyWith(
                        color: AppColors.honeycombDark,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // If no collaborators yet
            if (campaign.matchedCreators.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.accentGrey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No collaborators yet'.tr,
                        style: AppText.body1.copyWith(
                          color: AppColors.accentGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isOwnCampaign)
                        Text(
                          'When creators apply to your campaign, you can accept them here'.tr,
                          style: AppText.body2.copyWith(
                            color: AppColors.accentGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              )
            else
              // Collaborators list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: campaign.matchedCreators.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final String creatorId = campaign.matchedCreators[index];
                  final CollaborationStatus status = campaign.collaborationStatuses[creatorId] ?? 
                      CollaborationStatus.matched;
                  
                  // Find creator in the creators list
                  final UserModel? creator = controller.creators
                      .firstWhereOrNull((c) => c.id == creatorId);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentLightGrey,
                      backgroundImage: creator?.profileImageUrl != null
                          ? NetworkImage(creator!.profileImageUrl!)
                          : null,
                      child: creator?.profileImageUrl == null
                          ? Text(
                              creator?.fullName?.substring(0, 1) ?? 'C',
                              style: AppText.body1,
                            )
                          : null,
                    ),
                    title: Text(
                      creator?.fullName ?? 'Creator',
                      style: AppText.body1,
                    ),
                    subtitle: Row(
                      children: [
                        _buildCollaborationStatusBadge(status),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.honeycombDark,
                      ),
                      onPressed: () {
                        // Navigate to chat with this creator
                        Get.toNamed(
                          Routes.CHAT_DETAIL,
                          arguments: {
                            'otherUserId': creatorId,
                            'campaignId': campaign.id,
                            'campaignName': campaign.campaignName,
                          },
                        );
                      },
                    ),
                    onTap: () {
                      // TODO: Show collaborator details or update status
                      if (isOwnCampaign) {
                        _showUpdateStatusSheet(context, campaign, creatorId, status);
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Action button based on user role and status
  Widget _buildActionButton(CampaignModel campaign, BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final String currentUserId = authController.firebaseUser.value?.uid ?? '';
    final String userRole = authController.userRole.value;
    
    // If user is the brand owner of this campaign
    if (currentUserId == campaign.brandId) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // Navigate to find creators
            Get.toNamed(Routes.BRAND_DASHBOARD, arguments: {'tabIndex': 1});
          },
          icon: const Icon(Icons.people),
          label: Text('Find Creators'.tr),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }
    
    // If user is a creator
    if (userRole == 'creator') {
      // Check if creator has already applied
      final bool hasApplied = campaign.appliedCreators.contains(currentUserId);
      
      // Check if creator has been matched
      final bool isMatched = campaign.matchedCreators.contains(currentUserId);
      
      if (isMatched) {
        // Creator is matched, show chat button
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to chat with the brand
              Get.toNamed(
                Routes.CHAT_DETAIL,
                arguments: {
                  'otherUserId': campaign.brandId,
                  'campaignId': campaign.id,
                  'campaignName': campaign.campaignName,
                },
              );
            },
            icon: const Icon(Icons.chat),
            label: Text('Message Brand'.tr),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppColors.honeycombDark,
            ),
          ),
        );
      } else if (hasApplied) {
        // Creator has applied but not yet matched
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null, // Disabled button
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.grey[300],
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              'Application Pending'.tr,
              style: AppText.button.copyWith(
                color: AppColors.accentGrey,
              ),
            ),
          ),
        );
      } else {
        // Creator has not applied yet
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Apply to campaign
              _showApplyConfirmation(context, campaign.id);
            },
            icon: const Icon(Icons.check_circle),
            label: Text('Apply Now'.tr),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppColors.honeycombDark,
            ),
          ),
        );
      }
    }
    
    // Default - should not reach here
    return const SizedBox.shrink();
  }

  // Detail row widget
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.honeycombDark,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: AppText.body2.copyWith(
            color: AppColors.accentGrey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppText.body2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(CampaignStatus status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case CampaignStatus.draft:
        badgeColor = Colors.grey;
        statusText = 'Draft';
        break;
      case CampaignStatus.active:
        badgeColor = AppColors.honeycombMedium;
        statusText = 'Active';
        break;
      case CampaignStatus.completed:
        badgeColor = AppColors.success;
        statusText = 'Completed';
        break;
      case CampaignStatus.cancelled:
        badgeColor = AppColors.error;
        statusText = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText.tr,
        style: AppText.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Collaboration status badge widget
  Widget _buildCollaborationStatusBadge(CollaborationStatus status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case CollaborationStatus.matched:
        badgeColor = AppColors.statusMatched;
        statusText = 'Matched';
        break;
      case CollaborationStatus.contractSigned:
        badgeColor = AppColors.statusContractSigned;
        statusText = 'Contract Signed';
        break;
      case CollaborationStatus.productShipped:
        badgeColor = AppColors.statusShipped;
        statusText = 'Product Shipped';
        break;
      case CollaborationStatus.contentInProgress:
        badgeColor = AppColors.statusInProgress;
        statusText = 'Content In Progress';
        break;
      case CollaborationStatus.submitted:
        badgeColor = AppColors.statusSubmitted;
        statusText = 'Submitted';
        break;
      case CollaborationStatus.revision:
        badgeColor = AppColors.statusRevision;
        statusText = 'Revision';
        break;
      case CollaborationStatus.approved:
        badgeColor = AppColors.statusApproved;
        statusText = 'Approved';
        break;
      case CollaborationStatus.paymentReleased:
        badgeColor = AppColors.statusPaymentReleased;
        statusText = 'Payment Released';
        break;
      case CollaborationStatus.completed:
        badgeColor = AppColors.statusCompleted;
        statusText = 'Completed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText.tr,
        style: AppText.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, String campaignId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Campaign'.tr),
        content: Text(
          'Are you sure you want to delete this campaign? This action cannot be undone.'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteCampaign(campaignId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete'.tr),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Show apply confirmation dialog
  void _showApplyConfirmation(BuildContext context, String campaignId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply to Campaign'.tr),
        content: Text(
          'Are you sure you want to apply to this campaign? The brand will be notified of your interest.'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Get dashboard controller to apply to campaign
              final dashboardController = Get.find<CampaignController>();
              dashboardController.applyToCampaign(campaignId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.honeycombDark,
            ),
            child: Text('Apply'.tr),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Show applied creators bottom sheet
  void _showAppliedCreatorsSheet(BuildContext context, CampaignModel campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Applications'.tr,
                    style: AppText.h3,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Creators who have applied to your campaign'.tr,
                    style: AppText.body2.copyWith(
                      color: AppColors.accentGrey,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Applied creators list
                  Expanded(
                    child: campaign.appliedCreators.isEmpty
                        ? Center(
                            child: Text(
                              'No applications yet'.tr,
                              style: AppText.body1.copyWith(
                                color: AppColors.accentGrey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: campaign.appliedCreators.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final String creatorId = campaign.appliedCreators[index];
                              
                              // Find creator in the creators list
                              final UserModel? creator = controller.creators
                                  .firstWhereOrNull((c) => c.id == creatorId);
                              
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.accentLightGrey,
                                  backgroundImage: creator?.profileImageUrl != null
                                      ? NetworkImage(creator!.profileImageUrl!)
                                      : null,
                                  child: creator?.profileImageUrl == null
                                      ? Text(
                                          creator?.fullName?.substring(0, 1) ?? 'C',
                                          style: AppText.body1,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  creator?.fullName ?? 'Creator',
                                  style: AppText.body1,
                                ),
                                subtitle: Text(
                                  creator?.contentType ?? 'Content Creator'.tr,
                                  style: AppText.caption,
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    // Accept creator application
                                    Navigator.of(context).pop();
                                    _showAcceptConfirmation(context, campaign.id, creatorId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.honeycombDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text('Accept'.tr),
                                ),
                                onTap: () {
                                  // View creator profile
                                  // TODO: Implement profile view
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
      },
    );
  }

  // Show accept confirmation dialog
  void _showAcceptConfirmation(BuildContext context, String campaignId, String creatorId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Application'.tr),
        content: Text(
          'Are you sure you want to accept this creator\'s application? You will be matched and can start collaborating.'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Get dashboard controller to accept application
              final dashboardController = Get.find<CampaignController>();
              dashboardController.acceptCreatorApplication(campaignId, creatorId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.honeycombDark,
            ),
            child: Text('Accept'.tr),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Show update status bottom sheet
  void _showUpdateStatusSheet(
    BuildContext context,
    CampaignModel campaign,
    String creatorId,
    CollaborationStatus currentStatus,
  ) {
    final List<CollaborationStatus> allStatuses = [
      CollaborationStatus.matched,
      CollaborationStatus.contractSigned,
      CollaborationStatus.productShipped,
      CollaborationStatus.contentInProgress,
      CollaborationStatus.submitted,
      CollaborationStatus.revision,
      CollaborationStatus.approved,
      CollaborationStatus.paymentReleased,
      CollaborationStatus.completed,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Update Status'.tr,
                style: AppText.h3,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Current status: ${controller.getCollaborationStatusName(currentStatus)}'.tr,
                style: AppText.body2.copyWith(
                  color: AppColors.accentGrey,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Status options
              Expanded(
                child: ListView.builder(
                  itemCount: allStatuses.length,
                  itemBuilder: (context, index) {
                    final CollaborationStatus status = allStatuses[index];
                    final bool isSelected = status == currentStatus;
                    
                    return ListTile(
                      title: Text(
                        controller.getCollaborationStatusName(status).tr,
                        style: AppText.body1.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : null,
                      onTap: () {
                        // Update status
                        Navigator.of(context).pop();
                        
                        if (status != currentStatus) {
                          // Update campaign collaboration status
                          final dashboardController = Get.find<CampaignController>();
                          dashboardController.updateCollaborationStatus(
                            campaign.id,
                            creatorId,
                            status.toString().split('.').last,
                          );
                        }
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

  // Helper method to get status color
  Color _getStatusColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.matched:
        return AppColors.statusMatched;
      case CollaborationStatus.contractSigned:
        return AppColors.statusContractSigned;
      case CollaborationStatus.productShipped:
        return AppColors.statusShipped;
      case CollaborationStatus.contentInProgress:
        return AppColors.statusInProgress;
      case CollaborationStatus.submitted:
        return AppColors.statusSubmitted;
      case CollaborationStatus.revision:
        return AppColors.statusRevision;
      case CollaborationStatus.approved:
        return AppColors.statusApproved;
      case CollaborationStatus.paymentReleased:
        return AppColors.statusPaymentReleased;
      case CollaborationStatus.completed:
        return AppColors.statusCompleted;
    }
  }
}
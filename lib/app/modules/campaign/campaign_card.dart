import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:buzzmatch_v5/app/data/models/campaign_model.dart';
import 'package:buzzmatch_v5/app/theme/app_colors.dart';
import 'package:buzzmatch_v5/app/theme/app_text.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;
  final Widget? trailing;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign header (brand logo, status)
              Row(
                children: [
                  // Brand logo or placeholder
                  Container(
                    width: 40,
                    height: 40,
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

                  // Brand name and campaign status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.brandName,
                          style: AppText.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        _buildStatusBadge(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Campaign name
              Text(
                campaign.campaignName,
                style: AppText.h4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Product name
              Text(
                campaign.productName,
                style: AppText.body2.copyWith(
                  color: AppColors.accentGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Budget and content type
              Row(
                children: [
                  // Budget
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 18,
                          color: AppColors.accentGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${campaign.budget.toStringAsFixed(2)}',
                          style: AppText.body2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content type
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.photo_camera_outlined,
                          size: 18,
                          color: AppColors.accentGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getContentTypeText(),
                          style: AppText.body2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Deadline
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.accentGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${_formatDate(campaign.deadline)}',
                    style: AppText.body2,
                  ),
                ],
              ),

              // Bottom action area (trailing widget if provided)
              if (trailing != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Status badge widget
  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;

    switch (campaign.status) {
      case CampaignStatus.draft:
        badgeColor = Colors.grey;
        statusText = 'Draft'.tr;
        break;
      case CampaignStatus.active:
        badgeColor = AppColors.honeycombMedium;
        statusText = 'Active'.tr;
        break;
      case CampaignStatus.completed:
        badgeColor = AppColors.success;
        statusText = 'Completed'.tr;
        break;
      case CampaignStatus.cancelled:
        badgeColor = AppColors.error;
        statusText = 'Cancelled'.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statusText,
        style: AppText.body3.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to get content type text
  String _getContentTypeText() {
    if (campaign.requiredContentTypes.isEmpty) {
      return 'Multiple'.tr;
    }

    List<String> typeNames = campaign.requiredContentTypes.map((type) {
      switch (type) {
        case ContentType.photos:
          return 'Photos'.tr;
        case ContentType.videos:
          return 'Videos'.tr;
        case ContentType.stories:
          return 'Stories'.tr;
        case ContentType.voiceover:
          return 'Voiceover'.tr;
        case ContentType.multiple:
          return 'Multiple'.tr;
      }
    }).toList();

    return typeNames.join(', ');
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

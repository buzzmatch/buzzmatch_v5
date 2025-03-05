import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../data/models/campaign_model.dart';

class CampaignCreateView extends GetView<CampaignController> {
  const CampaignCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create Campaign'.tr,
          style: AppText.h3,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.accentBlack),
      ),
      body: Obx(() {
        if (controller.isCreating.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.honeycombMedium),
                ),
                const SizedBox(height: 24),
                Text(
                  controller.isUploading.value
                      ? 'Uploading files...'.tr
                      : 'Creating campaign...'.tr,
                  style: AppText.body1,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Name
              _buildSectionTitle('Campaign Name'.tr),
              const SizedBox(height: 8),
              TextField(
                controller: controller.campaignNameController,
                decoration: InputDecoration(
                  hintText: 'Enter campaign name'.tr,
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLength: 60,
              ),
              
              const SizedBox(height: 16),
              
              // Product Name
              _buildSectionTitle('Product/Service Name'.tr),
              const SizedBox(height: 8),
              TextField(
                controller: controller.productNameController,
                decoration: InputDecoration(
                  hintText: 'Enter product or service name'.tr,
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLength: 60,
              ),
              
              const SizedBox(height: 16),
              
              // Budget
              _buildSectionTitle('Budget (USD)'.tr),
              const SizedBox(height: 8),
              TextField(
                controller: controller.budgetController,
                decoration: InputDecoration(
                  hintText: 'Enter budget'.tr,
                  prefixText: '\$',
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: 24),
              
              // Deadline
              _buildSectionTitle('Deadline'.tr),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => controller.selectDeadline(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.accentGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        controller.formattedDeadline(),
                        style: controller.deadline.value == null
                            ? AppText.body1.copyWith(color: AppColors.accentGrey)
                            : AppText.body1,
                      )),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.accentGrey,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Content Types
              _buildSectionTitle('Required Content Types'.tr),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildContentTypeChip(ContentType.photos, 'Photos'.tr, Icons.photo_camera),
                  _buildContentTypeChip(ContentType.videos, 'Videos'.tr, Icons.videocam),
                  _buildContentTypeChip(ContentType.stories, 'Stories'.tr, Icons.view_day),
                  _buildContentTypeChip(ContentType.voiceover, 'Voiceover'.tr, Icons.mic),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Description
              _buildSectionTitle('Campaign Description'.tr),
              const SizedBox(height: 8),
              TextField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  hintText: 'Describe your campaign, requirements, guidelines...'.tr,
                  fillColor: Colors.white,
                  filled: true,
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                maxLength: 1000,
              ),
              
              const SizedBox(height: 24),
              
              // Reference Images
              _buildSectionTitle('Reference Images'.tr),
              const SizedBox(height: 8),
              Text(
                'Upload images to help creators understand your needs'.tr,
                style: AppText.body2.copyWith(color: AppColors.accentGrey),
              ),
              const SizedBox(height: 12),
              _buildReferenceImagesPicker(),
              
              const SizedBox(height: 24),
              
              // Reference Videos
              _buildSectionTitle('Reference Videos'.tr + ' (Optional)'),
              const SizedBox(height: 8),
              Text(
                'Upload videos to help creators understand your needs'.tr,
                style: AppText.body2.copyWith(color: AppColors.accentGrey),
              ),
              const SizedBox(height: 12),
              _buildReferenceVideosPicker(),
              
              const SizedBox(height: 32),
              
              // Create Campaign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.createCampaign,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.honeycombDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Create Campaign'.tr,
                    style: AppText.button,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppText.body1.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Content type chip widget
  Widget _buildContentTypeChip(ContentType type, String label, IconData icon) {
    return Obx(() {
      final bool isSelected = controller.selectedContentTypes.contains(type);
      
      return InkWell(
        onTap: () => controller.toggleContentType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.honeycombDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.honeycombDark : AppColors.accentLightGrey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.accentGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppText.body2.copyWith(
                  color: isSelected ? Colors.white : AppColors.accentBlack,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Reference images picker widget
  Widget _buildReferenceImagesPicker() {
    return Obx(() {
      return Column(
        children: [
          // Image grid
          if (controller.referenceImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: controller.referenceImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        controller.referenceImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Remove button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => controller.removeReferenceImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.error,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          
          const SizedBox(height: 12),
          
          // Add image button
          InkWell(
            onTap: controller.pickReferenceImage,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentLightGrey,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      color: AppColors.honeycombDark,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Image'.tr,
                      style: AppText.body2.copyWith(
                        color: AppColors.honeycombDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Reference videos picker widget
  Widget _buildReferenceVideosPicker() {
    return Obx(() {
      return Column(
        children: [
          // Video list
          if (controller.referenceVideos.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.referenceVideos.length,
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
                          Icons.video_file,
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
                              controller.referenceVideos[index].path.split('/').last,
                              style: AppText.body2.copyWith(
                                color: AppColors.accentGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => controller.removeReferenceVideo(index),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          
          const SizedBox(height: 12),
          
          // Add video button
          InkWell(
            onTap: controller.pickReferenceVideo,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentLightGrey,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_call,
                      color: AppColors.honeycombDark,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Video'.tr,
                      style: AppText.body2.copyWith(
                        color: AppColors.honeycombDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
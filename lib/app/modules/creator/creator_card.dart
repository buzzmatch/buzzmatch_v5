import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:buzzmatch_v5/app/data/models/user_model.dart';
import 'package:buzzmatch_v5/app/theme/app_colors.dart';
import 'package:buzzmatch_v5/app/theme/app_text.dart';

class CreatorCard extends StatelessWidget {
  final UserModel creator;
  final VoidCallback onTap;

  const CreatorCard({
    super.key,
    required this.creator,
    required this.onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Creator image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accentLightGrey,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: creator.profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(creator.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: creator.profileImageUrl == null
                    ? Center(
                        child: Text(
                          creator.fullName?.substring(0, 1) ?? 'C',
                          style: AppText.h1.copyWith(
                            color: AppColors.accentGrey,
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // Creator info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Creator name and rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator.fullName ?? 'Creator',
                          style: AppText.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Rating and completed projects
                        if (creator.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primaryYellow,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                creator.rating!.toStringAsFixed(1),
                                style: AppText.body3,
                              ),
                              const SizedBox(width: 8),
                              if (creator.completedProjects != null)
                                Text(
                                  '${creator.completedProjects} ${'projects'.tr}',
                                  style: AppText.body3.copyWith(
                                    color: AppColors.accentGrey,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),

                    // Creator type and country
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Content type
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: AppColors.accentGrey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  creator.contentType ?? 'Content Creator',
                                  style: AppText.body3.copyWith(
                                    color: AppColors.accentGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Country
                        if (creator.country != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.accentGrey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                creator.country!,
                                style: AppText.body3.copyWith(
                                  color: AppColors.accentGrey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

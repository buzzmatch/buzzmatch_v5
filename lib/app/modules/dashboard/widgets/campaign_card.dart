import 'package:buzzmatch_v5/app/data/models/campaign_model.dart';
import 'package:flutter/material.dart';

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required CampaignModel campaign, required Null Function() onTap, required ElevatedButton trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: Implement widget
      child: const Text('CampaignCard Widget'),
    );
  }
}

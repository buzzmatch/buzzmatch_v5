import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/campaign_model.dart';
import '../../authentication/controllers/auth_controller.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // References to other controllers
  final AuthController _authController = Get.find<AuthController>();

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Tab controller for dashboard
  late TabController tabController;

  // Selected tab index
  RxInt selectedTabIndex = 0.obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Campaign data
  RxList<CampaignModel> campaigns = <CampaignModel>[].obs;

  // Creator data (for brand dashboard)
  RxList<UserModel> creators = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize tab controller
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });

    // Load user data
    _loadUserData();

    // Load campaigns
    _loadCampaigns();

    // If user is a brand, load creators
    if (_authController.userRole.value == 'brand') {
      _loadCreators();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load user data
  Future<void> _loadUserData() async {
    try {
      if (_authController.firebaseUser.value != null) {
        String userId = _authController.firebaseUser.value!.uid;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          currentUser.value = UserModel.fromFirestore(userDoc);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Load campaigns
  Future<void> _loadCampaigns() async {
    try {
      isLoading.value = true;

      Query campaignsQuery;

      if (_authController.userRole.value == 'brand') {
        // Brand sees their own campaigns
        campaignsQuery = _firestore
            .collection('campaigns')
            .where('brandId',
                isEqualTo: _authController.firebaseUser.value?.uid)
            .orderBy('createdAt', descending: true);
      } else {
        // Creator sees campaigns they can apply to or are involved in
        campaignsQuery = _firestore
            .collection('campaigns')
            .where('status', isEqualTo: 'active')
            .orderBy('createdAt', descending: true);
      }

      QuerySnapshot campaignsSnapshot = await campaignsQuery.get();

      List<CampaignModel> campaignsList = campaignsSnapshot.docs
          .map((doc) => CampaignModel.fromFirestore(doc))
          .toList();

      campaigns.value = campaignsList;
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading campaigns: $e');
    }
  }

  // Load creators (for brand dashboard)
  Future<void> _loadCreators() async {
    try {
      Query creatorsQuery = _firestore
          .collection('users')
          .where('role', isEqualTo: 'creator')
          .limit(20);

      QuerySnapshot creatorsSnapshot = await creatorsQuery.get();

      List<UserModel> creatorsList = creatorsSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      creators.value = creatorsList;
    } catch (e) {
      print('Error loading creators: $e');
    }
  }

  // Change tab
  void changeTab(int index) {
    tabController.animateTo(index);
    selectedTabIndex.value = index;
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    await _loadUserData();
    await _loadCampaigns();

    if (_authController.userRole.value == 'brand') {
      await _loadCreators();
    }
  }

  // Get campaigns by status
  List<CampaignModel> getCampaignsByStatus(CampaignStatus status) {
    return campaigns.where((campaign) => campaign.status == status).toList();
  }

  // Get active campaigns for creator
  List<CampaignModel> getActiveCampaignsForCreator() {
    String creatorId = _authController.firebaseUser.value?.uid ?? '';

    return campaigns
        .where((campaign) =>
            campaign.status == CampaignStatus.active &&
            !campaign.invitedCreators.contains(creatorId) &&
            !campaign.appliedCreators.contains(creatorId) &&
            !campaign.matchedCreators.contains(creatorId))
        .toList();
  }

  // Get invited campaigns for creator
  List<CampaignModel> getInvitedCampaignsForCreator() {
    String creatorId = _authController.firebaseUser.value?.uid ?? '';

    return campaigns
        .where((campaign) =>
            campaign.status == CampaignStatus.active &&
            campaign.invitedCreators.contains(creatorId) &&
            !campaign.appliedCreators.contains(creatorId) &&
            !campaign.matchedCreators.contains(creatorId))
        .toList();
  }

  // Get applied campaigns for creator
  List<CampaignModel> getAppliedCampaignsForCreator() {
    String creatorId = _authController.firebaseUser.value?.uid ?? '';

    return campaigns
        .where((campaign) =>
            campaign.appliedCreators.contains(creatorId) &&
            !campaign.matchedCreators.contains(creatorId))
        .toList();
  }

  // Get matched campaigns for creator
  List<CampaignModel> getMatchedCampaignsForCreator() {
    String creatorId = _authController.firebaseUser.value?.uid ?? '';

    return campaigns
        .where((campaign) => campaign.matchedCreators.contains(creatorId))
        .toList();
  }

  // Apply to campaign
  Future<void> applyToCampaign(String campaignId) async {
    try {
      String creatorId = _authController.firebaseUser.value?.uid ?? '';

      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'appliedCreators': FieldValue.arrayUnion([creatorId]),
      });

      // Update local data
      CampaignModel? campaign =
          campaigns.firstWhereOrNull((c) => c.id == campaignId);
      if (campaign != null) {
        CampaignModel updatedCampaign = campaign.addAppliedCreator(creatorId);
        int index = campaigns.indexWhere((c) => c.id == campaignId);
        campaigns[index] = updatedCampaign;
      }

      Get.snackbar(
        'Success',
        'Applied to campaign successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error applying to campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to apply to campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Invite creator to campaign
  Future<void> inviteCreatorToCampaign(
      String campaignId, String creatorId) async {
    try {
      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'invitedCreators': FieldValue.arrayUnion([creatorId]),
      });

      // Update local data
      CampaignModel? campaign =
          campaigns.firstWhereOrNull((c) => c.id == campaignId);
      if (campaign != null) {
        CampaignModel updatedCampaign = campaign.addInvitedCreator(creatorId);
        int index = campaigns.indexWhere((c) => c.id == campaignId);
        campaigns[index] = updatedCampaign;
      }

      Get.snackbar(
        'Success',
        'Invited creator to campaign successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error inviting creator to campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to invite creator to campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Accept creator application
  Future<void> acceptCreatorApplication(
      String campaignId, String creatorId) async {
    try {
      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'matchedCreators': FieldValue.arrayUnion([creatorId]),
        'collaborationStatuses.$creatorId': 'matched',
      });

      // Update local data
      CampaignModel? campaign =
          campaigns.firstWhereOrNull((c) => c.id == campaignId);
      if (campaign != null) {
        CampaignModel updatedCampaign = campaign.matchCreator(creatorId);
        int index = campaigns.indexWhere((c) => c.id == campaignId);
        campaigns[index] = updatedCampaign;
      }

      Get.snackbar(
        'Success',
        'Accepted creator application successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error accepting creator application: $e');
      Get.snackbar(
        'Error',
        'Failed to accept creator application',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update collaboration status
  Future<void> updateCollaborationStatus(
      String campaignId, String creatorId, CollaborationStatus status) async {
    try {
      // Convert collaboration status to string
      String statusString;
      switch (status) {
        case CollaborationStatus.matched:
          statusString = 'matched';
          break;
        case CollaborationStatus.contractSigned:
          statusString = 'contractSigned';
          break;
        case CollaborationStatus.productShipped:
          statusString = 'productShipped';
          break;
        case CollaborationStatus.contentInProgress:
          statusString = 'contentInProgress';
          break;
        case CollaborationStatus.submitted:
          statusString = 'submitted';
          break;
        case CollaborationStatus.revision:
          statusString = 'revision';
          break;
        case CollaborationStatus.approved:
          statusString = 'approved';
          break;
        case CollaborationStatus.paymentReleased:
          statusString = 'paymentReleased';
          break;
        case CollaborationStatus.completed:
          statusString = 'completed';
          break;
      }

      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'collaborationStatuses.$creatorId': statusString,
      });

      // Update local data
      CampaignModel? campaign =
          campaigns.firstWhereOrNull((c) => c.id == campaignId);
      if (campaign != null) {
        CampaignModel updatedCampaign =
            campaign.updateCollaborationStatus(creatorId, status);
        int index = campaigns.indexWhere((c) => c.id == campaignId);
        campaigns[index] = updatedCampaign;
      }

      Get.snackbar(
        'Success',
        'Updated collaboration status successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error updating collaboration status: $e');
      Get.snackbar(
        'Error',
        'Failed to update collaboration status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/firebase_service.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../routes/app_pages.dart';

class CampaignController extends GetxController {
  // Firebase service
  final FirebaseService _firebaseService = FirebaseService.to;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UUID generator
  final Uuid _uuid = const Uuid();

  // Auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Campaign data
  final Rx<CampaignModel?> currentCampaign = Rx<CampaignModel?>(null);
  final RxList<UserModel> creators = <UserModel>[].obs;

  // Form controllers
  late TextEditingController campaignNameController;
  late TextEditingController productNameController;
  late TextEditingController budgetController;
  late TextEditingController descriptionController;

  // Selected content types
  final RxList<ContentType> selectedContentTypes = <ContentType>[].obs;

  // Deadline
  final Rx<DateTime?> deadline = Rx<DateTime?>(null);

  // Reference materials
  final RxList<File> referenceImages = <File>[].obs;
  final RxList<File> referenceVideos = <File>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    campaignNameController = TextEditingController();
    productNameController = TextEditingController();
    budgetController = TextEditingController();
    descriptionController = TextEditingController();

    // Load creators for brand dashboard
    if (_authController.userRole.value == 'brand') {
      loadCreators();
    }
  }

  @override
  void onClose() {
    // Dispose of controllers
    campaignNameController.dispose();
    productNameController.dispose();
    budgetController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Load campaign by ID
  Future<void> loadCampaign(String campaignId) async {
    try {
      isLoading.value = true;

      // Get campaign from Firestore
      CampaignModel? campaign = await _firebaseService.getCampaign(campaignId);

      if (campaign != null) {
        currentCampaign.value = campaign;

        // Load creators involved in this campaign
        await _loadCampaignCreators(campaign);
      } else {
        Get.snackbar(
          'Error',
          'Campaign not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Error loading campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to load campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load creators
  Future<void> loadCreators() async {
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

  // Load creators involved in a campaign
  Future<void> _loadCampaignCreators(CampaignModel campaign) async {
    try {
      // Get all creator IDs from the campaign
      List<String> creatorIds = [
        ...campaign.invitedCreators,
        ...campaign.appliedCreators,
        ...campaign.matchedCreators,
      ];

      // Remove duplicates
      creatorIds = creatorIds.toSet().toList();

      if (creatorIds.isEmpty) {
        return;
      }

      // Load creator data
      List<UserModel> campaignCreators = [];

      for (String creatorId in creatorIds) {
        UserModel? creator = await _firebaseService.getUserModel(creatorId);
        if (creator != null) {
          campaignCreators.add(creator);
        }
      }

      // Update creators list
      creators.value = campaignCreators;
    } catch (e) {
      print('Error loading campaign creators: $e');
    }
  }

  // Format deadline for display
  String formattedDeadline() {
    if (deadline.value == null) {
      return 'Select deadline date'.tr;
    }

    return DateFormat('MMM d, yyyy').format(deadline.value!);
  }

  // Select deadline
  Future<void> selectDeadline(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        deadline.value ?? now.add(const Duration(days: 7));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)), // 2 years from now
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.amber,
            colorScheme: const ColorScheme.light(primary: Colors.amber),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      deadline.value = pickedDate;
    }
  }

  // Toggle content type selection
  void toggleContentType(ContentType type) {
    if (selectedContentTypes.contains(type)) {
      selectedContentTypes.remove(type);
    } else {
      selectedContentTypes.add(type);
    }
  }

  // Define the ContentType enum
  ContentType getContentTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'photos':
        return ContentType.photos;
      case 'videos':
        return ContentType.videos;
      case 'stories':
        return ContentType.stories;
      case 'voiceover':
        return ContentType.voiceover;
      case 'multiple':
        return ContentType.multiple;
      default:
        return ContentType.photos;
    }
  }

  // Pick reference image
  Future<void> pickReferenceImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        referenceImages.add(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove reference image
  void removeReferenceImage(int index) {
    if (index >= 0 && index < referenceImages.length) {
      referenceImages.removeAt(index);
    }
  }

  // Pick reference video
  Future<void> pickReferenceVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        referenceVideos.add(File(result.files.single.path!));
      }
    } catch (e) {
      print('Error picking video: $e');
      Get.snackbar(
        'Error',
        'Failed to pick video',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove reference video
  void removeReferenceVideo(int index) {
    if (index >= 0 && index < referenceVideos.length) {
      referenceVideos.removeAt(index);
    }
  }

  // Create campaign
  Future<void> createCampaign() async {
    // Validate form
    if (!_validateCampaignForm()) {
      return;
    }

    try {
      isCreating.value = true;

      // Get current user info
      String userId = _authController.firebaseUser.value?.uid ?? '';
      String brandName = '';
      String? brandLogoUrl;

      // Get user model data if available
      if (_authController.userRole.value == 'brand') {
        DocumentSnapshot? userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          brandName = userData['companyName'] ?? 'Brand';
          brandLogoUrl = userData['profileImageUrl'];
        }
      }

      // Upload reference materials
      List<String> referenceImageUrls = [];
      List<String> referenceVideoUrls = [];

      // Upload images
      if (referenceImages.isNotEmpty) {
        isUploading.value = true;

        for (File image in referenceImages) {
          String fileName = '${_uuid.v4()}.jpg';
          Reference storageRef =
              _storage.ref().child('campaigns/images/$fileName');

          UploadTask uploadTask = storageRef.putFile(image);
          TaskSnapshot taskSnapshot = await uploadTask;

          String imageUrl = await taskSnapshot.ref.getDownloadURL();
          referenceImageUrls.add(imageUrl);
        }
      }

      // Upload videos
      if (referenceVideos.isNotEmpty) {
        isUploading.value = true;

        for (File video in referenceVideos) {
          String fileName = '${_uuid.v4()}.mp4';
          Reference storageRef =
              _storage.ref().child('campaigns/videos/$fileName');

          UploadTask uploadTask = storageRef.putFile(video);
          TaskSnapshot taskSnapshot = await uploadTask;

          String videoUrl = await taskSnapshot.ref.getDownloadURL();
          referenceVideoUrls.add(videoUrl);
        }
      }

      isUploading.value = false;

      // Create campaign data for Firestore
      Map<String, dynamic> campaignData = {
        'brandId': userId,
        'brandName': brandName,
        'brandLogoUrl': brandLogoUrl,
        'campaignName': campaignNameController.text.trim(),
        'productName': productNameController.text.trim(),
        'requiredContentTypes': selectedContentTypes
            .map((type) => type.toString().split('.').last)
            .toList(),
        'description': descriptionController.text.trim(),
        'budget': double.parse(budgetController.text.trim()),
        'deadline': deadline.value,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'referenceImageUrls': referenceImageUrls,
        'referenceVideoUrls': referenceVideoUrls,
        'invitedCreators': [],
        'appliedCreators': [],
        'matchedCreators': [],
        'collaborationStatuses': {},
      };

      // Save to Firestore
      DocumentReference docRef =
          await _firestore.collection('campaigns').add(campaignData);
      String campaignId = docRef.id;

      isCreating.value = false;

      // Clear form
      _clearCampaignForm();

      // Show success message
      Get.snackbar(
        'Success',
        'Campaign created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );

      // Navigate to campaign detail
      Get.offNamed(
        Routes.CAMPAIGN_DETAIL,
        arguments: {'campaignId': campaignId},
      );
    } catch (e) {
      isCreating.value = false;
      isUploading.value = false;

      print('Error creating campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to create campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Validate campaign form
  bool _validateCampaignForm() {
    if (campaignNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a campaign name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (productNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a product name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (budgetController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a budget',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      double budget = double.parse(budgetController.text.trim());
      if (budget <= 0) {
        throw Exception('Budget must be greater than zero');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Please enter a valid budget amount',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (deadline.value == null) {
      Get.snackbar(
        'Error',
        'Please select a deadline',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedContentTypes.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one content type',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (referenceImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one reference image',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  // Clear campaign form
  void _clearCampaignForm() {
    campaignNameController.clear();
    productNameController.clear();
    budgetController.clear();
    descriptionController.clear();
    selectedContentTypes.clear();
    deadline.value = null;
    referenceImages.clear();
    referenceVideos.clear();
  }

  // Apply to campaign (for creators)
  Future<void> applyToCampaign(String campaignId) async {
    try {
      isLoading.value = true;
      String creatorId = _authController.firebaseUser.value?.uid ?? '';

      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'appliedCreators': FieldValue.arrayUnion([creatorId]),
      });

      // Update local data if needed
      if (currentCampaign.value?.id == campaignId) {
        CampaignModel updatedCampaign =
            currentCampaign.value!.addAppliedCreator(creatorId);
        currentCampaign.value = updatedCampaign;
      }

      // Update dashboard if needed
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshData();
      }

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Applied to campaign successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
    } catch (e) {
      isLoading.value = false;
      print('Error applying to campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to apply to campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Accept creator application (for brands)
  Future<void> acceptCreatorApplication(
      String campaignId, String creatorId) async {
    try {
      isLoading.value = true;

      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'matchedCreators': FieldValue.arrayUnion([creatorId]),
        'collaborationStatuses.$creatorId': 'matched',
      });

      // Update local data if needed
      if (currentCampaign.value?.id == campaignId) {
        CampaignModel updatedCampaign =
            currentCampaign.value!.matchCreator(creatorId);
        currentCampaign.value = updatedCampaign;
      }

      // Update dashboard if needed
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshData();
      }

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Accepted creator application successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
    } catch (e) {
      isLoading.value = false;
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
    String campaignId,
    String creatorId,
    String status,
  ) async {
    try {
      isLoading.value = true;

      // Update Firestore
      await _firestore.collection('campaigns').doc(campaignId).update({
        'collaborationStatuses.$creatorId': status,
      });

      // Update local data if needed
      if (currentCampaign.value?.id == campaignId) {
        // Get the current collaboration statuses
        Map<String, CollaborationStatus> currentStatuses =
            Map<String, CollaborationStatus>.from(
                currentCampaign.value!.collaborationStatuses);

        // Update the status for this creator
        CollaborationStatus newStatus;
        switch (status) {
          case 'matched':
            newStatus = CollaborationStatus.matched;
            break;
          case 'contractSigned':
            newStatus = CollaborationStatus.contractSigned;
            break;
          case 'productShipped':
            newStatus = CollaborationStatus.productShipped;
            break;
          case 'contentInProgress':
            newStatus = CollaborationStatus.contentInProgress;
            break;
          case 'submitted':
            newStatus = CollaborationStatus.submitted;
            break;
          case 'revision':
            newStatus = CollaborationStatus.revision;
            break;
          case 'approved':
            newStatus = CollaborationStatus.approved;
            break;
          case 'paymentReleased':
            newStatus = CollaborationStatus.paymentReleased;
            break;
          case 'completed':
            newStatus = CollaborationStatus.completed;
            break;
          default:
            newStatus = CollaborationStatus.matched;
        }

        currentStatuses[creatorId] = newStatus;

        // Create updated campaign with new statuses
        CampaignModel updatedCampaign = CampaignModel(
          id: currentCampaign.value!.id,
          brandId: currentCampaign.value!.brandId,
          brandName: currentCampaign.value!.brandName,
          brandLogoUrl: currentCampaign.value!.brandLogoUrl,
          campaignName: currentCampaign.value!.campaignName,
          productName: currentCampaign.value!.productName,
          requiredContentTypes: currentCampaign.value!.requiredContentTypes,
          description: currentCampaign.value!.description,
          budget: currentCampaign.value!.budget,
          deadline: currentCampaign.value!.deadline,
          createdAt: currentCampaign.value!.createdAt,
          status: currentCampaign.value!.status,
          referenceImageUrls: currentCampaign.value!.referenceImageUrls,
          referenceVideoUrls: currentCampaign.value!.referenceVideoUrls,
          invitedCreators: currentCampaign.value!.invitedCreators,
          appliedCreators: currentCampaign.value!.appliedCreators,
          matchedCreators: currentCampaign.value!.matchedCreators,
          collaborationStatuses: currentStatuses,
        );

        currentCampaign.value = updatedCampaign;
      }

      // Update dashboard if needed
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshData();
      }

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Updated collaboration status successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
    } catch (e) {
      isLoading.value = false;
      print('Error updating collaboration status: $e');
      Get.snackbar(
        'Error',
        'Failed to update collaboration status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete campaign
  Future<void> deleteCampaign(String campaignId) async {
    try {
      isLoading.value = true;

      // Delete from Firestore
      await _firestore.collection('campaigns').doc(campaignId).delete();

      // Update dashboard if needed
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshData();
      }

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Campaign deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );

      // Navigate back to dashboard
      Get.offNamed(Routes.BRAND_DASHBOARD);
    } catch (e) {
      isLoading.value = false;
      print('Error deleting campaign: $e');
      Get.snackbar(
        'Error',
        'Failed to delete campaign',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get content type name
  String getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.photos:
        return 'Photos';
      case ContentType.videos:
        return 'Videos';
      case ContentType.stories:
        return 'Stories';
      case ContentType.voiceover:
        return 'Voiceover';
      case ContentType.multiple:
        return 'Multiple';
      default:
        return 'Unknown';
    }
  }

  // Get collaboration status name
  String getCollaborationStatusName(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.matched:
        return 'Matched';
      case CollaborationStatus.contractSigned:
        return 'Contract Signed';
      case CollaborationStatus.productShipped:
        return 'Product Shipped';
      case CollaborationStatus.contentInProgress:
        return 'Content In Progress';
      case CollaborationStatus.submitted:
        return 'Submitted';
      case CollaborationStatus.revision:
        return 'Revision';
      case CollaborationStatus.approved:
        return 'Approved';
      case CollaborationStatus.paymentReleased:
        return 'Payment Released';
      case CollaborationStatus.completed:
        return 'Completed';
    }
  }

  // Get collaboration status from string
  CollaborationStatus getCollaborationStatusFromString(String statusString) {
    switch (statusString) {
      case 'matched':
        return CollaborationStatus.matched;
      case 'contractSigned':
        return CollaborationStatus.contractSigned;
      case 'productShipped':
        return CollaborationStatus.productShipped;
      case 'contentInProgress':
        return CollaborationStatus.contentInProgress;
      case 'submitted':
        return CollaborationStatus.submitted;
      case 'revision':
        return CollaborationStatus.revision;
      case 'approved':
        return CollaborationStatus.approved;
      case 'paymentReleased':
        return CollaborationStatus.paymentReleased;
      case 'completed':
        return CollaborationStatus.completed;
      default:
        return CollaborationStatus.matched;
    }
  }
}

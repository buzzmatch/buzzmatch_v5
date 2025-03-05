import 'package:cloud_firestore/cloud_firestore.dart';

// Campaign status enum
enum CampaignStatus {
  draft,
  active,
  completed,
  cancelled,
}

// Collaboration status enum
enum CollaborationStatus {
  matched,
  contractSigned,
  productShipped,
  contentInProgress,
  submitted,
  revision,
  approved,
  paymentReleased,
  completed,
}

// Content type enum
enum ContentType {
  photos,
  videos,
  stories,
  voiceover,
  multiple,
}

class CampaignModel {
  final String id;
  final String brandId;
  final String brandName;
  final String? brandLogoUrl;
  final String campaignName;
  final String productName;
  final List<ContentType> requiredContentTypes;
  final String description;
  final double budget;
  final DateTime deadline;
  final DateTime createdAt;
  final CampaignStatus status;
  final List<String> referenceImageUrls;
  final List<String> referenceVideoUrls;
  final List<String> invitedCreators;
  final List<String> appliedCreators;
  final List<String> matchedCreators;
  final Map<String, CollaborationStatus> collaborationStatuses;

  CampaignModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    this.brandLogoUrl,
    required this.campaignName,
    required this.productName,
    required this.requiredContentTypes,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.createdAt,
    required this.status,
    required this.referenceImageUrls,
    required this.referenceVideoUrls,
    required this.invitedCreators,
    required this.appliedCreators,
    required this.matchedCreators,
    required this.collaborationStatuses,
  });

  // Convert Firestore document to CampaignModel
  factory CampaignModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse content types
    List<ContentType> contentTypes = [];
    if (data['requiredContentTypes'] != null) {
      for (var type in data['requiredContentTypes']) {
        switch (type) {
          case 'photos':
            contentTypes.add(ContentType.photos);
            break;
          case 'videos':
            contentTypes.add(ContentType.videos);
            break;
          case 'stories':
            contentTypes.add(ContentType.stories);
            break;
          case 'voiceover':
            contentTypes.add(ContentType.voiceover);
            break;
          case 'multiple':
            contentTypes.add(ContentType.multiple);
            break;
        }
      }
    }

    // Parse collaboration statuses
    Map<String, CollaborationStatus> collaborationStatuses = {};
    if (data['collaborationStatuses'] != null) {
      Map<String, dynamic> statusMap = data['collaborationStatuses'];
      statusMap.forEach((creatorId, statusString) {
        CollaborationStatus status;
        switch (statusString) {
          case 'matched':
            status = CollaborationStatus.matched;
            break;
          case 'contractSigned':
            status = CollaborationStatus.contractSigned;
            break;
          case 'productShipped':
            status = CollaborationStatus.productShipped;
            break;
          case 'contentInProgress':
            status = CollaborationStatus.contentInProgress;
            break;
          case 'submitted':
            status = CollaborationStatus.submitted;
            break;
          case 'revision':
            status = CollaborationStatus.revision;
            break;
          case 'approved':
            status = CollaborationStatus.approved;
            break;
          case 'paymentReleased':
            status = CollaborationStatus.paymentReleased;
            break;
          case 'completed':
            status = CollaborationStatus.completed;
            break;
          default:
            status = CollaborationStatus.matched;
        }
        collaborationStatuses[creatorId] = status;
      });
    }

    // Parse campaign status
    CampaignStatus campaignStatus;
    switch (data['status']) {
      case 'draft':
        campaignStatus = CampaignStatus.draft;
        break;
      case 'active':
        campaignStatus = CampaignStatus.active;
        break;
      case 'completed':
        campaignStatus = CampaignStatus.completed;
        break;
      case 'cancelled':
        campaignStatus = CampaignStatus.cancelled;
        break;
      default:
        campaignStatus = CampaignStatus.draft;
    }

    return CampaignModel(
      id: doc.id,
      brandId: data['brandId'] ?? '',
      brandName: data['brandName'] ?? '',
      brandLogoUrl: data['brandLogoUrl'],
      campaignName: data['campaignName'] ?? '',
      productName: data['productName'] ?? '',
      requiredContentTypes: contentTypes,
      description: data['description'] ?? '',
      budget: (data['budget'] ?? 0).toDouble(),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: campaignStatus,
      referenceImageUrls: data['referenceImageUrls'] != null
          ? List<String>.from(data['referenceImageUrls'])
          : [],
      referenceVideoUrls: data['referenceVideoUrls'] != null
          ? List<String>.from(data['referenceVideoUrls'])
          : [],
      invitedCreators: data['invitedCreators'] != null
          ? List<String>.from(data['invitedCreators'])
          : [],
      appliedCreators: data['appliedCreators'] != null
          ? List<String>.from(data['appliedCreators'])
          : [],
      matchedCreators: data['matchedCreators'] != null
          ? List<String>.from(data['matchedCreators'])
          : [],
      collaborationStatuses: collaborationStatuses,
    );
  }

  // Convert CampaignModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert content types to strings
    List<String> contentTypeStrings = requiredContentTypes.map((type) {
      switch (type) {
        case ContentType.photos:
          return 'photos';
        case ContentType.videos:
          return 'videos';
        case ContentType.stories:
          return 'stories';
        case ContentType.voiceover:
          return 'voiceover';
        case ContentType.multiple:
          return 'multiple';
      }
    }).toList();

    // Convert campaign status to string
    String statusString;
    switch (status) {
      case CampaignStatus.draft:
        statusString = 'draft';
        break;
      case CampaignStatus.active:
        statusString = 'active';
        break;
      case CampaignStatus.completed:
        statusString = 'completed';
        break;
      case CampaignStatus.cancelled:
        statusString = 'cancelled';
        break;
    }

    // Convert collaboration statuses to strings
    Map<String, String> collaborationStatusStrings = {};
    collaborationStatuses.forEach((creatorId, status) {
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
      collaborationStatusStrings[creatorId] = statusString;
    });

    return {
      'brandId': brandId,
      'brandName': brandName,
      'brandLogoUrl': brandLogoUrl,
      'campaignName': campaignName,
      'productName': productName,
      'requiredContentTypes': contentTypeStrings,
      'description': description,
      'budget': budget,
      'deadline': deadline,
      'createdAt': createdAt,
      'status': statusString,
      'referenceImageUrls': referenceImageUrls,
      'referenceVideoUrls': referenceVideoUrls,
      'invitedCreators': invitedCreators,
      'appliedCreators': appliedCreators,
      'matchedCreators': matchedCreators,
      'collaborationStatuses': collaborationStatusStrings,
    };
  }

  // Create a copy of CampaignModel with updated fields
  CampaignModel copyWith({
    String? brandName,
    String? brandLogoUrl,
    String? campaignName,
    String? productName,
    List<ContentType>? requiredContentTypes,
    String? description,
    double? budget,
    DateTime? deadline,
    CampaignStatus? status,
    List<String>? referenceImageUrls,
    List<String>? referenceVideoUrls,
    List<String>? invitedCreators,
    List<String>? appliedCreators,
    List<String>? matchedCreators,
    Map<String, CollaborationStatus>? collaborationStatuses,
  }) {
    return CampaignModel(
      id: id,
      brandId: brandId,
      brandName: brandName ?? this.brandName,
      brandLogoUrl: brandLogoUrl ?? this.brandLogoUrl,
      campaignName: campaignName ?? this.campaignName,
      productName: productName ?? this.productName,
      requiredContentTypes: requiredContentTypes ?? this.requiredContentTypes,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      status: status ?? this.status,
      referenceImageUrls: referenceImageUrls ?? this.referenceImageUrls,
      referenceVideoUrls: referenceVideoUrls ?? this.referenceVideoUrls,
      invitedCreators: invitedCreators ?? this.invitedCreators,
      appliedCreators: appliedCreators ?? this.appliedCreators,
      matchedCreators: matchedCreators ?? this.matchedCreators,
      collaborationStatuses:
          collaborationStatuses ?? this.collaborationStatuses,
    );
  }

  // Helper method to add a creator to invitedCreators
  CampaignModel addInvitedCreator(String creatorId) {
    List<String> updatedInvitedCreators = List.from(invitedCreators);
    if (!updatedInvitedCreators.contains(creatorId)) {
      updatedInvitedCreators.add(creatorId);
    }
    return copyWith(invitedCreators: updatedInvitedCreators);
  }

  // Helper method to add a creator to appliedCreators
  CampaignModel addAppliedCreator(String creatorId) {
    List<String> updatedAppliedCreators = List.from(appliedCreators);
    if (!updatedAppliedCreators.contains(creatorId)) {
      updatedAppliedCreators.add(creatorId);
    }
    return copyWith(appliedCreators: updatedAppliedCreators);
  }

  // Helper method to add a creator to matchedCreators and set initial collaboration status
  CampaignModel matchCreator(String creatorId) {
    List<String> updatedMatchedCreators = List.from(matchedCreators);
    if (!updatedMatchedCreators.contains(creatorId)) {
      updatedMatchedCreators.add(creatorId);
    }

    Map<String, CollaborationStatus> updatedStatuses =
        Map.from(collaborationStatuses);
    updatedStatuses[creatorId] = CollaborationStatus.matched;

    return copyWith(
      matchedCreators: updatedMatchedCreators,
      collaborationStatuses: updatedStatuses,
    );
  }

  // Helper method to update collaboration status
  CampaignModel updateCollaborationStatus(
      String creatorId, CollaborationStatus status) {
    Map<String, CollaborationStatus> updatedStatuses =
        Map.from(collaborationStatuses);
    updatedStatuses[creatorId] = status;

    return copyWith(collaborationStatuses: updatedStatuses);
  }
}

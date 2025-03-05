import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? email;
  final String? role;
  final String? companyName;
  final String? fullName;
  final String? phone;
  final String? businessCategory;
  final String? contentType;
  final String? country;
  final String? profileImageUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    this.email,
    this.role,
    this.companyName,
    this.fullName,
    this.phone,
    this.businessCategory,
    this.contentType,
    this.country,
    this.profileImageUrl,
    this.createdAt,
  });

  // Factory method to create from Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'],
      role: data['role'],
      companyName: data['companyName'],
      fullName: data['fullName'],
      phone: data['phone'],
      businessCategory: data['businessCategory'],
      contentType: data['contentType'],
      country: data['country'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  get rating => null;

  get completedProjects => null;

  get portfolioUrls => null;

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'companyName': companyName,
      'fullName': fullName,
      'phone': phone,
      'businessCategory': businessCategory,
      'contentType': contentType,
      'country': country,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}

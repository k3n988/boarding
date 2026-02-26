import 'package:cloud_firestore/cloud_firestore.dart';

class RequirementModel {
  final String userId;
  final bool isIdentityVerified;
  final String? communityStandingUrl; // e.g., uploaded Barangay Clearance URL
  final String? ownershipUrl;         // e.g., uploaded Utility Bill URL
  final bool isRealityCheckScheduled;
  final String status;
  
  // Optional: A place to hold the nested reality check schedule details if we need them later
  final Map<String, dynamic>? realityCheckDetails; 

  RequirementModel({
    required this.userId,
    this.isIdentityVerified = false,
    this.communityStandingUrl,
    this.ownershipUrl,
    this.isRealityCheckScheduled = false,
    this.status = 'pending',
    this.realityCheckDetails,
  });

  // --- ADDED: Factory to create the Model from Firestore Data ---
  factory RequirementModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RequirementModel(
      userId: documentId,
      // We check for the boolean flag OR the timestamp flag set by verification_step.dart
      isIdentityVerified: map['isIdentityVerified'] == true || map.containsKey('kycCompletedAt'),
      
      // Map the specific URL fields saved by verification_step.dart
      communityStandingUrl: map['communityStandingUrl'] ?? map['barangayClearanceUrl'],
      ownershipUrl: map['ownershipUrl'] ?? map['ownershipProofUrl'],
      
      // We check for the boolean flag OR the nested object set by verification_step.dart
      isRealityCheckScheduled: map['isRealityCheckScheduled'] == true || map.containsKey('realityCheck'),
      
      status: map['status'] ?? 'pending',
      realityCheckDetails: map['realityCheck'] as Map<String, dynamic>?,
    );
  }

  // Convert to Map for Firestore (Saving the final submission)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'isIdentityVerified': isIdentityVerified,
      'communityStandingUrl': communityStandingUrl,
      'ownershipUrl': ownershipUrl,
      'isRealityCheckScheduled': isRealityCheckScheduled,
      'status': status,
      'submittedAt': FieldValue.serverTimestamp(),
    };
  }
}
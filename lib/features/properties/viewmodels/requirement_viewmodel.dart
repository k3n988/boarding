import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/requirement_model.dart';

class RequirementViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Track the progress of individual steps
  bool _isIdentityVerified = false;
  bool get isIdentityVerified => _isIdentityVerified;

  String? _communityDocUrl;
  String? get communityDocUrl => _communityDocUrl;

  String? _ownershipDocUrl;
  String? get ownershipDocUrl => _ownershipDocUrl;

  bool _isRealityCheckScheduled = false;
  bool get isRealityCheckScheduled => _isRealityCheckScheduled;

  // Optional: Enforce that all steps must be done before submission
  bool get canSubmit => _isIdentityVerified && 
                        _communityDocUrl != null && 
                        _ownershipDocUrl != null && 
                        _isRealityCheckScheduled;

  // --- Constructor: Check existing progress when loaded ---
  RequirementViewModel() {
    checkExistingVerification();
  }

  // --- Fetch Existing Progress from Firestore ---
  Future<void> checkExistingVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    
    // Use addPostFrameCallback to avoid calling notifyListeners() while the widget tree is still building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('host_verifications')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        
        // Map the fields we saved in verification_step.dart back to the state
        _isIdentityVerified = data.containsKey('kycCompletedAt') || data['isIdentityVerified'] == true;
        _communityDocUrl = data['barangayClearanceUrl'] ?? data['communityStandingUrl'];
        _ownershipDocUrl = data['ownershipProofUrl'] ?? data['ownershipUrl'];
        _isRealityCheckScheduled = data.containsKey('realityCheck') || data['isRealityCheckScheduled'] == true;
      }
    } catch (e) {
      debugPrint('Error fetching verification status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Methods to update UI state when a step is completed ---
  void setIdentityVerified() {
    _isIdentityVerified = true;
    notifyListeners();
  }

  void setCommunityDocUrl(String url) {
    _communityDocUrl = url;
    notifyListeners();
  }

  void setOwnershipDocUrl(String url) {
    _ownershipDocUrl = url;
    notifyListeners();
  }

  void setRealityCheckScheduled() {
    _isRealityCheckScheduled = true;
    notifyListeners();
  }

  // --- Firebase Submission ---
  Future<void> submitApplication() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      // Create the model
      final requirement = RequirementModel(
        userId: user.uid,
        isIdentityVerified: _isIdentityVerified,
        communityStandingUrl: _communityDocUrl,
        ownershipUrl: _ownershipDocUrl,
        isRealityCheckScheduled: _isRealityCheckScheduled,
        status: 'pending_review',
      );

      // Save to Firestore. We use merge: true so we don't accidentally delete 
      // the actual nested image URLs that verification_step.dart just uploaded!
      await FirebaseFirestore.instance
          .collection('host_verifications')
          .doc(user.uid)
          .set(requirement.toMap(), SetOptions(merge: true));

    } catch (e) {
      rethrow; // Let the UI handle the error display
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
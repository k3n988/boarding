import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Ensure this path matches where your UserModel is stored
import '../../auth/data/models/user_model.dart'; 

class AccountViewModel extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── ADDED VARIABLES FOR AVATAR FIX ───
  bool _isPickerActive = false; // Lock to prevent "already_active" error
  String? _cachedPhotoUrl;      // Local cache to prevent image disappearing on tab switch

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Bulletproof Data Getters ───
  
  // 1. Tries Firestore real name first, then Auth display name, then defaults to 'User'
  String get firstName {
    String nameToReturn = '';

    if (_user != null && _user!.firstName.isNotEmpty) {
      nameToReturn = _user!.firstName;
    } else {
      final authName = FirebaseAuth.instance.currentUser?.displayName;
      if (authName != null && authName.isNotEmpty) {
        nameToReturn = authName.split(' ').first;
      }
    }

    // Capitalizes the first letter (e.g., 'khenje' -> 'Khenje')
    if (nameToReturn.isNotEmpty) {
      return nameToReturn[0].toUpperCase() + nameToReturn.substring(1);
    }

    return ''; // AccountScreen handles the final fallback to 'User'
  }

  // 2. Tries Firestore email first, then GUARANTEES email directly from FirebaseAuth
  String get email {
    if (_user != null && _user!.email.isNotEmpty) {
      return _user!.email;
    }
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  // 3. Gets the Photo URL directly from Firebase Auth (with cache fallback)
  String? get photoUrl => _cachedPhotoUrl ?? FirebaseAuth.instance.currentUser?.photoURL;

  bool get isLandlord => _user?.role == 'landlord';
  String get vipTier => 'Bronze';
  String get cashbackAmount => '₱ 0.00';
  String get language => 'English';
  String get priceDisplay => 'Base per night';
  String get appVersion => '1.0.0';

  // ─── Profile Loading ───
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners(); // Tell UI to load

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          _user = UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners(); // Refresh UI with the real fetched data
    }
  }

  // ─── Image Uploading Method ───
  Future<void> uploadProfilePicture() async {
    // Prevent opening the picker multiple times
    if (_isPickerActive || _isLoading) return;

    try {
      _isPickerActive = true; // Lock the picker

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _isPickerActive = false;
        return;
      }

      // 1. Pick an image from the gallery
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compresses the image to save data
      );

      _isPickerActive = false; // Unlock the picker after selection

      if (image == null) return; // User canceled the picker

      _isLoading = true;
      notifyListeners();

      // 2. Create a reference in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${currentUser.uid}.jpg');

      // 3. Upload the file
      final File imageFile = File(image.path);
      await storageRef.putFile(imageFile);

      // 4. Get the new secure download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // 5. Update Firebase Auth with the new photo URL
      await currentUser.updatePhotoURL(downloadUrl);

      // 6. Update Firestore users collection (Optional but recommended)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'photoUrl': downloadUrl}, SetOptions(merge: true));

      // Save to local cache and reload Auth to prevent UI blink on tab changes
      _cachedPhotoUrl = downloadUrl;
      await currentUser.reload(); 

      // Reload the profile to show the new image
      await loadProfile();

    } catch (e) {
      _errorMessage = 'Failed to upload image: $e';
      debugPrint(_errorMessage);
      _isPickerActive = false; // Ensure unlocked on error
      _isLoading = false;
      notifyListeners();
    }
  }
}
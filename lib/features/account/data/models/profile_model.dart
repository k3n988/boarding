class ProfileModel {
  final String uid;
  final String email;
  final String name;       
  final String? avatarUrl; // Renamed from photoUrl for clarity
  final String? phoneNumber;
  final String vipTier;   
  final bool isLandlord;

  ProfileModel({
    required this.uid,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.phoneNumber,
    this.vipTier = 'Standard', 
    this.isLandlord = false,
  });

  // copyWith helps us easily update just the avatar later in the ViewModel
  ProfileModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? avatarUrl,
    String? phoneNumber,
    String? vipTier,
    bool? isLandlord,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vipTier: vipTier ?? this.vipTier,
      isLandlord: isLandlord ?? this.isLandlord,
    );
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProfileModel(
      uid: documentId,
      email: map['email'] ?? '',
      name: map['name'] ?? 'User',
      // Added fallback to 'photoUrl' just in case you have existing old data in Firestore
      avatarUrl: map['avatarUrl'] ?? map['photoUrl'], 
      phoneNumber: map['phoneNumber'],
      vipTier: map['vipTier'] ?? 'Standard',
      isLandlord: map['isLandlord'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'vipTier': vipTier,
      'isLandlord': isLandlord,
    };
  }
}
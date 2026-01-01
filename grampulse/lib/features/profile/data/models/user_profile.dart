class UserProfile {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String role;
  final String language;
  final String? profileImageUrl;
  final String kycStatus;
  final bool isVerified;
  final bool isProfileComplete;
  final String? wardVillageId;
  final String? department;
  final String? designation;
  final int escalationLevel;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    required this.role,
    required this.language,
    this.profileImageUrl,
    required this.kycStatus,
    required this.isVerified,
    required this.isProfileComplete,
    this.wardVillageId,
    this.department,
    this.designation,
    required this.escalationLevel,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String,
      language: json['language'] as String? ?? 'en',
      profileImageUrl: json['profileImageUrl'] as String?,
      kycStatus: json['kycStatus'] as String,
      isVerified: json['isVerified'] as bool,
      isProfileComplete: json['isProfileComplete'] as bool,
      wardVillageId: json['wardVillageId'] as String?,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      escalationLevel: json['escalationLevel'] as int? ?? 1,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'role': role,
      'language': language,
      'profileImageUrl': profileImageUrl,
      'kycStatus': kycStatus,
      'isVerified': isVerified,
      'isProfileComplete': isProfileComplete,
      'wardVillageId': wardVillageId,
      'department': department,
      'designation': designation,
      'escalationLevel': escalationLevel,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? role,
    String? language,
    String? profileImageUrl,
    String? kycStatus,
    bool? isVerified,
    bool? isProfileComplete,
    String? wardVillageId,
    String? department,
    String? designation,
    int? escalationLevel,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      language: language ?? this.language,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      kycStatus: kycStatus ?? this.kycStatus,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      wardVillageId: wardVillageId ?? this.wardVillageId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      escalationLevel: escalationLevel ?? this.escalationLevel,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, phone: $phone, name: $name, email: $email, role: $role, isProfileComplete: $isProfileComplete}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

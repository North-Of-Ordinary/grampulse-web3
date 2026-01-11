class ProfileUpdateRequest {
  final String? name;
  final String? email;
  final String? language;
  final String? department;
  final String? designation;

  const ProfileUpdateRequest({
    this.name,
    this.email,
    this.language,
    this.department,
    this.designation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (language != null) data['language'] = language;
    if (department != null) data['department'] = department;
    if (designation != null) data['designation'] = designation;
    
    return data;
  }

  ProfileUpdateRequest copyWith({
    String? name,
    String? email,
    String? language,
    String? department,
    String? designation,
  }) {
    return ProfileUpdateRequest(
      name: name ?? this.name,
      email: email ?? this.email,
      language: language ?? this.language,
      department: department ?? this.department,
      designation: designation ?? this.designation,
    );
  }

  @override
  String toString() {
    return 'ProfileUpdateRequest{name: $name, email: $email, language: $language, department: $department, designation: $designation}';
  }
}

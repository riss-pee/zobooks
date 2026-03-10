class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String role;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    required this.role,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // API returns `username`, fallback to `email` if it ever exists
    final emailStr = json['username'] ?? json['email'] ?? '';
    
    // Extract role from array
    String roleStr = 'reader';
    if (json['roles'] != null && json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      roleStr = json['roles'][0].toString();
    } else if (json['role'] != null) {
      roleStr = json['role'];
    }

    return UserModel(
      id: json['id'] ?? '',
      email: emailStr, // Keep internal field as email/username 
      name: json['full_name'] ?? json['name'],
      phone: json['phone'],
      role: roleStr,
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': email, // Output back as username
      'full_name': name,
      'phone': phone,
      'roles': [role],
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}



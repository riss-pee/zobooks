class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;
  final bool isVerified;
  final String? profileImage;
  final String? bio;
  final String? dob;
  final String? gender;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.isVerified,
    this.profileImage,
    this.bio,
    this.dob,
    this.gender,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // The API wraps the core user details in a 'user' object:
    // { "id": "...", "user": { "email": "...", "username": "...", ... }, "avatar": "..." }
    final userJson = json['user'] as Map<String, dynamic>? ?? json;

    return UserProfileModel(
      id: json['id']?.toString() ?? userJson['id']?.toString() ?? '',
      email: userJson['email']?.toString() ?? '',
      username: userJson['username']?.toString() ?? '',
      firstName: userJson['first_name']?.toString() ?? '',
      lastName: userJson['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(), // Handle if phone is in outer payload
      isVerified: userJson['is_verified'] ?? false,
      profileImage: json['avatar']?.toString() ?? json['profile_image']?.toString(),
      bio: json['bio']?.toString(),
      dob: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}

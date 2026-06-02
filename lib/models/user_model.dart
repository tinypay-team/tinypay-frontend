class UserModel {
  final String name;
  final String email;
  final String avatar;

  const UserModel({
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      name: json['nickname'] ?? '',
      email: json['email'] ?? '',
      avatar: json['profileImage'] ?? '',
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? avatar,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }
}
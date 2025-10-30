class User {
  String id;
  String username;
  String email;
  String passwordHash;
  String image; // base64 string

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'image': image,
    };
  }

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      image: map['image'] ?? '',
    );
  }
}

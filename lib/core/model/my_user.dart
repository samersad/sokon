class MyUser {
  static const String collectionName = "users";
  String id;
  String name;
  String email;
  String? role; // 'owner' or 'client'
  String? photoUrl;
  DateTime? createdAt;

  MyUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photoUrl,
    this.createdAt,
  });

  MyUser.fromFireStore(Map<String, dynamic> data)
      : this(
          id: data["id"],
          name: data["name"],
          email: data["email"],
          role: data["role"],
          photoUrl: data["photoUrl"],
          createdAt: data["createdAt"] != null ? DateTime.parse(data["createdAt"]) : null,
        );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
      "photoUrl": photoUrl,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

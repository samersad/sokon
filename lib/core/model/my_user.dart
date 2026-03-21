class MyUser {
  static const String collectionName = "users";
  String id;
  String name;
  String email;
  String? role; // 'owner' or 'client'
  String? photoUrl;

  MyUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photoUrl,
  });

  MyUser.fromFireStore(Map<String, dynamic> data)
      : this(
          id: data["id"],
          name: data["name"],
          email: data["email"],
          role: data["role"],
          photoUrl: data["photoUrl"],
        );

  Map<String, dynamic> toFireStore() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
      "photoUrl": photoUrl,
    };
  }
}

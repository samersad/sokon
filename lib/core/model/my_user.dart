class MyUser {
  static const String collectionName = "users";
  String id;
  String name;
  String email;
  String? college;
  String? phoneNumber;
  String? gender;
  String? role; // 'owner' or 'client'
  String? photoUrl;
  String? fcmToken;
  DateTime? createdAt;

  MyUser({
    required this.id,
    required this.name,
    required this.email,
    this.college,
    this.phoneNumber,
    this.gender,
    this.role,
    this.photoUrl,
    this.fcmToken,
    this.createdAt,
  });

  factory MyUser.fromSupaBase(Map<String, dynamic> data) {
    return MyUser(
      id: data["id"]?.toString() ?? "",
      name: data["name"]?.toString() ?? "",
      email: data["email"]?.toString() ?? "",
      college: data["college"]?.toString(),
      phoneNumber: data["phoneNumber"]?.toString(),
      gender: data["gender"]?.toString(),
      role: data["role"]?.toString(),
      photoUrl: data["photoUrl"]?.toString(),
      fcmToken: data["fcmToken"]?.toString(),
      createdAt: data["createdAt"] != null
          ? DateTime.tryParse(data["createdAt"].toString())
          : null,
    );
  }

  Map<String, dynamic> toSupaBase() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "college": college,
      "phoneNumber": phoneNumber,
      "gender": gender,
      "role": role,
      "photoUrl": photoUrl,
      "fcmToken": fcmToken,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}

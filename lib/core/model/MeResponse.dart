// /// name : "Sokon Test User"
// /// email : "wwsdd@example.com"
// /// college : "Engineering"
// /// phoneNumber : "01000000000"
// /// gender : "male"
// /// role : "client"
// /// photoUrl : null
// /// fcmToken : null
// /// id : "d5fa201b-defe-476b-8c51-4307e9d38f2f"
// /// createdAt : "2026-06-22T19:48:57.624Z"
//
// class MeResponse {
//   MeResponse({
//       String name,
//       String email,
//       String college,
//       String phoneNumber,
//       String gender,
//       String role,
//       dynamic photoUrl,
//       dynamic fcmToken,
//       String id,
//       String createdAt,}){
//     _name = name;
//     _email = email;
//     _college = college;
//     _phoneNumber = phoneNumber;
//     _gender = gender;
//     _role = role;
//     _photoUrl = photoUrl;
//     _fcmToken = fcmToken;
//     _id = id;
//     _createdAt = createdAt;
// }
//
//   MeResponse.fromJson(dynamic json) {
//     _name = json['name'];
//     _email = json['email'];
//     _college = json['college'];
//     _phoneNumber = json['phoneNumber'];
//     _gender = json['gender'];
//     _role = json['role'];
//     _photoUrl = json['photoUrl'];
//     _fcmToken = json['fcmToken'];
//     _id = json['id'];
//     _createdAt = json['createdAt'];
//   }
//   String _name;
//   String _email;
//   String _college;
//   String _phoneNumber;
//   String _gender;
//   String _role;
//   dynamic _photoUrl;
//   dynamic _fcmToken;
//   String _id;
//   String _createdAt;
// MeResponse copyWith({  String name,
//   String email,
//   String college,
//   String phoneNumber,
//   String gender,
//   String role,
//   dynamic photoUrl,
//   dynamic fcmToken,
//   String id,
//   String createdAt,
// }) => MeResponse(  name: name ?? _name,
//   email: email ?? _email,
//   college: college ?? _college,
//   phoneNumber: phoneNumber ?? _phoneNumber,
//   gender: gender ?? _gender,
//   role: role ?? _role,
//   photoUrl: photoUrl ?? _photoUrl,
//   fcmToken: fcmToken ?? _fcmToken,
//   id: id ?? _id,
//   createdAt: createdAt ?? _createdAt,
// );
//   String get name => _name;
//   String get email => _email;
//   String get college => _college;
//   String get phoneNumber => _phoneNumber;
//   String get gender => _gender;
//   String get role => _role;
//   dynamic get photoUrl => _photoUrl;
//   dynamic get fcmToken => _fcmToken;
//   String get id => _id;
//   String get createdAt => _createdAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['name'] = _name;
//     map['email'] = _email;
//     map['college'] = _college;
//     map['phoneNumber'] = _phoneNumber;
//     map['gender'] = _gender;
//     map['role'] = _role;
//     map['photoUrl'] = _photoUrl;
//     map['fcmToken'] = _fcmToken;
//     map['id'] = _id;
//     map['createdAt'] = _createdAt;
//     return map;
//   }
//
// }
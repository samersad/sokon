class RegisterResponse {
  RegisterResponse({this.user, this.session});

  factory RegisterResponse.fromJson(dynamic json) {
    if (json is! Map) return RegisterResponse();
    final data = Map<String, dynamic>.from(json);
    return RegisterResponse(
      user: data['user'] is Map
          ? RegisterUser.fromJson(Map<String, dynamic>.from(data['user'] as Map))
          : null,
      session: data['session'] is Map
          ? Session.fromJson(Map<String, dynamic>.from(data['session'] as Map))
          : null,
    );
  }

  final RegisterUser? user;
  final Session? session;

  RegisterResponse copyWith({RegisterUser? user, Session? session}) {
    return RegisterResponse(
      user: user ?? this.user,
      session: session ?? this.session,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (user != null) 'user': user!.toJson(),
      if (session != null) 'session': session!.toJson(),
    };
  }
}

class LoginResponse extends RegisterResponse {
  LoginResponse({super.user, super.session});

  factory LoginResponse.fromJson(dynamic json) {
    final response = RegisterResponse.fromJson(json);
    return LoginResponse(user: response.user, session: response.session);
  }
}

class Session {
  Session({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.expiresAt,
    this.user,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      expiresIn: _toNum(json['expires_in']),
      expiresAt: _toNum(json['expires_at']),
      user: json['user'] is Map
          ? RegisterUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
    );
  }

  static num? _toNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final num? expiresIn;
  final num? expiresAt;
  final RegisterUser? user;

  Session copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    num? expiresIn,
    num? expiresAt,
    RegisterUser? user,
  }) {
    return Session(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class RegisterUser {
  RegisterUser({
    this.name,
    this.email,
    this.college,
    this.phoneNumber,
    this.gender,
    this.role,
    this.authProvider,
    this.photoUrl,
    this.fcmToken,
    this.id,
    this.createdAt,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      college: json['college']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      gender: json['gender']?.toString(),
      role: json['role']?.toString(),
      authProvider: json['authProvider']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      fcmToken: json['fcmToken']?.toString(),
      id: json['id']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  String? name;
  String? email;
  String? college;
  String? phoneNumber;
  String? gender;
  String? role;
  String? authProvider;
  dynamic photoUrl;
  dynamic fcmToken;
  String? id;
  String? createdAt;

  RegisterUser copyWith({
    String? name,
    String? email,
    String? college,
    String? phoneNumber,
    String? gender,
    String? role,
    String? authProvider,
    dynamic photoUrl,
    dynamic fcmToken,
    String? id,
    String? createdAt,
  }) {
    return RegisterUser(
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      authProvider: authProvider ?? this.authProvider,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'college': college,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'role': role,
      'authProvider': authProvider,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'id': id,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toSupaBase() => toJson();
}

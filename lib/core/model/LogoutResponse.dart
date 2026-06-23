class LogoutResponse {
  const LogoutResponse({required this.signedOut});

  factory LogoutResponse.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return LogoutResponse(
      signedOut: data['signedOut'] == true,
    );
  }

  final bool signedOut;

  LogoutResponse copyWith({bool? signedOut}) {
    return LogoutResponse(
      signedOut: signedOut ?? this.signedOut,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signedOut': signedOut,
    };
  }
}

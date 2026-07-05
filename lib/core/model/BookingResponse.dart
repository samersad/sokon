class BookingResponse {
  BookingResponse({
    this.apartmentId,
    this.apartmentName,
    this.apartmentAddress,
    this.apartmentImage,
    this.clientId,
    this.clientName,
    this.clientPhoneNumber,
    this.ownerId,
    this.ownerName,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.peopleCount,
    this.rating,
    this.ratedAt,
    this.status,
    this.createdAt,
    this.id,
  });

  factory BookingResponse.fromJson(dynamic json) {
    final raw = Map<String, dynamic>.from(json as Map);
    final nested = raw['booking'] ?? raw['data'] ?? raw['item'];
    final data = nested is Map ? Map<String, dynamic>.from(nested) : raw;
    final idValue = raw['id'] ??
        raw['bookingId'] ??
        raw['booking_id'] ??
        raw['bookingID'] ??
        raw['_id'] ??
        data['id'] ??
        data['bookingId'] ??
        data['booking_id'] ??
        data['bookingID'] ??
        data['_id'];
    return BookingResponse(
      apartmentId: data['apartmentId']?.toString(),
      apartmentName: data['apartmentName']?.toString(),
      apartmentAddress: data['apartmentAddress']?.toString(),
      apartmentImage: data['apartmentImage']?.toString(),
      clientId: data['clientId']?.toString(),
      clientName: data['clientName']?.toString(),
      clientPhoneNumber: data['clientPhoneNumber']?.toString() ??
          data['clientPhone']?.toString() ??
          data['phoneNumber']?.toString(),
      ownerId: data['ownerId']?.toString(),
      ownerName: data['ownerName']?.toString(),
      startDate: data['startDate'] != null
          ? DateTime.tryParse(data['startDate'].toString())
          : null,
      endDate: data['endDate'] != null
          ? DateTime.tryParse(data['endDate'].toString())
          : null,
      totalPrice: (data['totalPrice'] as num?)?.toDouble(),
      peopleCount: (data['people_count'] as num?)?.toInt(),
      rating: (data['rating'] as num?)?.toInt(),
      ratedAt: data['rated_at'] != null
          ? DateTime.tryParse(data['rated_at'].toString())
          : null,
      status: data['status']?.toString(),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
      id: idValue?.toString(),
    );
  }

  final String? apartmentId;
  final String? apartmentName;
  final String? apartmentAddress;
  final String? apartmentImage;
  final String? clientId;
  final String? clientName;
  final String? clientPhoneNumber;
  final String? ownerId;
  final String? ownerName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? totalPrice;
  final int? peopleCount;
  final int? rating;
  final DateTime? ratedAt;
  final String? status;
  final DateTime? createdAt;
  final String? id;

  BookingResponse copyWith({
    String? apartmentId,
    String? apartmentName,
    String? apartmentAddress,
    String? apartmentImage,
    String? clientId,
    String? clientName,
    String? clientPhoneNumber,
    String? ownerId,
    String? ownerName,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    int? peopleCount,
    int? rating,
    DateTime? ratedAt,
    String? status,
    DateTime? createdAt,
    String? id,
  }) {
    return BookingResponse(
      apartmentId: apartmentId ?? this.apartmentId,
      apartmentName: apartmentName ?? this.apartmentName,
      apartmentAddress: apartmentAddress ?? this.apartmentAddress,
      apartmentImage: apartmentImage ?? this.apartmentImage,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhoneNumber: clientPhoneNumber ?? this.clientPhoneNumber,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      peopleCount: peopleCount ?? this.peopleCount,
      rating: rating ?? this.rating,
      ratedAt: ratedAt ?? this.ratedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apartmentId': apartmentId,
      'apartmentName': apartmentName,
      'apartmentAddress': apartmentAddress,
      'apartmentImage': apartmentImage,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhoneNumber': clientPhoneNumber,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'totalPrice': totalPrice,
      'people_count': peopleCount,
      'rating': rating,
      'rated_at': ratedAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'id': id,
    };
  }
}

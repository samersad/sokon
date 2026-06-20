class Booking {
  static const String collectionName = "bookings";

  String? id;
  String? apartmentId;
  String? apartmentName;
  String? apartmentAddress;
  String? apartmentImage;
  String? clientId;
  String? clientName;
  String? ownerId;
  String? ownerName;
  DateTime? startDate;
  DateTime? endDate;
  double? totalPrice;
  int? peopleCount;
  String? status; // 'pending', 'accepted', 'cancelled'
  DateTime? createdAt;

  Booking({
    this.id,
    this.apartmentId,
    this.apartmentName,
    this.apartmentAddress,
    this.apartmentImage,
    this.clientId,
    this.clientName,
    this.ownerId,
    this.ownerName,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.peopleCount,
    this.status = 'pending',
    this.createdAt,
  });

  factory Booking.fromSupaBase(Map<String, dynamic> data) {
    return Booking(
      id: data["id"]?.toString(),
      apartmentId: data["apartmentId"],
      apartmentName: data["apartmentName"],
      apartmentAddress: data["apartmentAddress"],
      apartmentImage: data["apartmentImage"],
      clientId: data["clientId"],
      clientName: data["clientName"],
      ownerId: data["ownerId"],
      ownerName: data["ownerName"],
      startDate: data["startDate"] != null ? DateTime.parse(data["startDate"]) : null,
      endDate: data["endDate"] != null ? DateTime.parse(data["endDate"]) : null,
      totalPrice: (data["totalPrice"] as num?)?.toDouble(),
      peopleCount: data["people_count"],
      status: data["status"],
      createdAt: data["createdAt"] != null ? DateTime.parse(data["createdAt"]) : null,
    );
  }

  Map<String, dynamic> toSupaBase() {
    final Map<String, dynamic> data = {
      'apartmentId': apartmentId,
      'apartmentName': apartmentName,
      'apartmentAddress': apartmentAddress,
      'apartmentImage': apartmentImage,
      'clientId': clientId,
      'clientName': clientName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'totalPrice': totalPrice,
      'people_count': peopleCount,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

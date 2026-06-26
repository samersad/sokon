class Apartment {
  static const String collectionName = "apartments";

  String? id;
  String? name;
  String? description;
  double? price;

  List<String>? images;
  String? videoUrl;

  int? bedrooms;
  int? bathrooms;
  int? livingRooms;
  int? floor;
  int? maxPeople;
  int? availablePeople;

  String? address;
  String? city;
  String? district;
  String? locationAddress;
  double? lat;
  double? lng;
  String? ownerId;
  String? ownerName;
  String? ownerPhotoUrl;
  bool? verified;
  int? ratingSum;
  int? ratingCount;
  double? ratingAverage;
  DateTime? createdAt;

  Apartment({
    this.id,
    this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.videoUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.livingRooms,
    this.floor,
    required this.maxPeople,
    required this.availablePeople,
    this.address,
    this.city,
    this.district,
    this.locationAddress,
    this.lat,
    this.lng,
    this.ownerId,
    this.ownerName,
    this.ownerPhotoUrl,
    this.verified,
    this.ratingSum,
    this.ratingCount,
    this.ratingAverage,
    this.createdAt,
  });

  String get cityDistrictLabel {
    final parts = <String>[];
    final resolvedCity = city?.trim();
    final resolvedDistrict = _normalizeDistrictName(district);
    if (resolvedCity != null && resolvedCity.isNotEmpty) {
      parts.add(resolvedCity);
    }
    if (resolvedDistrict.isNotEmpty) {
      parts.add(resolvedDistrict);
    }
    return parts.isEmpty ? "Assuit • فريال" : parts.join(" • ");
  }

  String get displayLocationLabel {
    final resolvedAddress = address?.trim();
    if (resolvedAddress != null && resolvedAddress.isNotEmpty) {
      return resolvedAddress;
    }
    return cityDistrictLabel;
  }

  String get floorLabel => floor != null ? "Floor ${floor!}" : "Floor 1";

  String get ratingLabel {
    final count = ratingCount ?? 0;
    if (count == 0) {
      return "0.0";
    }
    return (ratingAverage ?? 0).toStringAsFixed(1);
  }

  factory Apartment.fromSupaBase(Map<String, dynamic> data) {
    return Apartment(
      id: data["id"]?.toString(),
      name: data["name"],
      description: data["description"],
      price: (data["price"] as num?)?.toDouble(),
      images: data["images"] != null ? List<String>.from(data["images"]) : [],
      videoUrl: data["video_url"],
      bedrooms: data["bedrooms"],
      bathrooms: data["bathrooms"],
      livingRooms: data["living_rooms"],
      floor: (data["floor"] as num?)?.toInt(),
      maxPeople: data["max_people"],
      availablePeople: data["available_people"],
      address: data["address"],
      city: data["city"] ?? "Assuit",
      district: _normalizeDistrictName(data["district"]?.toString()),
      locationAddress: data["locationAddress"] ?? data["address"],
      lat: (data["lat"] as num?)?.toDouble(),
      lng: (data["lng"] as num?)?.toDouble(),
      ownerId: data["ownerId"],
      ownerName: data["ownerName"],
      ownerPhotoUrl: data["ownerPhotoUrl"],
      verified: data["verified"] as bool? ?? false,
      ratingSum: (data["rating_sum"] as num?)?.toInt() ?? 0,
      ratingCount: (data["rating_count"] as num?)?.toInt() ?? 0,
      ratingAverage: (data["rating_average"] as num?)?.toDouble() ?? 0,
      createdAt: data["createdAt"] != null
          ? DateTime.parse(data["createdAt"])
          : null,
    );
  }

  Map<String, dynamic> toSupaBase() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'video_url': videoUrl,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'living_rooms': livingRooms,
      'floor': floor ?? 1,
      'max_people': maxPeople,
      'available_people': availablePeople,
      'address': address,
      'city': city ?? 'Assuit',
      'district': _normalizeDistrictName(district),
      'locationAddress': locationAddress,
      'lat': lat,
      'lng': lng,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'verified': verified ?? false,
      'createdAt': createdAt?.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

String _normalizeDistrictName(String? district) {
  final value = district?.trim();
  if (value == null || value.isEmpty) {
    return 'فريال';
  }
  const allowedDistricts = {
    'فريال',
    'سيتي',
    'سيد',
    'الجمهوريه',
    'يسري راغب',
    'آخر',
  };
  return allowedDistricts.contains(value) ? value : 'فريال';
}

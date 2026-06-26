class ApartmentResponse {
  ApartmentResponse({
    this.name,
    this.description,
    this.price,
    this.images,
    this.videoUrl,
    this.bedrooms,
    this.bathrooms,
    this.livingRooms,
    this.floor,
    this.maxPeople,
    this.availablePeople,
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
    this.id,
    this.createdAt,
  });

  factory ApartmentResponse.fromJson(dynamic json) {
    final data = Map<String, dynamic>.from(json as Map);
    return ApartmentResponse(
      name: data['name']?.toString(),
      description: data['description']?.toString(),
      price: (data['price'] as num?)?.toDouble(),
      images: data['images'] != null ? List<String>.from(data['images']) : [],
      videoUrl: data['video_url']?.toString(),
      bedrooms: (data['bedrooms'] as num?)?.toInt(),
      bathrooms: (data['bathrooms'] as num?)?.toInt(),
      livingRooms: (data['living_rooms'] as num?)?.toInt(),
      floor: (data['floor'] as num?)?.toInt(),
      maxPeople: (data['max_people'] as num?)?.toInt(),
      availablePeople: (data['available_people'] as num?)?.toInt(),
      address: data['address']?.toString(),
      city: data['city']?.toString(),
      district: data['district']?.toString(),
      locationAddress: data['locationAddress']?.toString(),
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      ownerId: data['ownerId']?.toString(),
      ownerName: data['ownerName']?.toString(),
      ownerPhotoUrl: data['ownerPhotoUrl']?.toString(),
      verified: data['verified'] as bool?,
      ratingSum: (data['rating_sum'] as num?)?.toInt(),
      ratingCount: (data['rating_count'] as num?)?.toInt(),
      ratingAverage: (data['rating_average'] as num?)?.toDouble(),
      id: data['id']?.toString(),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  final String? name;
  final String? description;
  final double? price;
  final List<String>? images;
  final String? videoUrl;
  final int? bedrooms;
  final int? bathrooms;
  final int? livingRooms;
  final int? floor;
  final int? maxPeople;
  final int? availablePeople;
  final String? address;
  final String? city;
  final String? district;
  final String? locationAddress;
  final double? lat;
  final double? lng;
  final String? ownerId;
  final String? ownerName;
  final String? ownerPhotoUrl;
  final bool? verified;
  final int? ratingSum;
  final int? ratingCount;
  final double? ratingAverage;
  final String? id;
  final DateTime? createdAt;

  String get cityDistrictLabel {
    final parts = <String>[];
    final resolvedCity = city?.trim();
    final resolvedDistrict = district?.trim();
    if (resolvedCity != null && resolvedCity.isNotEmpty) {
      parts.add(resolvedCity);
    }
    if (resolvedDistrict != null && resolvedDistrict.isNotEmpty) {
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

  String get floorLabel => floor != null ? "Floor $floor" : "Floor 1";

  String get ratingLabel {
    final count = ratingCount ?? 0;
    if (count == 0) {
      return "0.0";
    }
    return (ratingAverage ?? 0).toStringAsFixed(1);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images ?? [],
      'video_url': videoUrl,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'living_rooms': livingRooms,
      'floor': floor,
      'max_people': maxPeople,
      'available_people': availablePeople,
      'address': address,
      'city': city,
      'district': district,
      'locationAddress': locationAddress,
      'lat': lat,
      'lng': lng,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'verified': verified,
      'rating_sum': ratingSum,
      'rating_count': ratingCount,
      'rating_average': ratingAverage,
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

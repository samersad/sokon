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

  String? address;
  double? lat;
  double? lng;
  String? ownerId;
  String? ownerName;
  String? ownerPhotoUrl;
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
    this.address,
    this.lat,
    this.lng,
    this.ownerId,
    this.ownerName,
    this.ownerPhotoUrl,
    this.createdAt,
  });

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
      address: data["address"],
      lat: (data["lat"] as num?)?.toDouble(),
      lng: (data["lng"] as num?)?.toDouble(),
      ownerId: data["ownerId"],
      ownerName: data["ownerName"],
      ownerPhotoUrl: data["ownerPhotoUrl"],
      createdAt: data["createdAt"] != null ? DateTime.parse(data["createdAt"]) : null,
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
      'address': address,
      'lat': lat,
      'lng': lng,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}

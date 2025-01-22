class Restaurant {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String phoneNumber;
  final String cuisineType;
  final double rating;
  final String? websiteUrl;
  final List<String> haloCertifications;
  final List<String> tags;
  final bool isHalal;
  final bool isOpenNow;
  final List<String> openingHours;
  final List<String> images;
  final bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    this.description = '',
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phoneNumber = '',
    this.cuisineType = '',
    this.rating = 0.0,
    this.websiteUrl,
    this.haloCertifications = const [],
    this.tags = const [],
    this.isHalal = false,
    this.isOpenNow = false,
    this.openingHours = const [],
    this.images = const [],
    this.isFavorite = false,
  });

  // From JSON constructor
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      cuisineType: json['cuisineType'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      websiteUrl: json['websiteUrl'],
      haloCertifications: List<String>.from(json['haloCertifications'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      isHalal: json['isHalal'] ?? false,
      isOpenNow: json['isOpenNow'] ?? false,
      openingHours: List<String>.from(json['openingHours'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phoneNumber': phoneNumber,
      'cuisineType': cuisineType,
      'rating': rating,
      'websiteUrl': websiteUrl,
      'haloCertifications': haloCertifications,
      'tags': tags,
      'isHalal': isHalal,
      'isOpenNow': isOpenNow,
      'openingHours': openingHours,
      'images': images,
      'isFavorite': isFavorite,
    };
  }

  // Copywrite method for easy modification
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? phoneNumber,
    String? cuisineType,
    double? rating,
    String? websiteUrl,
    List<String>? haloCertifications,
    List<String>? tags,
    bool? isHalal,
    bool? isOpenNow,
    List<String>? openingHours,
    List<String>? images,
    bool? isFavorite,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cuisineType: cuisineType ?? this.cuisineType,
      rating: rating ?? this.rating,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      haloCertifications: haloCertifications ?? this.haloCertifications,
      tags: tags ?? this.tags,
      isHalal: isHalal ?? this.isHalal,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      openingHours: openingHours ?? this.openingHours,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Equality method
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Restaurant &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.cuisineType == cuisineType &&
        other.rating == rating &&
        other.websiteUrl == websiteUrl &&
        other.haloCertifications == haloCertifications &&
        other.tags == tags &&
        other.isHalal == isHalal &&
        other.isOpenNow == isOpenNow &&
        other.openingHours == openingHours &&
        other.images == images &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        cuisineType.hashCode ^
        rating.hashCode ^
        websiteUrl.hashCode ^
        haloCertifications.hashCode ^
        tags.hashCode ^
        isHalal.hashCode ^
        isOpenNow.hashCode ^
        openingHours.hashCode ^
        images.hashCode ^
        isFavorite.hashCode;
  }
}
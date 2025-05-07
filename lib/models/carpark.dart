// models/carpark.dart
class Carpark {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final double latitude;
  final double longitude;
  final int totalSpots;
  final int? availableSpots;
  final double pricePerHour;
  final bool isActive;
  final double distanceFromUser;

  Carpark({
    required this.id,
    required this.name,
    this.address,
    this.city,
    required this.latitude,
    required this.longitude,
    required this.totalSpots,
    this.availableSpots,
    required this.pricePerHour,
    required this.isActive,
    required this.distanceFromUser,
  });

  factory Carpark.fromJson(Map<String, dynamic> json) {
    return Carpark(
      id: json['id'].toString(),
      name: json['name'] ?? 'Parking',
      address: json['address'],
      city: json['city'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      totalSpots: json['total_spots'] ?? 0,
      availableSpots: json['available_spots'],
      pricePerHour: json['price_per_hour'] != null ? double.parse(json['price_per_hour'].toString()) : 150.0,
      isActive: json['is_active'] ?? true,
      distanceFromUser: json['distance_from_user'] != null ? double.parse(json['distance_from_user'].toString()) : 0.0,
    );
  }
}
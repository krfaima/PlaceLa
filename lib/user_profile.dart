class UserProfile {
  final String username;
  final String email;
  final Map<String, dynamic> profile;
  final List<dynamic> vehicles;
  final List<dynamic> gpsCoordinates;
  final List<dynamic> reservations;
  final List<dynamic> payments;

  UserProfile({
    required this.username,
    required this.email,
    required this.profile,
    required this.vehicles,
    required this.gpsCoordinates,
    required this.reservations,
    required this.payments,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      profile: json['profile'],
      vehicles: json['vehicles'],
      gpsCoordinates: json['gps_coordinates'],
      reservations: json['reservations'],
      payments: json['payments'],
    );
  }
}

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_profile.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  ProfilePage({required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile> futureProfile;

  @override
  void initState() {
    super.initState();
    futureProfile = ApiService.fetchUserProfile(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Profil")),
      body: FutureBuilder<UserProfile>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text("Nom : ${profile.profile['full_name']}"),
                Text("Adresse : ${profile.profile['address']}"),
                Text("Genre : ${profile.profile['gender']}"),
                Text("Date de naissance : ${profile.profile['date_of_birth']}"),
                Divider(),
                Text("Véhicules : ${profile.vehicles.length}"),
                Text("Réservations : ${profile.reservations.length}"),
                Text("Paiements : ${profile.payments.length}"),
                Text("Coordonnées GPS : ${profile.gpsCoordinates.length}"),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}


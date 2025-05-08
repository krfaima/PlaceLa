// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'user_profile.dart';

// class ApiService {
//   // static const String baseUrl = "http://10.0.2.2:8000/api/user/profile/";
//   static String get baseUrl => "http://127.0.0.1:8000/api/";

//   static Future<UserProfile> fetchUserProfile(String token) async {
//     final response = await http.get(
//       Uri.parse('${baseUrl}profile/'), // <-- Ici ajout "profile/"
//       headers: {
//      'Authorization': 'Bearer $token', // <-- Ici on envoie bien le token
//         // 'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//     if (response.statusCode == 200) {
//       return UserProfile.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Erreur lors de la récupération du profil');
//     }
//   }
// }


// # 5. Modify the ApiService in Dart to properly handle errors
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_profile.dart';

class ApiService {
  static String get baseUrl => "http://127.0.0.1:8000/api/";

  static Future<UserProfile> fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        print('Error response: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Network or parsing error: $e');
      throw Exception('Network error: $e');
    }
  }
}
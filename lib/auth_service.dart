import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final bool isLocal = false; // set to true for localhost

String get baseUrl => "http://192.168.1.8:8000/accounts/";
  //   return isLocal
  //       ? "http://192.168.1.8:8000/accounts/"
  //       : "http://10.0.2.2:8000/accounts/";
  // }

  // 🔹 INSCRIPTION
  Future<String?> register(
      String email, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "username": username.trim(),
          "password": password,
        }),
      );

      print(
          " Réponse Django (register): ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201) {
        return null; // Succès
      } else {
        final data = jsonDecode(response.body);
        return data["message"] ?? "Erreur lors de l'inscription";
      }
    } catch (e) {
      print(" Erreur (register): $e");
      return "Erreur de connexion au serveur";
    }
  }

  // 🔹 VÉRIFICATION DU CODE
  Future<String?> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}verify-email/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "code": code.trim(),
        }),
      );

      print(
          "📩 Réponse Django (verify): ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return null; // Succès
      } else {
        final data = jsonDecode(response.body);
        return data["message"] ?? "Code invalide";
      }
    } catch (e) {
      print("❌ Erreur (verifyCode): $e");
      return "Erreur de connexion au serveur";
    }
  }

  // 🔹 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password,
        }),
      );

      print(
          "📩 Réponse Django (login): ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? token = data["token"];
        Map<String, dynamic>? user = data["user"];

        if (token != null && user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("auth_token", token);
          await prefs.setInt("user_id", user["id"]);
          await prefs.setString("user_email", user["email"]);
          await prefs.setString("username", user["username"]);

          return null; // Succès
        } else {
          return "Aucun token reçu !";
        }
      } else {
        final data = jsonDecode(response.body);
        return data["message"] ?? "Email ou mot de passe incorrect";
      }
    } catch (e) {
      print("❌ Erreur (login): $e");
      return "Erreur de connexion au serveur";
    }
  }

  // 🔹 DÉCONNEXION
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_id");
    await prefs.remove("user_email");
    await prefs.remove("username");
    print("✅ User logged out");
  }

  // 🔹 RÉCUPÉRATION DU PROFIL UTILISATEUR
  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");

    if (token == null) {
      print("❌ Pas de token disponible");
      return null;
    }

    final response = await http.get(
      Uri.parse('${baseUrl}profile/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print(
        "📩 Réponse Django (profile): ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // 🔹 VÉRIFIER SI L'UTILISATEUR EST CONNECTÉ
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token") != null;
  }
}

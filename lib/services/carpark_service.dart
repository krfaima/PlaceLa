// services/carpark_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/carpark.dart';

class CarparkService {
  // final String baseUrl = 'http://192.168.100.12:8000/accounts/';
final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Carpark>> getNearbyCarparks(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$baseUrl/nearby-carparks/?lat=$latitude&lng=$longitude'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Carpark.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load car parks');
    }
  }

  Future<List<LatLng>> getRoute(
      double startLat, double startLng, double endLat, double endLng) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/get-route/?start_lat=$startLat&start_lng=$startLng&end_lat=$endLat&end_lng=$endLng'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
          .toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<bool> sendReservation({
    required String carparkId,
    required String duration,
    required String color,
    required String plateNumber,
  }) async {
    const String apiUrl = 'http://127.0.0.1:8000/accounts/reserve/';

    final int parsedDuration = int.tryParse(duration) ?? 0;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carpark_id': carparkId,  // Ajout de l'ID du parking
          'duration': parsedDuration,
          'color': color,
          'plate_number': plateNumber,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error sending reservation: $e');
      return false;
    }
  }

  Future<bool> processPayment({
    required String carparkId,  // Ajout de l'ID du parking
    required String plateNumber,
    required String color,
    required int duration,
    required int price,
    required String cardNumber,
    required String cardExpiry,
    required String cardCvv,
    required String cardName,
  }) async {
    const String apiUrl = 'http://127.0.0.1:8000/accounts/process-payment/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carpark_id': carparkId,  // Ajout de l'ID du parking
          'plate_number': plateNumber,
          'color': color,
          'duration': duration,
          'price': price,
          'card_number': cardNumber.replaceAll(' ', ''),
          'card_expiry': cardExpiry,
          'card_cvv': cardCvv,
          'card_name': cardName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }
}
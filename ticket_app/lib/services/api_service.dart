import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';

class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Utilisez l'adresse IP de votre machine si vous n'utilisez pas l'émulateur Android

  Future<void> createReservation(Reservation reservation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reservation.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Échec de la création de la réservation');
    }
  }

  Future<List<Reservation>> getReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      print('Données reçues du serveur: $body');
      //ceci est une modif pour régler le problème de suppression
      List<Reservation> reservations =
          body.map((json) => Reservation.fromJson(json)).toList();
      reservations.forEach((reservation) {
        print('ID de réservation reçu : ${reservation.idReservation}');
      });
      return reservations;
      //return body.map((json) => Reservation.fromJson(json)).toList();
    } else {
      print(
          'Erreur lors du chargement des réservations: ${response.statusCode}');
      throw Exception('Échec du chargement des réservations');
    }
  }

  Future<void> updateReservation(String? id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reservations/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw HttpException(
            'Échec de la mise à jour de la réservation: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      print('Erreur dans updateReservation: $e');
      rethrow; // Relance l'exception pour qu'elle soit gérée par l'appelant
    }
  }

  Future<void> deleteReservation(String? id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reservations/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la suppression de la réservation');
    }
  }
}

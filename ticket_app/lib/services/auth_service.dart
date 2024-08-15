import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  Future<bool> inscription(String identifiant, String motDePasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inscription'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifiant': identifiant, 'motDePasse': motDePasse}),
    );

    return response.statusCode == 201;
  }

  Future<bool> connexion(String identifiant, String motDePasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/connexion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifiant': identifiant, 'motDePasse': motDePasse}),
    );

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
    return false;
  }

  Future<void> deconnexion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> estConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<void> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la réinitialisation du mot de passe');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Échec de la demande de réinitialisation du mot de passe');
    }
  }

  Future<void> confirmPasswordReset(
      String email, String code, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password-confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la réinitialisation du mot de passe');
    }
  }
}

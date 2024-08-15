import 'package:flutter/material.dart';
import 'package:ticket_app/services/auth_service.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String email;

  ResetPasswordConfirmScreen({required this.email});

  @override
  _ResetPasswordConfirmScreenState createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState
    extends State<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _code = '';
  String _newPassword = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _authService.confirmPasswordReset(
            widget.email, _code, _newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mot de passe réinitialisé avec succès')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réinitialiser le mot de passe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Code de réinitialisation'),
              validator: (value) => value!.isEmpty ? 'Entrez le code' : null,
              onSaved: (value) => _code = value!,
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
              validator: (value) =>
                  value!.isEmpty ? 'Entrez un nouveau mot de passe' : null,
              onSaved: (value) => _newPassword = value!,
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Réinitialiser le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ticket_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _identifiant = '';
  String _motDePasse = '';
  //String _confirmerMdp = '';
  bool _isPasswordVisible = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool success = await _authService.inscription(_identifiant, _motDePasse);
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'inscription")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Identifiant',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => _identifiant = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => _motDePasse = value!,
              ),
              // TextFormField(
              //   decoration: const InputDecoration(
              //       labelText: 'Confirmer le mot de passe'),
              //   obscureText: true,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Veuillez confirmer votre mot de passe';
              //     }
              //     if (value != _motDePasse) {
              //       return 'Les mots de passe ne correspondent pas';
              //     }
              //     return null;
              //   },
              //   onSaved: (value) => _confirmerMdp = value!,
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

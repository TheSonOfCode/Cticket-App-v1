import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ticket_app/models/reservation.dart';
import 'package:ticket_app/screens/congratulations_screen.dart';
import 'package:ticket_app/services/api_service.dart';

class FormulaireScreen extends StatefulWidget {
  const FormulaireScreen({super.key});

  @override
  _FormulaireScreenState createState() => _FormulaireScreenState();
}

class _FormulaireScreenState extends State<FormulaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String _nom = '';
  String _prenom = '';
  String _telephone = '';
  int _nombreTickets = 1;
  String _nomArtiste = '';
  String _nomEvenement = '';
  File? _photo;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final reservation = Reservation(
        nom: _nom,
        prenom: _prenom,
        telephone: _telephone,
        nombreTickets: _nombreTickets,
        nomArtiste: _nomArtiste,
        nomEvenement: _nomEvenement,
        photo: _photo?.path ?? '',
      );

      try {
        await _apiService.createReservation(reservation);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation créée avec succès')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _photo = null;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CongratulationsScreen(
              name: _nom,
              prenom: _prenom,
              nbreTicket: _nombreTickets,
              event: _nomEvenement,
            ),
          ),
        );
      } catch (e) {
        print('Erreur lors de la création de la réservation: $e'); //
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de la création de la réservation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? identifiant =
        ModalRoute.of(context)!.settings.arguments as String?;
    print('Identifiant dans build: $identifiant'); // Ajout de debug
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulaire d\'enregistrement'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Liste'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/list',
                  arguments: identifiant,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                // Ajouter la navigation vers l'écran des paramètres ici
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Thème'),
              onTap: () {
                // Ajouter la navigation ou la logique de changement de thème ici
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (identifiant != null)
                Text(
                  'Bonjour, $identifiant',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer votre nom' : null,
                onSaved: (value) => _nom = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer votre prénom' : null,
                onSaved: (value) => _prenom = value!,
              ),
              TextFormField(
                // téléphone
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  if (value.length != 9) {
                    return "Le numéro de téléphone doit contenir exactement 9 chiffres";
                  }
                  return null;
                },
                onSaved: (value) => _telephone = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre de tickets'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de tickets';
                  }
                  return null;
                },
                onSaved: (value) => _nombreTickets = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Artiste'),
                validator: (value) => value!.isEmpty
                    ? 'Veuillez entrer le nom de l\'artiste'
                    : null,
                onSaved: (value) => _nomArtiste = value!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nom de l\'événement'),
                validator: (value) => value!.isEmpty
                    ? 'Veuillez entrer le nom de l\'événement'
                    : null,
                onSaved: (value) => _nomEvenement = value!,
              ),
              const SizedBox(height: 20),
              _photo == null
                  ? const Text('Aucune photo sélectionnée.')
                  : Image.file(_photo!),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Sélectionner une photo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Réserver'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            //authProvider.clearIdentifiant();
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Icon(Icons.logout),
        ),
      ),
    );
  }
}

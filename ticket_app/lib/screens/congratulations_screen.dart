import 'package:flutter/material.dart';

class CongratulationsScreen extends StatelessWidget {
  final String name;
  final String prenom;
  final int nbreTicket;
  final String event;

  const CongratulationsScreen({
    super.key,
    required this.name,
    required this.prenom,
    required this.nbreTicket,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Félicitations'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.celebration,
                  size: 100,
                  color: Colors.yellowAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Félicitations!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$name $prenom',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Vous avez réservé $nbreTicket ticket(s) pour l\'événement',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  event,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

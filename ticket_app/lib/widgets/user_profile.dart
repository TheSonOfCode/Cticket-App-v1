import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final String username;

  UserProfile({required this.username});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.person, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          username,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

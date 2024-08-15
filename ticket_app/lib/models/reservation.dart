class Reservation {
  final String? idReservation;
  final String nom;
  final String prenom;
  final String telephone;
  final int nombreTickets;
  final String nomArtiste;
  final String nomEvenement;
  final String photo;
  bool isValidated;

  Reservation({
    this.idReservation,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.nombreTickets,
    required this.nomArtiste,
    required this.nomEvenement,
    required this.photo,
    this.isValidated = false,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      idReservation: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      nombreTickets: json['nombreTickets'] ?? '',
      nomArtiste: json['nomArtiste'] ?? '',
      nomEvenement: json['nomEvenement'] ?? '',
      photo: json['photo'] ?? '',
      isValidated: json['isValidated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': idReservation,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'nombreTickets': nombreTickets,
      'nomArtiste': nomArtiste,
      'nomEvenement': nomEvenement,
      'photo': photo,
      'isValidated': isValidated,
    };
  }
}

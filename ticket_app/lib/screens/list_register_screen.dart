import 'package:flutter/material.dart';
import 'package:ticket_app/models/reservation.dart';
import 'package:ticket_app/services/api_service.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Reservation>> _futureReservations;
  String? _identifiant;
  List<Reservation> unvalidatedReservations = [];
  List<Reservation> validatedReservations = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _futureReservations = _apiService.getReservations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupération de l'identifiant depuis les arguments de route
    _identifiant = ModalRoute.of(context)?.settings.arguments as String?;
    print('Identifiant récupéré: $_identifiant'); // Debug
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des réservations'),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _futureReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Erreur : ${snapshot.error}');
            return const Center(
                child: Text('Erreur lors du chargement des données'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune réservation trouvée'));
          } else {
            unvalidatedReservations = snapshot.data!
                .where((reservation) => !reservation.isValidated)
                .toList();
            validatedReservations = snapshot.data!
                .where((reservation) => reservation.isValidated)
                .toList();

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: unvalidatedReservations.length,
                    itemBuilder: (context, index) {
                      Reservation reservation = unvalidatedReservations[index];
                      return ListTile(
                        title: Text('${reservation.nom} ${reservation.prenom}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Téléphone: ${reservation.telephone}\nTickets: ${reservation.nombreTickets}\nArtiste: ${reservation.nomArtiste}\nÉvénement: ${reservation.nomEvenement}'),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(
                                    context, reservation),
                              ),
                            ),
                          ],
                        ),
                        onLongPress: () => _showValidationDialog(reservation),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ),
                ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isDropdownOpen = !_isDropdownOpen;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(
                              'Réservations validées (${validatedReservations.length})'),
                        );
                      },
                      body: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height *
                              0.3, // 30% de la hauteur de l'écran
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: validatedReservations.length,
                          itemBuilder: (context, index) {
                            Reservation reservation =
                                validatedReservations[index];
                            return ListTile(
                              title: Text(
                                  '${reservation.nom} ${reservation.prenom}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Téléphone: ${reservation.telephone}\n'
                                      'Tickets: ${reservation.nombreTickets}\n'
                                      'Artiste: ${reservation.nomArtiste}\n'
                                      'Événement: ${reservation.nomEvenement}'),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteConfirmationDialog(
                                              context, reservation),
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  const Icon(Icons.check, color: Colors.green),
                              onLongPress: () =>
                                  _showValidationDialog(reservation),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                            thickness: 1,
                          ),
                        ),
                      ),
                      isExpanded: _isDropdownOpen,
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showValidationDialog(Reservation reservation) {
    final bool isCurrentlyValidated = reservation.isValidated;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCurrentlyValidated
            ? 'Dévalider Réservation'
            : 'Valider Réservation'),
        content: Text(isCurrentlyValidated
            ? 'Voulez-vous dévalider cette réservation?'
            : 'Voulez-vous valider cette réservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _toggleValidation(reservation);
              Navigator.pop(context);
            },
            child: Text(isCurrentlyValidated ? 'Dévalider' : 'Valider'),
          ),
        ],
      ),
    );
  }

  void _toggleValidation(Reservation reservation) async {
    final bool isCurrentlyValidated = reservation.isValidated;

    // Mise à jour optimiste de l'UI
    setState(() {
      if (isCurrentlyValidated) {
        // Dévalider la réservation
        validatedReservations.remove(reservation);
        reservation.isValidated = false;
        unvalidatedReservations.add(reservation);
      } else {
        // Valider la réservation
        unvalidatedReservations.remove(reservation);
        reservation.isValidated = true;
        validatedReservations.add(reservation);
        _isDropdownOpen = true; // Ouvrir le dropdown après validation
      }
    });
    try {
      await _apiService.updateReservation(
          reservation.idReservation, {'isValidated': !isCurrentlyValidated});
      // Afficher un effet visuel avec Overlay
      _showOverlay(context, isCurrentlyValidated);
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        if (isCurrentlyValidated) {
          // Remettre la réservation comme validée
          unvalidatedReservations.remove(reservation);
          reservation.isValidated = true;
          validatedReservations.add(reservation);
        } else {
          // Remettre la réservation comme non validée
          validatedReservations.remove(reservation);
          reservation.isValidated = false;
          unvalidatedReservations.add(reservation);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    }
  }

  void _showOverlay(BuildContext context, bool isCurrentlyValidated) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0,
        left: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isCurrentlyValidated ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              isCurrentlyValidated
                  ? 'Réservation dévalidée avec succès'
                  : 'Réservation validée avec succès',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _validateReservation(Reservation reservation) async {
    // Mise à jour optimiste de l'UI
    setState(() {
      unvalidatedReservations.remove(reservation);
      reservation.isValidated = true;
      validatedReservations.add(reservation);
      _isDropdownOpen = true; // Ouvrez le dropdown après validation
    });

    try {
      await _apiService
          .updateReservation(reservation.idReservation, {'isValidated': true});
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        validatedReservations.remove(reservation);
        reservation.isValidated = false;
        unvalidatedReservations.add(reservation);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la validation : $e')),
      );
    }
  }

  void _deleteReservation(Reservation reservation) async {
    try {
      print(
          'Tentative de suppression de la réservation avec ID : ${reservation.idReservation}');
      await _apiService.deleteReservation(reservation.idReservation);

      _futureReservations = _apiService.getReservations();
      setState(() {}); // Forcer le rafraîchissement de l'UI

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: const Text('Réservation supprimée avec succès')),
      );
    } catch (e) {
      print(
          'Erreur lors de la suppression de la réservation avec ID : ${reservation.idReservation} - $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette réservation ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Ferme la boîte de dialogue
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                _deleteReservation(reservation); // Supprime la réservation
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

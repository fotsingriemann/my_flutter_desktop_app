import 'package:geolocator/geolocator.dart';

class GeoLocationResponse {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? error;

  GeoLocationResponse({
    required this.success,
    this.latitude,
    this.longitude,
    this.error,
  });

  // Convertir un objet JSON en une instance de GeoLocationResponse
  factory GeoLocationResponse.fromJson(Map<String, dynamic> json) {
    return GeoLocationResponse(
      success: json['success'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      error: json['error'],
    );
  }

  // Convertir une instance de GeoLocationResponse en un format JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'latitude': latitude,
      'longitude': longitude,
      'error': error,
    };
  }
}

Future<Map<String, dynamic>> getCurrentLocation() async {
  try {
    // Demande la permission si nécessaire
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'success': false,
        'error': 'Location services are disabled.',
      };
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'success': false,
          'error': 'Location permission denied.',
        };
      }
    }

    // Récupère la position actuelle avec les paramètres
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    );

    // Résultat avec latitude et longitude
    return {
      'success': true,
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  } catch (e) {
    // Gère les erreurs
    print('Error: $e');
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> loginUserWithPartner(String email, String password, Database db) async {

  return db.transaction((txn) async {
    try {
      var results = await txn.rawQuery(
        'SELECT * FROM Users WHERE email = ? AND password = ?;',
        [email, password],
      );

      if (results.isNotEmpty) {
        var user = results.first; // Récupérer les informations du premier utilisateur
        return {
          'success': true,
          'data': user,
        };
      } else {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur lors de la connexion: $error',
      };
    }
  });
}

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Map<String, dynamic>> createUserWithPartner(
    int id, String name, String email, String password, String phone, String role, int partnerId, Database db) async {

  return db.transaction((txn) async {
    try {
      // Vérifier si l'email existe déjà
      var results = await txn.rawQuery('SELECT * FROM Users WHERE email = ?;', [email]);

      if (results.isNotEmpty) {
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé.',
        };
      } else {
        // Insérer un nouvel utilisateur dans la table Users
        var userResults = await txn.rawInsert(
          'INSERT INTO Users (id, name, email, password, partner_id, phone, role) VALUES (?, ?, ?, ?, ?, ?, ?);',
          [id, name, email, password, partnerId, phone, role],
        );

        // Récupérer l'ID de l'utilisateur inséré (dans le cas de sqflite_common_ffi, il n'y a pas de `insertId`, mais `userResults` contient un entier indiquant le nombre de lignes affectées)
        return {
          'success': true,
          'message': 'Utilisateur et partenaire créés avec succès',
          'data': {
            'phone': phone,
            'role': role,
            'name': name,
            'email': email,
            'password': password,
            'id': id,
            'user_id': userResults, // userResults contient le nombre de lignes affectées, il peut être utilisé comme indicateur d'insertion
          }
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erreur lors de la création de l’utilisateur: $error',
      };
    }
  });
}



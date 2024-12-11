import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/database_service.dart';
import '../models/user_record.dart';
import 'package:intl/intl.dart';
import '../services/tts_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';


class AttendanceService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TTSService _ttsService = TTSService();
    // Singleton instance
  static final AttendanceService instance = AttendanceService._();

  // Private constructor
  AttendanceService._();


Future<void> getLastAttendences() async {
  try {
    // Fetch data from the API
    final response = await http.get(Uri.parse('$LOCAL_URL1/api/employees/attendances'));

    // Check if the request was successful
    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      print("/////////////&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& $res");

      if (res['success'] == true) {
        final data = res['data'] ?? [];
        print("/////////////&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& ${data.length}");

        // Call the function to upsert attendance data
        await upsertAttendance(data).then((result) {
          print(",,,,,,,,,,,,,,,,,, $result");
          dispatch(updateAttendencesBannerMessage("La synchronisation de companys a reussi"));
        }).catchError((error) {
          print("error,$error");
          showCustomMessage("Information", "La synchronisation de Types a échoué", "warning", "bottom");
        });
      } else {
        showCustomMessage("Information", res['message'], "warning", "bottom");
      }
    } else {
      showCustomMessage("Information", 'Failed to fetch data', "warning", "bottom");
    }
  } catch (err) {
    showCustomMessage("Information", 'Une erreur s\'est produite : $err', "warning", "bottom");
    print('Une erreur s\'est produite : $err');
  }
}

Future<void> syncAllPartners(List<dynamic> requests, Database db) async {
  // Start a transaction
  await db.transaction((tx) async {
    List<Future> queryPromises = [];

    for (var request in requests) {
      print(request);

      var queryPromise = tx.query(
        'respartner', // Table name
        where: 'id = ?', // WHERE clause
        whereArgs: [request['id']], // Arguments for the WHERE clause
      ).then((results) async {
        if (results.isNotEmpty) {
          // If the ID exists, update the record
          await tx.update(
            'respartner',
            {
              'name': request['display_name'] ?? '',
              'rfidcode': request['rfid_code']?.toString() ?? '',
              'image': request['avatar']?.toString() ?? '',
              'type': request['person_type'] ?? '',
              'rfidcode_num': request['rfid_num'] ?? '',
            },
            where: 'id = ?',
            whereArgs: [request['id']],
          );
          print('Updated: ${request['id']}');
        } else {
          // If the ID does not exist, insert a new record
          await tx.insert(
            'respartner',
            {
              'id': request['id'],
              'name': request['display_name'] ?? '',
              'rfidcode': request['rfid_code']?.toString() ?? '',
              'image': request['avatar']?.toString() ?? '',
              'type': request['person_type'] ?? '',
              'rfidcode_num': request['rfid_num'] ?? '',
            },
          );
          print('Inserted: ${request['id']}');
        }
      }).catchError((error) {
        print('Error during sync: $error');
        throw error; // Rethrow error to stop further processing if needed
      });

      queryPromises.add(queryPromise);
    }

    // Wait for all queries to finish
    await Future.wait(queryPromises);
  });
}



Future<List<String>> syncAllStudents(List<Map<String, dynamic>> requests, Database db) async {
  // Initialiser la base de données

  // Démarrer la transaction
  return await db.transaction((txn) async {
    List<Future<String>> queryPromises = requests.map((request) async {
      // Vérifier si l'étudiant existe déjà dans la base de données
      List<Map> results = await txn.rawQuery(
        'SELECT id FROM students WHERE id = ?',
        [request['id']],
      );

      String resultMessage = '';

      if (results.isNotEmpty) {
        // L'étudiant existe, effectuer une mise à jour
        await txn.rawUpdate(
          'UPDATE students SET name = ?, rfidcode = ?, image = ? WHERE id = ?',
          [
            request['display_name'] ?? "",
            request['rfid']?.toString() ?? "",
            request['avatar']?.toString() ?? "",
            request['id'],
          ],
        );
        resultMessage = 'Updated: ${request['id']}';
      } else {
        // L'étudiant n'existe pas, effectuer une insertion
        await txn.rawInsert(
          'INSERT INTO students (id, name, rfidcode, image) VALUES (?, ?, ?, ?)',
          [
            request['id'],
            request['display_name'] ?? "",
            request['rfid']?.toString() ?? "",
            request['avatar']?.toString() ?? "",
          ],
        );
        resultMessage = 'Inserted: ${request['id']}';
      }
      return resultMessage;
    }).toList();

    // Attendre que toutes les requêtes soient terminées
    try {
      List<String> results = await Future.wait(queryPromises);
      return results; // Retourner les résultats des requêtes
    } catch (error) {
      throw 'Une erreur est survenue lors de la synchronisation des étudiants: $error';
    }
  });
}

Future<List<String>> syncAllAttendance(Database db, List<Map<String, dynamic>> requests) async {
  try {
    // Démarrer une transaction
    return await db.transaction((txn) async {
      List<String> results = [];

      for (var request in requests) {
        // Vérifier si l'ID existe déjà
        final existing = await txn.rawQuery(
          'SELECT id FROM africasystem WHERE id = ?',
          [request['id']],
        );

        if (existing.isNotEmpty) {
          // Si l'ID existe, mettre à jour l'enregistrement
          await txn.rawUpdate(
            '''
            UPDATE africasystem
            SET 
                name = ?,
                rfidcode = ?,
                image = ?,
                description = ?
            WHERE id = ?
            ''',
            [
              request['name'] ?? "",
              request['rfid_code'] ?? "",
              request['image_1920'] ?? "",
              request['name'] ?? "",
              request['id'],
            ],
          );
          results.add('Updated: ${request['id']}');
        } else {
          // Sinon, insérer un nouvel enregistrement
          await txn.rawInsert(
            '''
            INSERT INTO africasystem (
                id, name, rfidcode, image, description
            ) VALUES (?, ?, ?, ?, ?)
            ''',
            [
              request['id'],
              request['name'] ?? "",
              request['rfid_code'] ?? "",
              request['image_1920'] ?? "",
              request['name'] ?? "",
            ],
          );
          results.add('Inserted: ${request['id']}');
        }
      }

      // Retourner les résultats des opérations
      return results;
    });
  } catch (e) {
    throw Exception('Error during sync: ${e.toString()}');
  }
}


Future<Map<String, dynamic>> getAllAttendances(Database db) async {
  try {
    // Exécuter la requête SQL
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT attendance.*,
             africasystem.name AS user_name,
             africasystem.id AS user_id
      FROM attendance
      LEFT JOIN africasystem ON attendance.id_user = africasystem.id
      ORDER BY attendance.created_at DESC;
    ''');

    // Transformer les résultats en une liste
    List<Map<String, dynamic>> requests = results.map((row) => row).toList();

    // Retourner les données avec succès
    return {
      'data': requests,
      'success': true,
    };
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'error': error.toString(),
      'success': false,
    };
  }
}

Future<Map<String, dynamic>> getFilterAttendances(Database db) async {
  try {
    // Exécuter la requête SQL
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT a.*,
             af.name AS user_name,
             af.rfidcode,
             af.id AS user_id
      FROM africasystem af
      LEFT JOIN attendance a ON a.id_user = af.id AND a.updated_at = (
          SELECT MAX(updated_at)
          FROM attendance
          WHERE id_user = af.id
      )
      ORDER BY af.name ASC;
    ''');

    // Transformer les résultats en une liste
    List<Map<String, dynamic>> requests = results.map((row) => row).toList();

    // Retourner les données avec succès
    return {
      'data': requests,
      'success': true,
    };
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'error': error.toString(),
      'success': false,
    };
  }
}


Future<Map<String, dynamic>> updateAttendanceLocal(Database db, int id) async {
  try {
    // Exécuter la requête de mise à jour
    await db.rawUpdate(
      'UPDATE attendance SET isLocal = ? WHERE id = ?;',
      [0, id],
    );

    // Retourner le succès
    return {
      'data': 'types',
      'success': true,
    };
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'success': false,
      'message': error.toString(),
    };
  }
}

Future<Map<String, dynamic>> getUnSyncAttendance(Database db) async {
  try {
    // Requête pour récupérer les entrées non synchronisées
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM attendance WHERE isLocal = 1 ORDER BY updated_at ASC;',
    );

    // Transformer les résultats en une liste de requêtes
    final List<Map<String, dynamic>> requests = results;

    // Retourner les résultats avec succès
    return {
      'data': requests,
      'success': true,
    };
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'success': false,
      'message': error.toString(),
    };
  }
}


Future<Map<String, dynamic>> getUnSyncAttendanceLogs(Database db) async {
  try {
    // Requête pour récupérer les entrées de logs d'assistance
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT * FROM attendance_log ORDER BY datetime ASC;',
    );

    // Transformer les résultats en une liste de logs
    final List<Map<String, dynamic>> logs = results;

    // Retourner les résultats avec succès
    return {
      'data': logs,
      'success': true,
    };
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'success': false,
      'message': error.toString(),
    };
  }
}


Future<Map<String, dynamic>> deleteAttententLogs(Database db, int id) async {
  try {
    // Exécution de la requête SQL pour supprimer un log d'assistance par ID
    int result = await db.rawDelete(
      'DELETE FROM attendance_log WHERE id = ?;',
      [id],
    );

    // Si aucune ligne n'est affectée, cela signifie que l'ID n'existe pas
    if (result > 0) {
      return {
        'data': 'types',
        'success': true,
      };
    } else {
      return {
        'data': 'No record found to delete',
        'success': false,
      };
    }
  } catch (error) {
    // Gérer les erreurs et retourner une réponse avec succès = false
    return {
      'success': false,
      'message': error.toString(),
    };
  }
}


Future<Map<String, dynamic>> upsertAttendance(Database db, List<Map<String, dynamic>> dataList) async {
  try {
    await db.transaction((txn) async {
      for (var data in dataList) {
        final employee = data['employee'];
        final recordId = data['id']; // ID unique dans l'objet attendance
        final checkinTime = data['check_in'];
        final checkoutTime = data['check_out'] ?? null;
        final isCheckin = checkinTime != null && checkoutTime == null;
        final createdAt = data['create_date'];
        final userId = employee['id'];
        final name = employee['name'];

        // Vérifier si l'enregistrement existe déjà
        List<Map<String, dynamic>> existingRows = await txn.rawQuery(
            'SELECT * FROM attendance WHERE id = ?;', [recordId]);

        if (existingRows.isEmpty) {
          // Si l'enregistrement n'existe pas, rechercher la dernière ligne avec isLocal = 1
          List<Map<String, dynamic>> localRows = await txn.rawQuery(
              'SELECT * FROM attendance WHERE id_user = ? AND isLocal = 1 ORDER BY created_at DESC LIMIT 1;', [userId]);

          if (localRows.isEmpty) {
            // Aucune ligne locale, insérer la nouvelle ligne
            await txn.rawInsert(
              'INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) VALUES (?, ?, ?, ?, ?, ?, ?);',
              [recordId, userId, isCheckin ? 1 : 0, checkinTime, checkoutTime, createdAt, 0],
            );
            print('Nouvelle entrée insérée pour $name avec l\'ID $recordId');
          } else {
            // Comparer avec la dernière ligne locale
            final lastLocalEntry = localRows.first;
            final hasChanged = lastLocalEntry['checkin_time'] != checkinTime ||
                               lastLocalEntry['checkout_time'] != checkoutTime;

            if (hasChanged) {
              // Supprimer l'ancienne ligne locale et insérer la nouvelle
              await txn.rawDelete('DELETE FROM attendance WHERE id = ?', [lastLocalEntry['id']]);

              await txn.rawInsert(
                'INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) VALUES (?, ?, ?, ?, ?, ?, ?);',
                [recordId, userId, isCheckin ? 1 : 0, checkinTime, checkoutTime ?? lastLocalEntry['checkout_time'], createdAt, 0],
              );
              print('Ancienne entrée supprimée et nouvelle entrée insérée pour $name avec l\'ID $recordId');
            } else {
              print('Aucune modification pour $name avec l\'ID $recordId');
            }
          }
        } else {
          final existingEntry = existingRows.first;
          // Vérifier si les données ont changé
          final hasChanged = existingEntry['checkin_time'] != checkinTime ||
                             existingEntry['checkout_time'] != checkoutTime;

          if (hasChanged && existingEntry['isLocal'] == 0) {
            // Mettre à jour uniquement si les données sont différentes
            await txn.rawUpdate(
              'UPDATE attendance SET is_checkin = ?, checkin_time = ?, checkout_time = ?, isLocal = ? WHERE id = ?;',
              [isCheckin ? 1 : 0, checkinTime, checkoutTime, 0, recordId],
            );
            print('Entrée mise à jour pour $name avec l\'ID $recordId');
          } else {
            print('Aucune modification pour $name avec l\'ID $recordId');
          }
        }
      }
    });

    return {'data': 'Opération terminée pour tous les éléments de la liste', 'success': true};
  } catch (error) {
    return {'success': false, 'message': error.toString()};
  }
}

Future<Map<String, dynamic>> handleCreateAttendanceCorrect(
  int idUser, 
  Database db,
  String userName, 
  String rfidCode, 
  int? makeAttendanceId, 
  int timing, 
  Map<String, double>? coords, 
  String? checktime, 
  bool isStudent
) async {
  final model = isStudent ? 'attendance_students' : 'attendance';
  print("model...............$model");

  try {
    return await db.transaction((txn) async {
      // Vérifier la dernière ligne de l'utilisateur
      var results = await txn.rawQuery(
        'SELECT * FROM $model WHERE id_user = ? ORDER BY updated_at DESC LIMIT 1;',
        [idUser],
      );

      final currentTime = DateTime.now().toIso8601String();
      final currentHour = DateTime.now().hour;
      final createAt = DateTime.now().toIso8601String();
      final updatedAt = DateTime.now().toIso8601String();

      double? longitude = coords?['longitude'];
      double? latitude = coords?['latitude'];

      bool isCheckin = false;
      String? checkinTime;
      String? checkoutTime;
      String greeting = '';
      if (currentHour >= 5 && currentHour < 12) {
        greeting = 'Bonjour ';
      } else if (currentHour >= 12 && currentHour < 15) {
        greeting = 'Bon après-midi ';
      } else {
        greeting = 'Bonsoir ';
      }

      String finalMessage = '';
      if (results.isEmpty) {
        // Aucun enregistrement existant => on fait un check-in
        isCheckin = true;
        checkinTime = checktime ?? currentTime;

        finalMessage = '$greeting$userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat('HH:mm').format(DateTime.now())}';
        _ttsService.speakAttendance(finalMessage, true);
        // Insérer une nouvelle ligne de check-in
        await txn.rawInsert(
          'INSERT INTO $model (id_user, is_checkin, checkin_time, checkout_time, created_at, updated_at, make_attendance_id, longitude, latitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
          [idUser, isCheckin, checkinTime, checkoutTime, createAt, updatedAt, makeAttendanceId, longitude, latitude],
        );

        // Insérer dans attendance_log
        await txn.rawInsert(
          'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
          [userName, createAt, 'check_in', rfidCode, 'success', finalMessage],
        );

        return {'data': isCheckin, 'success': true, 'message': finalMessage};
      } else {
        final lastEntry = results.first;
        final checkin = DateTime.parse(
          (lastEntry['checkout_time'] ?? lastEntry['checkin_time'])?.toString() ?? ''
        );

        final current = checktime != null ? DateTime.parse(checktime) : DateTime.now();
        
        // Calculer la différence en millisecondes
        final timeDifference = current.difference(checkin).inMilliseconds;
        
        // Convertir la différence en minutes
        final minutesDifference = timeDifference / (1000 * 60);
        print("minutesDifference======================== $minutesDifference, timing $timing");

        if (minutesDifference <= timing) {
          final minutes = (minutesDifference).floor();
          final seconds = ((minutesDifference - minutes) * 60).round();
          finalMessage = '$userName, vous avez badgé il y a $minutes minutes et $seconds secondes. Vous pouvez encore badger dans ${5 - minutesDifference.floor()} minutes.';
          _ttsService.speakAttendance(finalMessage, true);
          // Insérer dans attendance_log
          await txn.rawInsert(
            'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
            [userName, createAt, 'unknow', rfidCode, 'failed', finalMessage],
          );

          return {'data': {}, 'success': false, 'message': finalMessage};
        } else {
          if (lastEntry['checkin_time'] != null && lastEntry['checkout_time'] == null) {
            // Dernière entrée est un check-in sans check-out => faire un check-out
            isCheckin = false;
            checkoutTime = checktime ?? currentTime;
            finalMessage = '$greeting$userName, Au revoir! Vous venez de quitter à : ${DateFormat('HH:mm').format(DateTime.now())}';
            _ttsService.speakAttendance(finalMessage, true);
            // Mettre à jour la dernière ligne pour ajouter le check-out
            await txn.rawUpdate(
              'UPDATE $model SET checkout_time = ?, isLocal = ?, updated_at = ?, make_attendance_id = ?, longitude = ?, latitude = ? WHERE id = ?;',
              [checkoutTime, 1, updatedAt, makeAttendanceId, longitude, latitude, lastEntry['id']],
            );

            // Insérer dans attendance_log
            await txn.rawInsert(
              'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
              [userName, createAt, 'check_out', rfidCode, 'success', finalMessage],
            );

            return {'data': isCheckin, 'success': true, 'message': finalMessage};
          } else {
            // Dernière entrée est un check-out ou un check-in avec check-out => faire un nouveau check-in
            isCheckin = true;
            checkinTime = checktime ?? currentTime;

            finalMessage = '$greeting$userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat('HH:mm').format(DateTime.now())}';
            _ttsService.speakAttendance(finalMessage, true);
            // Insérer une nouvelle ligne de check-in
            await txn.rawInsert(
              'INSERT INTO $model (id_user, is_checkin, checkin_time, checkout_time, created_at, updated_at, make_attendance_id, longitude, latitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
              [idUser, isCheckin, checkinTime, checkoutTime, createAt, updatedAt, makeAttendanceId, longitude, latitude],
            );

            // Insérer dans attendance_log
            await txn.rawInsert(
              'INSERT INTO attendance_log (nom, datetime, activity_name, rfid_code, status, message) VALUES (?, ?, ?, ?, ?, ?);',
              [userName, createAt, 'check_in', rfidCode, 'success', finalMessage],
            );

            return {'data': isCheckin, 'success': true, 'message': finalMessage};
          }
        }
      }
    });
  } catch (error) {
    print("Erreur lors de la transaction: $error");
    return {'success': false, 'message': 'Erreur lors de la transaction'};
  }
}

  Future<void> showCustomMessage(
      String title, String message, String type, String position) async {
    // Affichez un message personnalisé ici
    print("$title: $message");
  }

Future<void> getEmployee(Database db) async {
    await updateAttendencesBannerMessage("Synchronisation des employés en cours");

    try {
      // Simuler la récupération des données des employés
      final data = {}; // Remplacez cette ligne par la récupération réelle des données
      if (data != null && data['success']) {
        final data1 = data['success'] ? data['data'] : [];
        print("getEmployee================ ${data1.length}");
        await syncAllPartners(data1, db);
        await updateAttendencesBannerMessage("La synchronisation des employés a réussi");
        await showCustomMessage("Information", "La synchronisation des employés a réussi", "success", "center");
      } else {
        await showCustomMessage("Information", "Erreur dans les données", "warning", "bottom");
      }
    } catch (e) {
      await showCustomMessage("Information", 'Une erreur s\'est produite: ${e.toString()}', "warning", "bottom");
      print('Une erreur s\'est produite: $e');
    }
  }

  Future<void> getStudents(Database db) async {
    await updateAttendencesBannerMessage("Synchronisation des étudiants en cours");

    try {
      // Simuler la récupération des données des étudiants
      final students = {}; // Remplacez cette ligne par la récupération réelle des données
      if (students != null && students['success']) {
        final data1 = students['success'] ? students['data'] : [];
        print("getStudents================ ${data1.length}");
        await syncAllPartners(data1, db);  // Remplacez `syncAllPartners` par la fonction appropriée pour les étudiants
        await updateAttendencesBannerMessage("La synchronisation des étudiants a réussi");
        await showCustomMessage("Information", "La synchronisation des étudiants a réussi", "success", "center");
      } else {
        await showCustomMessage("Information", "Erreur dans les données", "warning", "bottom");
      }
    } catch (e) {
      await showCustomMessage("Information", 'Une erreur s\'est produite: ${e.toString()}', "warning", "bottom");
      print('Une erreur s\'est produite: $e');
    }
  }



}

  Future<void> updateAttendencesBannerMessage(String message) async {
    // Mettez à jour le message de la bannière ici
    print(message);
  }



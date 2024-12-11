import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/database_service.dart';
import '../models/user_record.dart';
import 'package:intl/intl.dart';
import '../services/tts_service.dart';

class AttendanceService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TTSService _ttsService = TTSService();
    // Singleton instance
  static final AttendanceService instance = AttendanceService._();

  // Private constructor
  AttendanceService._();

Future<Map<String, dynamic>> handleCreateAttendanceCorrect(
    int idUser, String userName, Database db) async {
  try {
    final currentTime = DateTime.now().toIso8601String();
    final currentHour = DateTime.now().hour;
    final createAt = DateTime.now().toIso8601String();
    bool isCheckin;
    String? checkinTime;
    String? checkoutTime;

    // Determine greeting based on the time of day
    String greeting = '';
    if (currentHour >= 5 && currentHour < 12) {
      greeting = 'Bonjour ';
    } else if (currentHour >= 12 && currentHour < 15) {
      greeting = 'Bon après-midi ';
    } else {
      greeting = 'Bonsoir ';
    }

    String finalMessage = '';

    // Fetch the last entry for the user
    final List<Map<String, dynamic>> rows = await db.rawQuery(
        'SELECT * FROM attendance WHERE id_user = ? ORDER BY created_at DESC LIMIT 1;',
        [idUser]);

    if (rows.isEmpty) {
      // No existing record => Perform check-in
      isCheckin = true;
      checkinTime = currentTime;

      // Insert a new check-in record
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO attendance (id_user, is_checkin, checkin_time, checkout_time, created_at) VALUES (?, ?, ?, ?, ?);',
          [idUser, isCheckin ? 1 : 0, checkinTime, checkoutTime, createAt],
        );
      });

      finalMessage = '$greeting$userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat("HH:mm").format(DateTime.now())}';
      await _ttsService.speakAttendance(finalMessage, true);
      return {'data': isCheckin, 'success': true, 'message': finalMessage};
    } else {
      final lastEntry = rows.first;

      if (lastEntry['is_checkin'] == 1 && lastEntry['checkout_time'] == null) {
        // Last entry is a check-in without checkout => Perform checkout
        isCheckin = false;
        checkoutTime = currentTime;

        // Update the last entry to add checkout
        await db.transaction((txn) async {
          await txn.rawUpdate(
            'UPDATE attendance SET checkout_time = ?, isLocal = ? WHERE id = ?;',
            [checkoutTime, 1, lastEntry['id']],
          );
        });

        finalMessage = '$greeting$userName, Au revoir! Vous venez de quitter à : ${DateFormat("HH:mm").format(DateTime.now())}';
        await _ttsService.speakAttendance(finalMessage, true);
        return {'data': isCheckin, 'success': true, 'message': finalMessage};
      } else {
        // Last entry is a checkout or a check-in with checkout => Perform new check-in
        isCheckin = true;
        checkinTime = currentTime;

        // Insert a new check-in record
        await db.transaction((txn) async {
          await txn.rawInsert(
            'INSERT INTO attendance (id_user, is_checkin, checkin_time, checkout_time, created_at) VALUES (?, ?, ?, ?, ?);',
            [idUser, isCheckin ? 1 : 0, checkinTime, checkoutTime, createAt],
          );
        });

        finalMessage = '$greeting$userName, Bienvenue! Vous venez de vous enregistrer à : ${DateFormat("HH:mm").format(DateTime.now())}';
        await _ttsService.speakAttendance(finalMessage, true);
        return {'data': isCheckin, 'success': true, 'message': finalMessage};
      }
    }
  } catch (error) {
    print("Error: $error");
    return {'data': null, 'success': false, 'message': 'Erreur lors de la vérification'};
  }
}

  /// Upsert attendance records (either insert or update existing ones)
  Future<String> upsertAttendance(List<Map<String, dynamic>> dataList) async {
    final db = await _databaseService.database;

    // Démarrer la transaction pour gérer les insertions/mises à jour
    await db.transaction((txn) async {
      for (var data in dataList) {
        final employee = data['employee'];
        final int id = employee['id'];
        final String name = employee['name'];
        final int recordId = data['id'];  // ID unique pour l'objet attendance
        final String checkinTime = data['check_in'];
        final String checkoutTime = data['check_out'] ?? null;
        final bool isCheckin = checkinTime != null && checkoutTime == null;
        final String createdAt = data['create_date'];

        // Vérifier si l'enregistrement existe déjà
        List<Map<String, dynamic>> rows = await txn.rawQuery(
          'SELECT * FROM attendance WHERE id = ?;',
          [recordId],
        );

        if (rows.isEmpty) {
          // Si l'enregistrement n'existe pas, rechercher la dernière ligne avec isLocal = true
          List<Map<String, dynamic>> localRows = await txn.rawQuery(
            'SELECT * FROM attendance WHERE id_user = ? AND isLocal = 1 ORDER BY created_at DESC LIMIT 1;',
            [id],
          );

          if (localRows.isEmpty) {
            // Aucune ligne locale, insérer une nouvelle ligne
            await txn.rawInsert(
              'INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) VALUES (?, ?, ?, ?, ?, ?, ?);',
              [recordId, id, isCheckin ? 1 : 0, checkinTime, checkoutTime, createdAt, 0],
            );
            print('Nouvelle entrée insérée pour $name avec l\'ID $recordId');
          } else {
            // Comparer avec la dernière ligne locale
            var lastLocalEntry = localRows.first;
            bool hasChanged = lastLocalEntry['checkin_time'] != checkinTime ||
                lastLocalEntry['checkout_time'] != checkoutTime;

            if (hasChanged) {
              // Supprimer l'ancienne ligne locale et insérer la nouvelle
              await txn.rawDelete(
                'DELETE FROM attendance WHERE id = ?;',
                [lastLocalEntry['id']],
              );
              await txn.rawInsert(
                'INSERT INTO attendance (id, id_user, is_checkin, checkin_time, checkout_time, created_at, isLocal) VALUES (?, ?, ?, ?, ?, ?, ?);',
                [
                  recordId,
                  id,
                  isCheckin ? 1 : 0,
                  checkinTime,
                  checkoutTime ?? lastLocalEntry['checkout_time'],
                  createdAt,
                  0
                ],
              );
              print('Ancienne entrée supprimée et nouvelle entrée insérée pour $name avec l\'ID $recordId');
            } else {
              print('Aucune modification pour $name avec l\'ID $recordId');
            }
          }
        } else {
          // Si l'enregistrement existe déjà, vérifier si les données ont changé
          var existingEntry = rows.first;
          bool hasChanged = existingEntry['checkin_time'] != checkinTime ||
              existingEntry['checkout_time'] != checkoutTime;

          if (hasChanged) {
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

    return 'Opération terminée pour tous les éléments de la liste';
  }

}



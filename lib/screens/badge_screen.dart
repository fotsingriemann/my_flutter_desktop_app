import 'package:flutter/material.dart';
import '../widgets/animated_logo.dart';
import '../widgets/settings_panel.dart';
import '../widgets/manual_input.dart';
import '../widgets/rfid_dialog.dart';
import '../theme/colors.dart';
import '../services/tts_service.dart';
import '../services/rfid_service.dart';
import '../services/database_service.dart';
import '../models/user_record.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  bool _isVoiceEnabled = true;
  bool _isFrench = true;
  bool _isManualInputVisible = false;
  final TTSService _ttsService = TTSService();
  final RFIDService _rfidService = RFIDService();

  @override
@override
void initState() {
  super.initState();
  _initializeDatabase();
 
}

Future<void> _initializeDatabase() async {
  try {
    // Initialize the database and insert default users
    await DatabaseService.instance.database;
   print("bonjour a tous");
    // Optionally, you can call a method to ensure default users are inserted, if needed:
    // await DatabaseService.instance.insertDefaultUsers();
    
    _ttsService.speakGreeting(_isFrench);
  } catch (e) {
    print('Error initializing database: $e');
  }
}


Future<void> _handleRfidInput(String rfidCode) async {
  try {
    // Fetch user data from the database
    final user = await _rfidService.getUserData(rfidCode);
    print("Get the data of the user");

    // if (_isVoiceEnabled) {
    //   await _ttsService.speakRfidCode(rfidCode, _isFrench);
    // }

    if (user != null) {
      // Save the record in the database
      print("The user is found");

      // Display user details in the dialog
      if (mounted) {
        _showRfidDialog(user.name, user.imageUrl);
      }
    } else {
      // Handle unknown user
      if (mounted) {
        _showRfidDialog('Utilisateur inconnu', null);
      }
    }
  } catch (e) {
    // Handle errors
    if (mounted) {
      _showRfidDialog('Erreur: $e', null);
    }
  }
}

void _showRfidDialog(String name, String? imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RFIDDialog(name: name, imageUrl: imageUrl);
    },
  );

    // Automatically close the dialog after 2 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.offWhite,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const AnimatedLogo(),
                const SizedBox(height: 40),
                SettingsPanel(
                  isVoiceEnabled: _isVoiceEnabled,
                  isFrench: _isFrench,
                  onVoiceChanged: (value) {
                    setState(() => _isVoiceEnabled = value);
                  },
                  onLanguageChanged: (value) {
                    setState(() => _isFrench = value);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isManualInputVisible = !_isManualInputVisible;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    child: Text(
                      'Entrer manuellement un code RFID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_isManualInputVisible) ...[
                  const SizedBox(height: 30),
                  ManualInput(
                    onRfidInput: _handleRfidInput,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

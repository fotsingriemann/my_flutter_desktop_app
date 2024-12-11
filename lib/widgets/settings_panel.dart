import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SettingsPanel extends StatelessWidget {
  final bool isVoiceEnabled;
  final bool isFrench;
  final ValueChanged<bool> onVoiceChanged;
  final ValueChanged<bool> onLanguageChanged;

  const SettingsPanel({
    super.key,
    required this.isVoiceEnabled,
    required this.isFrench,
    required this.onVoiceChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Scannez une carte RFID pour afficher les informations complètes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          _buildSwitchRow(
            'Activer l\'IA :',
            isVoiceEnabled,
            onVoiceChanged,
          ),
          const SizedBox(height: 20),
          _buildSwitchRow(
            'Langue (Français/Anglais) :',
            isFrench,
            onLanguageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
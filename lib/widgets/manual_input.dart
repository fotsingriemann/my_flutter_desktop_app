import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class ManualInput extends StatefulWidget {
  final Function(String) onRfidInput;

  const ManualInput({
    super.key,
    required this.onRfidInput,
  });

  @override
  State<ManualInput> createState() => _ManualInputState();
}

class _ManualInputState extends State<ManualInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _inputTimer;

  @override
  void initState() {
    super.initState();
    _ensureFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _inputTimer?.cancel();
    super.dispose();
  }

  void _ensureFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  void _onChanged(String value) {
    _inputTimer?.cancel();
    if (value.isNotEmpty) {
      _inputTimer = Timer(const Duration(milliseconds: 2000), () {
        widget.onRfidInput(value);
        _controller.clear();
        _ensureFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.text,
        onChanged: _onChanged,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        ],
        decoration: InputDecoration(
          labelText: 'Code RFID',
          hintText: 'Entrez un code RFID',
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
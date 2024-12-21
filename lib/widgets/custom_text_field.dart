import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/color_screen.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final IconData suffixIcon;
  final bool issuffixIcon;
  final TextInputType type;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Function? onPressed;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.issuffixIcon = false,
    this.suffixIcon = Icons.location_on_outlined,
    this.validator,
    this.type = TextInputType.text,
    this.inputFormatters, this.onPressed,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = false;
  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.type,
      controller: widget.controller,
      obscureText: _isObscured,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: ScreenColor.color6),
        suffixIcon: widget.issuffixIcon
            ? IconButton(
          onPressed: () => widget.onPressed,
          icon: Icon(widget.suffixIcon),
        )
            : widget.obscureText
            ? IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: ScreenColor.color2,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ScreenColor.color2),
        ),
        focusColor: ScreenColor.color6,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ScreenColor.color6, width: 2),
        ),
      ),
    );
  }
}
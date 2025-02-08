import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  final String label;
  final Widget prefixIcon;
  final bool isPassword;
  final String hintText;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  CustomTextField({
    required this.label,
    required this.prefixIcon,
    this.isPassword = false,
    required this.hintText,
    required this.validator,
    required this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
          validator: widget.validator,
          obscureText: widget.isPassword ? _isObscure : false,
          controller: _controller,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey),
            labelText: widget.label,
            labelStyle: GoogleFonts.getFont(
              'Nunito Sans',
              color: Color(0xFF7F909F),
              fontSize: 14,
              letterSpacing: 0.1,
              height: 1.7,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(10.0),
              child: widget.prefixIcon,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}

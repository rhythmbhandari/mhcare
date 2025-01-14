import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom Text Form Field component
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    Key? key,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.color = Colors.white,
    required this.textInputType,
    required this.labelText,
    required this.inputFormatters,
    required this.textController,
    required this.onChanged,
    this.errorBool = false,
  }) : super(key: key);

  final String labelText;
  final bool readOnly;
  final Color color;
  final bool
      obscureText; // Whether the text form field should obscure text (e.g., for passwords)
  final TextInputType textInputType; // Input formatters for the text form field
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? textController;
  final void Function(String)? onChanged;
  final bool errorBool;

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText; // Local state for managing obscure text

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 0.015 * MediaQuery.of(context).size.height,
      ),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: widget.errorBool ? Colors.red : Colors.grey,
          width: 1,
        ),
      ),
      child: TextFormField(
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Colors.black87),
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        controller: widget.textController,
        inputFormatters: widget.inputFormatters,
        obscureText: _obscureText,
        keyboardType: widget.textInputType,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Auto float label behavior
          fillColor: Colors.white,
          filled: false,
          border: InputBorder.none, // Remove default border
          labelText: widget.labelText,
          labelStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.grey),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility
                        : Icons.visibility_off, // Icon for showing/hiding text
                    color: Colors.grey,
                  ),
                  onPressed: _toggleObscureText,
                )
              : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ButtonsWidget extends StatelessWidget {
  final String name;
  final void Function()? onPressed;
  final bool isLoading;

  const ButtonsWidget({
    super.key,
    required this.name,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed, // Disable tap if loading
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(220, 53, 69, 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white), // White color for the loading spinner
                  ),
                )
              : Text(name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
        ),
      ),
    );
  }
}

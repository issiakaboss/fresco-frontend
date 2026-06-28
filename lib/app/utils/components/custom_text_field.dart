import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Variable locale réactive propre à l'instance
    final RxBool isObscured = true.obs;

    // Étape 1 : On extrait la construction de base du TextFormField
    Widget buildTextFormField() {
      return TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword
            ? isObscured.value
            : false, // Lu uniquement si isPassword est true
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade500, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  onPressed: () => isObscured.toggle(),
                )
              : null,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.amber.shade800, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade600, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade600, width: 1.5),
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Étape 2 : On n'enveloppe avec Obx QUE si c'est un mot de passe
    if (isPassword) {
      return Obx(() => buildTextFormField());
    } else {
      return buildTextFormField();
    }
  }
}

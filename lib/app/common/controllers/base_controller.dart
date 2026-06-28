// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/core/network/api_exception.dart';
import 'package:get/get.dart';

mixin BaseController {
  void handleError(dynamic error) {
    debugPrint("❌ [BaseController] Erreur interceptée : $error");
    if (Get.isDialogOpen ?? false) Get.back();
    if (error is ApiException) {
      String title = "Une erreur est survenue";

      if (error is ServiceUnavailableException) {
        title = "Service Indisponible 🛠️";
      } else if (error.statusCode == 422) {
        title = "Données Invalides ⚠️";
      } else if (error.statusCode == 500) {
        title = "Erreur Serveur 🔥";
      }

      _showErrorSnackbar(title, error.message ?? "Erreur inconnue");
      return;
    }

    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('timeout')) {
      _showErrorSnackbar(
        "Problème de Connexion 📡",
        "Impossible de joindre le serveur. Vérifie ta connexion Internet.",
      );
      return;
    }

    _showErrorSnackbar("Erreur", error.toString());
  }

  // --- DESIGN DES NOTIFICATIONS ---
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[800],
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 26,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

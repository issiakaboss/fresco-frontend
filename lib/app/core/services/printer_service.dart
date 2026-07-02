import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrinterService extends GetxService {
  static PrinterService get to => Get.find();

  // Variables réactives pour stocker l'état global des périphériques
  final selectedPrinter = "Aucune imprimante sélectionnée".obs;
  final isConnected = false.obs;
  final availablePrinters = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    scanPrinters(); // Recherche automatique au chargement
  }

  // Simulation ou scan réel des imprimantes (Bluetooth / Réseau / USB)
  Future<void> scanPrinters() async {
    availablePrinters.value = [
      "Imprimante Ticket Caisse (Bluetooth)",
      "Imprimante Reçu Cuisine (WiFi - 192.168.1.100)",
      "Imprimante Comptoir (USB)",
    ];
  }

  Future<bool> connectToPrinter(String printerName) async {
    try {
      // Écrire ici les wrappers pour esc_pos / thermal_printer
      selectedPrinter.value = printerName;
      isConnected.value = true;
      debugPrint("🖨️ Connecté avec succès à : $printerName");
      return true;
    } catch (e) {
      isConnected.value = false;
      return false;
    }
  }

  // C'est ici que tu formateras le ticket textuel ou binaire
  Future<void> printOrderTicket(dynamic order) async {
    if (!isConnected.value) {
      Get.snackbar("Imprimante hors-ligne", "Le ticket est sauvegardé mais l'impression a échoué.",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    
    debugPrint("--------------------------------");
    debugPrint("       MAISONNETTE GARBA        ");
    debugPrint("   Ticket N° : ${order['ticket_number'] ?? '00'} ");
    debugPrint("--------------------------------");
    debugPrint("Type: ${order['service_type'] == 'sur_place' ? 'SUR PLACE' : 'A EMPORTER'}");
    debugPrint("Plat: ${order['base_plat']}");
    debugPrint("Notes: ${order['notes'] ?? 'Aucune'}");
    debugPrint("--------------------------------");
    debugPrint("Total: ${order['total_price']} F CFA");
    debugPrint("--------------------------------");
  }
}
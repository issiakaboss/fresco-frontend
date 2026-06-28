import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/printer_service.dart';

class PrinterSettingView extends StatelessWidget {
  const PrinterSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final printerService = PrinterService.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Configuration Imprimantes"),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut de connexion actuel
            Obx(
              () => Card(
                color: printerService.isConnected.value
                    ? Colors.amber[50]
                    : Colors.red[50],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: printerService.isConnected.value
                        ? Colors.amber
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    printerService.isConnected.value
                        ? Icons.print_rounded
                        : Icons.print_disabled_rounded,
                    color: printerService.isConnected.value
                        ? Colors.amber[800]
                        : Colors.red[800],
                    size: 30,
                  ),
                  title: const Text(
                    "Statut Matériel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(printerService.selectedPrinter.value),
                  trailing: printerService.isConnected.value
                      ? const Badge(
                          label: Text("Actif"),
                          backgroundColor: Colors.amber,
                        )
                      : const Badge(
                          label: Text("Déconnecté"),
                          backgroundColor: Colors.red,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Appareils Disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => printerService.scanPrinters(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Actualiser"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Liste des périphériques
            Expanded(
              child: Obx(() {
                if (printerService.availablePrinters.isEmpty) {
                  return const Center(child: Text("Aucun appareil détecté."));
                }
                return ListView.builder(
                  itemCount: printerService.availablePrinters.length,
                  itemBuilder: (context, index) {
                    final printer = printerService.availablePrinters[index];
                    return Obx(() {
                      final isCurrent =
                          printerService.selectedPrinter.value == printer;
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isCurrent
                                ? Colors.amber.shade800
                                : Colors.grey.shade200,
                            width: isCurrent ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            printer,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing:
                              isCurrent && printerService.isConnected.value
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.amber[800],
                                )
                              : const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                ),
                          onTap: () async {
                            bool success = await printerService
                                .connectToPrinter(printer);
                            if (success) {
                              Get.snackbar("Succès", "Connecté à $printer");
                            }
                          },
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

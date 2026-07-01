import 'package:flutter/material.dart';
import 'package:fresco_shop/app/core/services/printer_service.dart';
import 'package:get/get.dart';
import '../../../data/models/order_request.dart';
import '../../../data/providers/order_provider.dart';

class CaisseController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final orderRx = OrderRequest().obs;
  final isLoading = false.obs;
  final notesController = TextEditingController();

  // --- Variables pour la Gestion de la Modification ---
  final isEditing = false.obs;
  int? editingOrderId;

  final selectedPrinter = "Imprimante Caisse (Bluetooth)".obs;

  final FocusNode notesFocusNode = FocusNode();

  void selectBasePlat(String type) {
    final current = orderRx.value;
    current.basePlat = type;
    switch (type) {
      case 'plat_500':
        current.attiekePrice = 200;
        current.fishCount = 1;
        current.fishPrice = 300;
        break;
      case 'plat_600':
        current.attiekePrice = 300;
        current.fishCount = 1;
        current.fishPrice = 300;
        break;
      case 'plat_800':
        current.attiekePrice = 200;
        current.fishCount = 2;
        current.fishPrice = 600;
        break;
      case 'plat_1000':
        current.attiekePrice = 400;
        current.fishCount = 2;
        current.fishPrice = 600;
        break;
      case 'personnalise':
        if (current.attiekePrice == 0 && current.fishCount == 0) {
          current.attiekePrice = 100;
          current.fishCount = 1;
          current.fishPrice = 300;
        }
        showCustomizationBottomSheet();
        break;
    }
    orderRx.refresh();
  }

  bool isNoteSelected(String note) {
    final currentText = notesController.text.toLowerCase();
    return currentText.contains(note.toLowerCase());
  }

  void toggleNote(String note) {
    String currentText = notesController.text.trim();
    List<String> activeNotes = currentText.isEmpty
        ? []
        : currentText
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

    final existingIndex = activeNotes.indexWhere(
      (element) => element.toLowerCase() == note.toLowerCase(),
    );

    if (existingIndex != -1) {
      activeNotes.removeAt(existingIndex);
    } else {
      activeNotes.add(note);
    }

    notesController.text = activeNotes.join(', ');
    orderRx.value.notes = notesController.text;
    orderRx.refresh();
  }

  void updateOeufs(int delta) {
    if (orderRx.value.extraOeufs + delta >= 0) {
      orderRx.value.extraOeufs += delta;
      orderRx.refresh();
    }
  }

  void updateEau(int delta) {
    if (orderRx.value.extraEau + delta >= 0) {
      orderRx.value.extraEau += delta;
      orderRx.refresh();
    }
  }

  void setAllocoPrice(int price) {
    if (price >= 0) {
      orderRx.value.extraAllocoPrice = price;
      orderRx.refresh();
    }
  }

  void setTomatePrice(int price) {
    if (price >= 0) {
      orderRx.value.extraTomatePrice = price;
      orderRx.refresh();
    }
  }

  void setMayonnaisePrice(int price) {
    if (price >= 0) {
      orderRx.value.extraMayonnaisePrice = price;
      orderRx.refresh();
    }
  }

  void setBissapPrice(int price) {
    if (price >= 0) {
      orderRx.value.extraBissapPrice = price;
      orderRx.refresh();
    }
  }

  void setServiceType(String type) {
    orderRx.value.serviceType = type;
    orderRx.refresh();
  }

  // Ajuster le montant de l'attiéké (par pas de 100F)
  void adjustAttieke(int offset) {
    final current = orderRx.value;

    // Évite d'aller en dessous de 0 F
    if (current.attiekePrice + offset >= 0) {
      current.attiekePrice += offset;
      orderRx.refresh();
    }
  }

  // Ajuster le nombre de poissons (Le prix se calcule tout seul : count * 300F)
  void adjustFish(int offset) {
    final current = orderRx.value;
    const int prixUnitairePoisson = 300;

    if (current.fishCount + offset >= 0) {
      current.fishCount += offset;
      current.fishPrice = current.fishCount * prixUnitairePoisson;
      orderRx.refresh();
    }
  }

  /// 📥 Charger une commande de l'historique pour la modifier
  void loadOrderForEdition(OrderRequest order) {
    if (order.id == null) return;

    isEditing.value = true;
    editingOrderId = order.id;

    // On injecte directement la commande complète dans notre objet réactif
    orderRx.value = order;
    notesController.text = order.notes;

    orderRx.refresh();
  }

  /// 📣 Soumettre la commande (Création OU Modification)
  Future<void> submitOrder() async {
    try {
      isLoading.value = true;
      orderRx.value.notes = notesController.text;

      dynamic response;

      if (isEditing.value && editingOrderId != null) {
        // Mode ÉDITION -> PUT /orders/{id}
        response = await _orderProvider.updateOrder(
          editingOrderId!,
          orderRx.value,
        );
      } else {
        // Mode CRÉATION -> POST /orders
        response = await _orderProvider.createOrder(orderRx.value);
      }

      if (response != null && response['order'] != null) {
        // On imprime le ticket mis à jour ou le nouveau ticket
        await PrinterService.to.printOrderTicket(response['order']);
        resetForm();
      }
    } catch (e) {
      debugPrint("Erreur lors de la soumission : $e");
    } finally {
      isLoading.value = false;
    }
  }

  void showCustomizationBottomSheet() {
    Get.bottomSheet(
      Obx(() {
        final order = orderRx.value;
        final totalPlat = order.attiekePrice + order.fishPrice;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de drag supérieure
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Plat sur mesure 🎯",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$totalPlat F",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ligne Attiéké
              _buildBottomSheetRow(
                label: "Montant Attiéké",
                value: "${order.attiekePrice} F",
                onDecrement: () => adjustAttieke(-100),
                onIncrement: () => adjustAttieke(50),
              ),

              const SizedBox(height: 12),

              // Ligne Poisson
              _buildBottomSheetRow(
                label: "Quantité Poisson",
                value: "${order.fishCount} p",
                subtitle: "Total poisson: ${order.fishPrice} F",
                onDecrement: () => adjustFish(-1),
                onIncrement: () => adjustFish(1),
              ),

              const SizedBox(height: 24),

              // Bouton de validation
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Valider la composition",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBottomSheetRow({
    required String label,
    required String value,
    String? subtitle,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.redAccent,
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 50),
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔄 Remise à zéro complète (et sortie du mode édition)
  void resetForm() {
    isEditing.value = false;
    editingOrderId = null;
    orderRx.value = OrderRequest();
    notesController.clear();
    orderRx.refresh();
    print(orderRx.toJson());
  }

  @override
  void onClose() {
    notesController.dispose();
    notesFocusNode.dispose();
    super.onClose();
  }
}

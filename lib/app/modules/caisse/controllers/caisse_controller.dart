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

  // --- Configuration Notes Prédéfinies ---
  final List<String> predefinedNotes = [
    "Sans oignon",
    "1 bidon de bissap",
    "Poisson bien cuit",
    "Piment vert uniqment",
  ];

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

  void setServiceType(String type) {
    orderRx.value.serviceType = type;
    orderRx.refresh();
  }

  void togglePiment() {
    orderRx.value.pimentAPart = !orderRx.value.pimentAPart;
    orderRx.refresh();
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

        Get.snackbar(
          isEditing.value ? "Modifié 🎉" : "Succès 🎉",
          "Ticket ${response['order']['ticket_number']} ${isEditing.value ? 'mis à jour' : 'validé'} et imprimé sur ${PrinterService.to.selectedPrinter.value} !",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
        );
        resetForm();
      }
    } catch (e) {
      debugPrint("Erreur lors de la soumission : $e");
    } finally {
      isLoading.value = false;
    }
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

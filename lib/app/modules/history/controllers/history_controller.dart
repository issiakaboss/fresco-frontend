import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:fresco_shop/app/modules/caisse/controllers/caisse_controller.dart';
import 'package:get/get.dart';
import '../../../data/providers/order_provider.dart';

class HistoryController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final ScrollController scrollController = ScrollController();

  // Utilisation du modèle fortement typé
  final orders = <OrderRequest>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final totalSales = 0.obs;

  final currentFilter = 'today'.obs;

  int _currentPage = 1;
  bool _hasMore = false;
final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final FocusNode searchFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    searchFocusNode.dispose();
    super.onClose();
  }

  void searchOrders(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
 _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchHistory(); 
    });
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      _currentPage = 1;

      final response = await _orderProvider.getCashierOrders(
        filter: currentFilter.value,
        page: _currentPage,
        search: searchController.text,
      );

      if (response != null && response['orders'] != null) {
        totalSales.value = response['total_sales'] ?? 0;

        // Conversion de la liste de Maps en liste de OrderModel
        final List<dynamic> rawOrders = response['orders'];
        orders.assignAll(
          rawOrders.map((json) => OrderRequest.fromJson(json)).toList(),
        );

        if (response['meta'] != null) {
          _hasMore = response['meta']['has_more'] ?? false;
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de l'historique : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore) return;

    try {
      isLoadingMore.value = true;
      _currentPage++;

      final response = await _orderProvider.getCashierOrders(
        filter: currentFilter.value,
        page: _currentPage,
        search: searchController.text,
      );

      if (response != null && response['orders'] != null) {
        final List<dynamic> rawOrders = response['orders'];
        orders.addAll(
          rawOrders.map((json) => OrderRequest.fromJson(json)).toList(),
        );
        _hasMore = response['meta']['has_more'] ?? false;
      }
    } catch (e) {
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void changeFilter(String newFilter) {
    currentFilter.value = newFilter;
    searchController.clear();
    fetchHistory();
  }

void onEditOrderPressed(OrderRequest order) {
  // On récupère l'instance du contrôleur de la caisse
  final caisseController = Get.find<CaisseController>();
  
  // On lui injecte la commande à modifier
  caisseController.loadOrderForEdition(order);
}
  // Typage strict ici aussi
  Future<void> cancelOrder(OrderRequest order) async {
    if (!order.isEnAttente) {
      Get.snackbar(
        "Action impossible",
        "La cuisine prépare déjà ce plat.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône d'avertissement stylisée
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Titre principal
              Text(
                "Annuler le Ticket ${order.ticketNumber ?? '---'}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212529),
                ),
              ),
              const SizedBox(height: 12),

              // Texte explicatif explicite
              Text(
                "Cette action va supprimer définitivement la commande en cuisine. Souhaitez-vous continuer ?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'action horizontaux bien dimensionnés
              Row(
                children: [
                  // Bouton Retour / Annuler l'action
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Retour",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bouton de confirmation d'annulation destructrice
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Get.back();
                        isLoading.value = true;
                        if (order.id != null) {
                          bool success = await _orderProvider.cancelOrder(
                            order.id!,
                          );
                          if (success) {
                            orders.remove(order);
                            Get.snackbar(
                              "Annulé",
                              "Commande supprimée avec succès",
                              backgroundColor: Colors.red.shade800,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(15),
                            );
                          }
                        }
                        isLoading.value = false;
                      },
                      child: const Text(
                        "Confirmer",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      transitionCurve: Curves.easeInOut,
    );
  }


}

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/utils/helpers/storage_helper.dart';
import 'package:get/get.dart';
import '../../../data/models/order_request.dart'; // Ajuste le chemin selon ton projet
import '../../../data/providers/order_provider.dart';

class CuisineController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();

  // Listes réactives pour séparer les flux de travail
  final ordersEnAttente = <OrderRequest>[].obs;
  final RxList<OrderRequest> ordersEnCours = <OrderRequest>[].obs;
  final isLoading = false.obs;
  final isfinishPrepLoading = false.obs;
  var isAutoNextEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    isAutoNextEnabled.value = StorageHelper.getAutoNextStatus();
    fetchCuisineOrders();
  }

  void toggleAutoNext() async{
    isAutoNextEnabled.value = !isAutoNextEnabled.value;
    await StorageHelper.saveAutoNextStatus(isAutoNextEnabled.value);
    if (isAutoNextEnabled.value && ordersEnCours.isEmpty) {
      _checkAndTriggerAutoNext();
    }
  }

  void _checkAndTriggerAutoNext() {
    // Si l'option est active ET qu'il n'y a plus rien en préparation
    if (isAutoNextEnabled.value && ordersEnCours.isEmpty) {
      if (ordersEnAttente.isNotEmpty) {
        final nextOrder = ordersEnAttente.first;
        startPreparation(nextOrder.id!);
      }
    }
  }

  /// 📥 Charger les commandes actives (En attente et En préparation)
  Future<void> fetchCuisineOrders() async {
    try {
      isLoading.value = true;
      final response = await _orderProvider.getActiveOrders();

      if (response != null && response['data'] != null) {
        final List<dynamic> rawOrders = response['data'];
        List<OrderRequest> allOrders = rawOrders
            .map((json) => OrderRequest.fromJson(json))
            .toList();
        ordersEnAttente.assignAll(
          allOrders.where((o) => o.status == 'en_attente').toList(),
        );
        ordersEnCours.assignAll(
          allOrders.where((o) => o.status == 'preparation').toList(),
        );
        _checkAndTriggerAutoNext();
      }
    } catch (e) {
      debugPrint("Erreur chargement cuisine : $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ⚡ Passer une commande de "En attente" à "En préparation"
  Future<void> startPreparation(int orderId) async {
    try {
      final response = await _orderProvider.updateStatus(
        orderId,
        'preparation',
      );
      if (response != null && response['error'] == null) {
        final index = ordersEnAttente.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final oldOrder = ordersEnAttente.removeAt(index);
          final updatedOrder = oldOrder.copyWith(status: 'preparation');
          ordersEnCours.add(updatedOrder);
        }
      } else if (response?['error'] != null) {
        Get.snackbar(
          "Oups 🛑",
          response['error'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Erreur startPreparation: $e");
    }
  }

  Future<void> finishPreparation(int orderId) async {
    try {
      isfinishPrepLoading.value = true;
      final response = await _orderProvider.updateStatus(orderId, 'preparer');
      if (response != null && response['error'] == null) {
        ordersEnCours.removeWhere((o) => o.id == orderId);
        _checkAndTriggerAutoNext();
      }
    } catch (e) {
      debugPrint("Erreur finishPreparation: $e");
    } finally {
      isfinishPrepLoading.value = false;
    }
  }

  void addOrUpdateOrder(OrderRequest order) {
    final String status = order.status;
    removeOrderFromScreen(order.id!);
    if (status == 'en_attente') {
      ordersEnAttente.add(order);
      _sortOrders(ordersEnAttente);
    } else if (status == 'preparation') {
      ordersEnCours.add(order);
      _sortOrders(ordersEnCours);
    }
    _checkAndTriggerAutoNext();
  }

  void removeOrderFromScreen(int orderId) {
    ordersEnAttente.removeWhere((order) => order.id == orderId);
    ordersEnCours.removeWhere((order) => order.id == orderId);
  }

  void _sortOrders(RxList<dynamic> list) {
    list.sort((a, b) {
      if (a is OrderRequest && b is OrderRequest) {
        return (a.id ?? 0).compareTo(b.id ?? 0);
      }
      if (a is Map && b is Map) {
        return (a['id'] ?? 0).compareTo(b['id'] ?? 0);
      }
      return 0;
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}

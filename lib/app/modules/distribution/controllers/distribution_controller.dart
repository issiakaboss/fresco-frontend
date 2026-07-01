import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:fresco_shop/app/data/providers/order_provider.dart';
import 'package:get/get.dart';

class DistributionController extends GetxController {
  var orders = <OrderRequest>[].obs;
  var isLoading = false.obs;
  final OrderProvider _orderProvider = OrderProvider();
  var isVisibleCommandeInfos = true.obs;

  @override
  void onInit() {
    fetchReadyOrders();
    super.onInit();
  }

  void toogleCommandeInfos() {
    isVisibleCommandeInfos.value = !isVisibleCommandeInfos.value;
  }

  // Dans ton DistributionController :

  Future<void> fetchReadyOrders() async {
    try {
      isLoading.value = true;
      final response = await _orderProvider.getReadyForDistribution();
      if (response != null && response['data'] != null) {
        final List<dynamic> rawList = response['data'];
        orders.assignAll(
          rawList.map((json) => OrderRequest.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les commandes prêtes');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAndDistribute(int orderId) async {
    try {
      final response = await _orderProvider.distributeOrder(orderId);
      if (response != null && response['success'] == true) {
        orders.removeWhere((order) => order.id == orderId);
        Get.snackbar(
          'Succès 🍽️',
          'Commande livrée au client !',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la validation');
    }
  }

  void addOrUpdateOrder(OrderRequest order) {
    if (order.status != 'preparer') {
      orders.removeWhere((item) => item.id == order.id);
      return;
    }

    final int existingIndex = orders.indexWhere((item) => item.id == order.id);
    if (existingIndex != -1) {
      orders[existingIndex] = order;
    } else {
      orders.insert(0, order);
    }
  }

  void removeOrderFromScreen(int orderId) {
    orders.removeWhere((order) => order.id == orderId);
  }
}

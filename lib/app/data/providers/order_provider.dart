import 'package:fresco_shop/app/common/controllers/base_controller.dart';
import 'package:fresco_shop/app/data/providers/api_provider.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:fresco_shop/app/utils/enums/api_routes.dart';

class OrderProvider with BaseController {
  Future<dynamic> createOrder(OrderRequest orderRequest) async {
    try {
      final response = await ApiProvider.post(
        apiURL: ApiRoutes.orders.path,
        auth: true,
        data: orderRequest.toJson(),
      ).catchError(handleError);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getCashierOrders({
    String filter = 'today',
    int page = 1,
    String search = '', // <-- Ajout du paramètre search
  }) async {
    String url = '${ApiRoutes.cashierOrders.path}?filter=$filter&page=$page';

    if (search.trim().isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search.trim())}';
    }

    final response = await ApiProvider.get(
      apiURL: url,
      auth: true,
    ).catchError(handleError);

    return response;
  }

  Future<dynamic> updateOrder(int orderId, OrderRequest orderRequest) async {
    try {
      final response = await ApiProvider.put(
        apiURL: ApiRoutes.updateOrder.format({"order": orderId}),
        auth: true,
        data: orderRequest.toJson(),
      ).catchError(handleError);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final response = await ApiProvider.post(
      apiURL: ApiRoutes.cancelOrder.format({"order": orderId}),
      auth: true,
      data: {},
    ).catchError(handleError);
    return response != null;
  }

  // Récupérer les commandes pour la cuisine (Statuts : en_attente, preparation, preparer)
  Future<dynamic> getActiveOrders() async {
    try {
      final response = await ApiProvider.get(
        apiURL: ApiRoutes
            .orders
            .path, // Appelle la fonction index() de ton controlleur Laravel
        auth: true,
      ).catchError(handleError);
      return response;
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour le statut (Cuisine -> Préparation ou Prêt / Distribution -> Livré)
  Future<dynamic> updateStatus(int orderId, String status) async {
    try {
      final response = await ApiProvider.put(
        apiURL:
            "${ApiRoutes.orders.path}/$orderId/status", // Ajuste selon ta route Laravel de updateStatus
        auth: true,
        data: {'status': status},
      ).catchError(handleError);
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Récupérer la liste des commandes prêtes pour la distribution
  Future<dynamic> getReadyForDistribution() async {
    try {
      final response = await ApiProvider.get(
        apiURL: ApiRoutes.forDistribution.path,
        auth: true,
      ).catchError(handleError);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getDistributionHistory({
    String filter = 'today',
    int page = 1,
    String search = '',
  }) async {
    try {
      String url =
          '${ApiRoutes.distributionHistory.path}?filter=$filter&page=$page';
      if (search.trim().isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search.trim())}';
      }

      final response = await ApiProvider.get(
        apiURL: url,
        auth: true,
      ).catchError(handleError);

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Valider la distribution/livraison d'une commande spécifique
  Future<dynamic> distributeOrder(int orderId) async {
    try {
      final response = await ApiProvider.put(
        apiURL: ApiRoutes.distributeOrder.format({"order": orderId}),
        auth: true,
        data: {},
      ).catchError(handleError);

      return response;
    } catch (e) {
      return null;
    }
  }
}

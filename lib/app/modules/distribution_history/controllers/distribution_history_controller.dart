import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_request.dart';
import '../../../data/providers/order_provider.dart';

class DistributionHistoryController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final scrollController = ScrollController();

  final orders = <OrderRequest>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final totalSales = 0.obs;

  final currentFilter = 'today'.obs;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  Timer? _debounce;

  int _currentPage = 1;
  bool _hasMore = false;

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
    scrollController.dispose();
    super.onClose();
  }

  void searchOrders(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchHistory();
    });
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      _currentPage = 1;

      final response = await _orderProvider.getDistributionHistory(
        filter: currentFilter.value,
        page: _currentPage,
        search: searchController.text,
      );

      if (response != null && response['orders'] != null) {
        totalSales.value = response['total_sales'] ?? 0;

        final List<dynamic> rawOrders = response['orders'];
        orders.assignAll(
          rawOrders.map((json) => OrderRequest.fromJson(json)).toList(),
        );

        if (response['meta'] != null) {
          _hasMore = response['meta']['has_more'] ?? false;
        }
      }
    } catch (e) {
      debugPrint('Erreur récupération historique distribution : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore) return;

    try {
      isLoadingMore.value = true;
      _currentPage++;

      final response = await _orderProvider.getDistributionHistory(
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
      debugPrint('Erreur pagination historique distribution : $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void changeFilter(String filter) {
    if (currentFilter.value == filter) return;
    currentFilter.value = filter;
    searchController.clear();
    fetchHistory();
  }

  void clearSearch() {
    searchController.clear();
    fetchHistory();
  }
}

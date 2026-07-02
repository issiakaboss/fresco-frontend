// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/modules/caisse/controllers/caisse_controller.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Historique des Ventes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return Column(
          children: [
            // --- BOX RECETTES ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 10,
              ),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade800, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recettes du filtre actif",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${controller.totalSales.value} F CFA",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- BARRE DE RECHERCHE PROFESSIONNELLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                onChanged: (value) {
                  controller.searchOrders(value);
                },
                onTapOutside: (event) {
                  controller.searchFocusNode.unfocus();
                },
                decoration: InputDecoration(
                  hintText: "Rechercher un ticket ou un plat...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.amber[800],
                  ),
                  suffixIcon: controller.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchOrders("");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.amber.shade700,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // --- FILTRES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterButton("Aujourd'hui", "today"),
                  const SizedBox(width: 8),
                  _buildFilterButton("Récents", "recent"),
                  const SizedBox(width: 8),
                  _buildFilterButton("Tous", "all"),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- LISTE DES TICKETS ---
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.orders.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun ticket trouvé.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          controller.orders.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.orders.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final order = controller.orders[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.amber.withOpacity(0.1),
                              child: Icon(
                                Icons.restaurant_rounded,
                                color: Colors.amber[800],
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  "Ticket ${order.ticketNumber ?? '---'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${order.totalPrice} F",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${order.basePlat} • ${order.notes}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // RÈGLE LE DÉBORDEMENT VISIBLE SUR L'IMAGE WhatsApp
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Utilisation de Flexible ou Expanded pour éviter de pousser les boutons hors écran
                                      Flexible(
                                        child: Text(
                                          order.formattedDateTime,
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (order.isEnAttente) ...[
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit_rounded,
                                                color: const Color(0xFF1976D2),
                                                size: 18,
                                              ),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              onPressed: () {
                                                Get.find<CaisseController>()
                                                    .loadOrderForEdition(order);
                                                Get.back();
                                              },
                                            ),
                                            const SizedBox(width: 2),
                                          ],
                                          InkWell(
                                            onTap: order.isEnAttente
                                                ? () => controller.cancelOrder(
                                                    order,
                                                  )
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: order.statusColor
                                                    ?.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 5,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      color: order.statusColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    order.isEnAttente
                                                        ? "En attente (Annuler)"
                                                        : order.statusLabel ??
                                                              '',
                                                    style: TextStyle(
                                                      color: order.statusColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    return Obx(() {
      final isSelected = controller.currentFilter.value == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.changeFilter(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

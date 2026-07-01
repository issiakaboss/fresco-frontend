// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:get/get.dart';
import '../controllers/distribution_history_controller.dart';

class DistributionHistoryView extends GetView<DistributionHistoryController> {
  const DistributionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Historique Distribution',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildSummaryCard(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(child: _buildOrderList()),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total livré',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => Text(
                  '${controller.totalSales.value} F CFA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(controller.orders.length.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        onTapOutside: (event) => controller.searchFocusNode.unfocus(),
        onChanged: controller.searchOrders,
        decoration: InputDecoration(
          hintText: 'Rechercher ticket, plat ou note...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.amber),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: controller.clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.amber.shade700),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Aujourd\'hui', 'today'),
          const SizedBox(width: 8),
          _buildFilterChip('Récents', 'recent'),
          const SizedBox(width: 8),
          _buildFilterChip('Tous', 'all'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool selected = controller.currentFilter.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.amber[800] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.amber[800]! : Colors.grey.shade200,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[800],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.orders.isEmpty) {
      return const Center(
        child: Text(
          'Aucun historique trouvé.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount:
          controller.orders.length + (controller.isLoadingMore.value ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == controller.orders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final order = controller.orders[index];
        return _buildHistoryTile(context, order);
      },
    );
  }

  Widget _buildHistoryTile(BuildContext context, OrderRequest order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // C'est ici qu'on déclenche l'affichage des détails
          onTap: () => _showOrderDetailsBottomSheet(context, order),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // --- BLOC DE GAUCHE : IDENTIFIANT ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.formattedDateTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.ticketNumber ?? order.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // --- BLOC CENTRAL : APPARENCE SIMPLIFIÉE ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.basePlat == 'personnalise'
                            ? 'Plat Sur Mesure 🎯'
                            : 'Formule Standard 🍽️',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cliquez pour voir les détails',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BLOC DE DROITE : PRIX & STATUT ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.totalPrice} F',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EC4B6).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Color(0xFF2EC4B6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.statusLabel ?? 'Livré',
                            style: const TextStyle(
                              color: Color(0xFF2EC4B6),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, OrderRequest order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // En-tête du Ticket
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails de la commande',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Distribué le ${order.formattedDateTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${order.ticketNumber ?? order.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),

              // Section Composition de Base
              const Text(
                'Composition de base',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[900]?.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        order.basePlat == 'personnalise'
                            ? 'Plat Sur Mesure 🎯'
                            : '${order.basePlat} 🍽️',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _buildDetailRow('Attiéké', '${order.attiekePrice} F CFA'),
              _buildDetailRow(
                'Poisson (${order.fishCount}p)',
                '${order.fishPrice} F CFA',
              ),

              // Section Suppléments (Affichée uniquement s'il y en a)
              if (_hasExtras(order)) ...[
                const Divider(height: 24, thickness: 0.5),
                const Text(
                  'Suppléments ajoutés',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (order.extraOeufs > 0)
                  _buildDetailRow(
                    'Œuf(s) (x${order.extraOeufs})',
                    '${order.extraOeufs * 150} F CFA',
                  ),
                if (order.extraAllocoPrice > 0)
                  _buildDetailRow('Alloco', '${order.extraAllocoPrice} F CFA'),
                if (order.extraTomatePrice > 0)
                  _buildDetailRow('Tomate', '${order.extraTomatePrice} F CFA'),
                if (order.extraMayonnaisePrice > 0)
                  _buildDetailRow(
                    'Mayonnaise',
                    '${order.extraMayonnaisePrice} F CFA',
                  ),
                if (order.extraBissapPrice > 0)
                  _buildDetailRow('Bissap', '${order.extraBissapPrice} F CFA'),
                if (order.extraEau > 0)
                  _buildDetailRow(
                    'Eau (x${order.extraEau})',
                    '${order.extraEau * 25} F CFA',
                  ),
              ],

              // Section Note (Si renseignée)
              if (order.notes.isNotEmpty) ...[
                const Divider(height: 24, thickness: 0.5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 32, thickness: 1),

              // Section Montant Total de Fin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Montant Total Encaissé',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  Text(
                    '${order.totalPrice} F CFA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Widget d'aide pour aligner proprement une clé et sa valeur (ex: Attiéké .... 200F)
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF495057),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212529),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasExtras(OrderRequest order) {
    return order.extraOeufs > 0 ||
        order.extraAllocoPrice > 0 ||
        order.extraTomatePrice > 0 ||
        order.extraMayonnaisePrice > 0 ||
        order.extraBissapPrice > 0 ||
        order.extraEau > 0;
  }
}

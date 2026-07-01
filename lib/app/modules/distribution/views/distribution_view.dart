// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:fresco_shop/app/routes/app_pages.dart';
import 'package:fresco_shop/app/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import '../controllers/distribution_controller.dart';

class DistributionView extends GetView<DistributionController> {
  const DistributionView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 720;
    final double horizontalPadding = isTablet ? 24 : 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Espace Distribution',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.amber[800],
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: controller.fetchReadyOrders,
                    tooltip: 'Rafraîchir',
                  ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 26,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 46),
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Get.toNamed(Routes.DISTRIBUTION_HISTORY);
                  break;
                case 'logout':
                  DialogHelper.showLogoutConfirmation(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'history',
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      color: Colors.grey[800],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Historique des distributions',
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'logout',
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun plat en attente de livraison',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            12,
          ),
          child: Column(
            children: [
              _buildSummaryHeader(context, isTablet),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return _buildOrderCard(order, isTablet);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, bool isTablet) {
    final pendingCount = controller.orders.length;
    return GestureDetector(
      onDoubleTap: () => controller.toogleCommandeInfos(),
      child: Visibility(
        visible: controller.isVisibleCommandeInfos.value,
        replacement: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.only(left: 10),
                child: Text(
                  '$pendingCount commande${pendingCount > 1 ? 's' : ''} prête${pendingCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Commandes prêtes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF343A40),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pendingCount commande${pendingCount > 1 ? 's' : ''} en attente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTablet)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Tablette',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Faites glisser vers le bas ou appuyez sur le bouton de rafraîchissement pour mettre à jour la liste.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderRequest order, bool isTablet) {
    final Color? statusColor =
        order.statusColor?.withOpacity(1.0) ??
        (order.isEnAttente ? Colors.amber[800] : Colors.green[700]);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.06),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        collapsedBackgroundColor: const Color(0xFFF8F9FB),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TICKET ${order.ticketNumber ?? order.id ?? '---'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2A37),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.basePlat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2A37),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.formattedDateTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(order, statusColor ?? Colors.grey),
                const SizedBox(height: 8),
                _buildServiceBadge(order.serviceType),
              ],
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow('Attiéké', '${order.attiekePrice} F'),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Poisson',
            '${order.fishCount} pièce(s) • ${order.fishPrice} F',
          ),
          if (_hasExtras(order)) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: _buildExtrasChips(order)),
          ],
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note_alt_rounded,
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
              ),
              Text(
                '${order.totalPrice} F',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212529),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => controller.verifyAndDistribute(order.id ?? 0),
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text(
                'Marquer comme livré',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderRequest order, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        order.statusLabel ?? _formatStatusLabel(order.status),
        style: TextStyle(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildServiceBadge(String serviceType) {
    final bool isDelivery = serviceType.toLowerCase() == 'livraison';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDelivery
            ? Colors.blue.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivery
                ? Icons.delivery_dining_rounded
                : Icons.storefront_rounded,
            size: 14,
            color: isDelivery ? Colors.blue : Colors.green[700],
          ),
          const SizedBox(width: 6),
          Text(
            serviceType.capitalizeFirst ?? serviceType,
            style: TextStyle(
              color: isDelivery ? Colors.blue[800] : Colors.green[800],
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF212529),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatBasePlat(String basePlat) {
    if (basePlat == 'personnalise') {
      return 'Personnalisé';
    }
    return basePlat.replaceAll('_', ' ').capitalizeFirst ?? basePlat;
  }

  String _formatStatusLabel(String status) {
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'annule':
        return 'Annulé';
      case 'livre':
        return 'Livré';
      default:
        return status.capitalizeFirst ?? status;
    }
  }

  bool _hasExtras(OrderRequest order) {
    return order.extraOeufs > 0 ||
        order.extraAllocoPrice > 0 ||
        order.extraTomatePrice > 0 ||
        order.extraMayonnaisePrice > 0 ||
        order.extraBissapPrice > 0 ||
        order.extraEau > 0;
  }

  List<Widget> _buildExtrasChips(OrderRequest order) {
    final List<Widget> chips = [];

    void addChip(String label, Color color) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2), width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    if (order.extraOeufs > 0) {
      addChip('+${order.extraOeufs} œuf(s)', Colors.orange[800]!);
    }
    if (order.extraAllocoPrice > 0) {
      addChip('Alloco ${order.extraAllocoPrice} F', Colors.brown[700]!);
    }
    if (order.extraTomatePrice > 0) {
      addChip('Tomate ${order.extraTomatePrice} F', Colors.red[700]!);
    }
    if (order.extraMayonnaisePrice > 0) {
      addChip(
        'Mayonnaise ${order.extraMayonnaisePrice} F',
        Colors.blueGrey[600]!,
      );
    }
    if (order.extraBissapPrice > 0) {
      addChip('Bissap ${order.extraBissapPrice} F', Colors.purple[700]!);
    }
    if (order.extraEau > 0) {
      addChip('${order.extraEau} eau(s)', Colors.blue[700]!);
    }

    return chips;
  }
}

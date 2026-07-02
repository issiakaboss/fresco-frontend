// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/modules/cuisine/views/kds_ticket_card.dart';
import 'package:fresco_shop/app/modules/cuisine/views/kds_ticket_card_compact.dart';
import 'package:fresco_shop/app/routes/app_pages.dart';
import 'package:fresco_shop/app/utils/components/notification_toggle_item.dart';
import 'package:fresco_shop/app/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import '../controllers/cuisine_controller.dart';

class CuisineView extends GetView<CuisineController> {
  const CuisineView({super.key});

  @override
  Widget build(BuildContext context) {
    // Thème sombre de type "KDS Pro" pour reposer les yeux des cuisiniers
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF12141C),
        cardColor: const Color(0xFF1E2230),
        dividerColor: Colors.white10,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E2230),
          elevation: 0,
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SERVEUR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Fresco Garba',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Obx(() {
              return controller.isLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => controller.fetchCuisineOrders(),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                      ),
                    );
            }),
            SizedBox(width: 8.0),
            Obx(() {
              final count =
                  controller.ordersEnAttente.length +
                  controller.ordersEnCours.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: count > 5
                      ? Colors.redAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: count > 5 ? Colors.redAccent : Colors.white10,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: count > 5
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$count COMDS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: count > 5 ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              // Style moderne pour le conteneur du menu
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFF12141C),
              elevation: 4,
              offset: const Offset(
                0,
                40,
              ), // Positionne le menu légèrement plus bas que l'icône
              onSelected: (value) {
                switch (value) {
                  case 'history':
                    // Get.toNamed(Routes.CUISIN_HISTORY);
                    break;
                  case 'auto_next':
                    controller.toggleAutoNext();
                    break;
                  case 'logout':
                    DialogHelper.showLogoutConfirmation(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'history',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Historique des préparations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'auto_next',
                  child: Obx(() {
                    final bool isAuto = controller.isAutoNextEnabled.value;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAuto ? Icons.bolt : Icons.front_hand,
                            color: isAuto ? Colors.blueAccent : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAuto ? "Auto-Next : ACTIF" : "Auto-Next : OFF",
                            style: TextStyle(
                              color: isAuto ? Colors.white : Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const PopupMenuItem<String>(
                  enabled: false,
                  child: NotificationToggleItem(),
                ),
                const PopupMenuDivider(
                  height: 1,
                ), // Ligne de séparation élégante
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors
                              .redAccent, // Distingue visuellement l'action destructive
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
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Obx(() {
          // Si absolument rien n'est à servir ou en attente
          if (controller.ordersEnCours.isEmpty &&
              controller.ordersEnAttente.isEmpty) {
            return _buildEmptyState();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Si la largeur est trop petite (ex: smartphone vertical), on empile verticalement
              final bool isCompact = constraints.maxWidth < 750;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ZONE 1 : EN COURS (Prend le haut de l'écran)
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF131622),
                        child: controller.ordersEnCours.isEmpty
                            ? _buildNoActiveOrderState()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildZoneHeader("COMMANDE EN COURS"),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Obx(() {
                                      if (controller
                                          .isfinishPrepLoading
                                          .value) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: CircularProgressIndicator(
                                                color: Colors.white70,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return KdsTicketCard(
                                        order: controller.ordersEnCours.first,
                                        isFocused: false,
                                        onAction: () =>
                                            controller.finishPreparation(
                                              controller
                                                  .ordersEnCours
                                                  .first
                                                  .id!,
                                            ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    Container(height: 2, color: Colors.white10),

                    // ZONE 2 : FILE D'ATTENTE (Prend le bas de l'écran en horizontal)
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: const Color(0xFF1E2230),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQueueHeader(),
                            const SizedBox(height: 12),
                            Expanded(
                              child: controller.ordersEnAttente.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "Aucune commande en attente",
                                        style: TextStyle(color: Colors.white30),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis
                                          .horizontal, // File d'attente défilable de gauche à droite
                                      itemCount:
                                          controller.ordersEnAttente.length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            controller.ordersEnAttente[index];
                                        return Container(
                                          width:
                                              280, // Largeur fixe pour chaque petit ticket en bas
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: InkWell(
                                            onTap: () => controller
                                                .startPreparation(order.id!),
                                            child: KdsTicketCardCompact(
                                              order: order,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // ====================================================================
              // DESIGN ORIGINAL POUR GRAND ÉCRAN (TABLETTE / PAYSAGE) - OK PAS DE BUG
              // ====================================================================
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFF131622),
                      child: controller.ordersEnCours.isEmpty
                          ? _buildNoActiveOrderState()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildZoneHeader(
                                  "COMMANDE EN COURS DE PRÉPARATION",
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: Obx(() {
                                    if (controller.isfinishPrepLoading.value) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.0,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(
                                              color: Colors.white70,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return KdsTicketCard(
                                      order: controller.ordersEnCours.first,
                                      isFocused: true,
                                      onAction: () =>
                                          controller.finishPreparation(
                                            controller.ordersEnCours.first.id!,
                                          ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Container(width: 2, color: Colors.white10),
                  Container(
                    width: 360, // Légèrement réduit pour sécurité
                    color: const Color(0xFF1E2230),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQueueHeader(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: controller.ordersEnAttente.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Aucune commande\nen attente",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white30),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.ordersEnAttente.length,
                                  itemBuilder: (context, index) {
                                    final order =
                                        controller.ordersEnAttente[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: InkWell(
                                        onTap: () => controller
                                            .startPreparation(order.id!),
                                        child: Opacity(
                                          opacity: 0.85,
                                          child: KdsTicketCardCompact(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  // Petits helpers pour alléger le code au-dessus :
  Widget _buildZoneHeader(String title) {
    return Row(
      children: [
        const Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.amber,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "À SERVIR ENSUITE",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Obx(
            () => Text(
              "${Get.find<CuisineController>().ordersEnAttente.length}",
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_rounded, size: 90, color: Colors.grey[800]),
          const SizedBox(height: 20),
          const Text(
            "Cuisine en sommeil",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Dès qu'un client passe à la caisse, son bon s'affichera ici.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 15),
          ),
        ],
      ),
    );
  }
}

Widget _buildNoActiveOrderState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.touch_app_rounded, size: 64, color: Colors.grey.shade700),
        const SizedBox(height: 16),
        const Text(
          "Aucune commande sélectionnée",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Touchez un ticket dans la file d'attente à droite\npour commencer à le dresser.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    ),
  );
}

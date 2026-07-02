// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/core/services/printer_service.dart';
import 'package:fresco_shop/app/modules/caisse/views/printer_setting_view.dart';
import 'package:fresco_shop/app/routes/app_pages.dart';
import 'package:fresco_shop/app/utils/constants/food_icons.dart';
import 'package:fresco_shop/app/utils/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import '../controllers/caisse_controller.dart';

class CaisseView extends GetView<CaisseController> {
  const CaisseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        248,
        249,
        250,
      ), // Fond soft gris-blanc moderne
      appBar: AppBar(
        title: const Text(
          'Fresco Caisse',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.resetForm(),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            // Style moderne pour le conteneur du menu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 4,
            offset: const Offset(
              0,
              40,
            ), // Positionne le menu légèrement plus bas que l'icône
            onSelected: (value) {
              switch (value) {
                case 'history':
                  Get.toNamed(Routes.HISTORY);
                  break;
                case 'printer':
                  Get.to(() => const PrinterSettingView());
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
                        color: Colors.black87,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Historique des ventes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'printer',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.print_rounded,
                        color: Colors.black87,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Configuration Imprimante',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(height: 1), // Ligne de séparation élégante
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
        final order = controller.orderRx.value;
        final selectedPrinter = PrinterService.to.selectedPrinter.value;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- INSÈRE CE BLOC JUSTE AU-DESSUS DE "1. Plats de Base" ---
                    _buildSectionHeader("Type de Service"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceTypeButton(
                            type: 'sur_place',
                            label: 'Sur Place',
                            icon: Icons.restaurant_rounded,
                            selectedType: order.serviceType,
                            activeColor: const Color(0xFF009688),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildServiceTypeButton(
                            type: 'emporter',
                            label: 'À Emporter',
                            icon: Icons.local_mall_rounded,
                            selectedType: order.serviceType,
                            activeColor: const Color(0xFFFF6E40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- SECTION 1 : PLATS DE BASE ---
                    _buildSectionHeader("1. Plats de Base"),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                      children: [
                        _buildBasePlatCard(
                          'plat_500',
                          'Plat 500 F',
                          'Attiéké 200f • 1 Poisson (300f)',
                          order.basePlat,
                        ),
                        _buildBasePlatCard(
                          'plat_600',
                          'Plat 600 F',
                          'Attiéké 300f • 1 Poisson (300f)',
                          order.basePlat,
                        ),
                        _buildBasePlatCard(
                          'plat_800',
                          'Plat 800 F',
                          'Attiéké 200f • 2 Poissons (600f)',
                          order.basePlat,
                        ),
                        _buildBasePlatCard(
                          'plat_1000',
                          'Plat 1000 F',
                          'Attiéké 400f • 2 Poissons (600f)',
                          order.basePlat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCustomPlatRowCard(
                      'personnalise',
                      'Sur Mesure 🎯',
                      'Composition libre de l\'Attiéké et du poisson',
                      order.basePlat,
                    ),
                    const SizedBox(height: 28),
                    // --- SECTION 2 : SUPPLÉMENTS ---
                    _buildSectionHeader("2. Éléments Supplémentaires"),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        child: Column(
                          children: [
                            _buildCounterRow(
                              icon: FoodIcons.oeuf,
                              title: "Œufs",
                              subtitle: "150 F",
                              count: order.extraOeufs,
                              onDecrement: () => controller.updateOeufs(-1),
                              onIncrement: () => controller.updateOeufs(1),
                              color: Colors.amber,
                            ),
                            const Divider(height: 1),
                            _buildCounterRow(
                              icon: FoodIcons.eau,
                              title: "Sachet d'eau",
                              subtitle: "25 F",
                              count: order.extraEau,
                              onDecrement: () => controller.updateEau(-1),
                              onIncrement: () => controller.updateEau(1),
                              color: Colors.blue,
                            ),
                            const Divider(height: 1),
                            _buildPriceRow(
                              context: context,
                              label: "Alloco",
                              icon: FoodIcons.alloco,
                              color: Colors.orange,
                              currentPrice: order.extraAllocoPrice,
                              onPriceChanged: (newPrice) =>
                                  controller.setAllocoPrice(newPrice),
                            ),
                            const Divider(height: 1),
                            _buildPriceRow(
                              context: context,
                              label: "Tomate",
                              icon: FoodIcons.tomate,
                              color: Colors.redAccent,
                              currentPrice: order.extraTomatePrice,
                              onPriceChanged: (newPrice) =>
                                  controller.setTomatePrice(newPrice),
                            ),
                            const Divider(height: 1),
                            _buildPriceRow(
                              context: context,
                              label: "Mayonnaise",
                              icon: FoodIcons.mayonnaise,
                              color: Colors.blueGrey,
                              currentPrice: order.extraMayonnaisePrice,
                              onPriceChanged: (newPrice) =>
                                  controller.setMayonnaisePrice(newPrice),
                            ),
                            const Divider(height: 1),
                            _buildPriceRow(
                              context: context,
                              label: "Bissap",
                              icon: FoodIcons.bissap,
                              color: const Color.fromARGB(255, 104, 9, 2),
                              currentPrice: order.extraBissapPrice,
                              onPriceChanged: (newPrice) =>
                                  controller.setBissapPrice(newPrice),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- SECTION 3 : NOTES DYNAMIQUES ---
                    _buildSectionHeader("3. Remarques & Spécifications"),
                    const SizedBox(height: 12),
                    Obx(() {
                      // On écoute orderRx pour forcer le rafraîchissement des puces graphiques
                      final _ = controller.orderRx.value.notes;

                      // --- Configuration Notes Prédéfinies ---
                      final List<String> _predefinedNotes = [
                        "${FoodIcons.piment} Piment mis à part",
                        "${FoodIcons.oignon} Sans oignon",
                        "${FoodIcons.piment} Sans piment",
                        "${FoodIcons.poisson} Pas tête Poisson",
                        "${FoodIcons.piment} Pas d'huile",
                        "${FoodIcons.poisson} Tête Poisson",
                        "${FoodIcons.bissap} beaucoup d'huile",
                      ];

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _predefinedNotes.map((note) {
                          final isSelected = controller.isNoteSelected(note);
                          return FilterChip(
                            label: Text(note),
                            selected: isSelected,
                            labelStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.amber[900],
                            ),
                            selectedColor: Colors.amber[800],
                            checkmarkColor: Colors.white,
                            backgroundColor: Colors.amber.withOpacity(0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.amber.withOpacity(0.3),
                            ),
                            onSelected: (_) => controller.toggleNote(note),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.notesController,
                      focusNode: controller.notesFocusNode,
                      onChanged: (val) => controller.orderRx.refresh(),
                      onTapOutside: (event) {
                        controller.notesFocusNode.unfocus();
                      },
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Saisir une autre note spécifique ici...",
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.amber.shade800,
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            // --- DECORATIVE PAYMENT BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Net Encaissé",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${selectedPrinter.split(' ').first} active",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${order.totalPrice} F CFA",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.submitOrder(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Valider & Imprimer",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildServiceTypeButton({
    required String type,
    required String label,
    required IconData icon,
    required String selectedType,
    required Color activeColor,
  }) {
    final isSelected = type == selectedType;
    return InkWell(
      onTap: () => controller.setServiceType(type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor.withAlpha(50)
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasePlatCard(
    String type,
    String title,
    String subtitle,
    String selectedType,
  ) {
    final isSelected = type == selectedType;
    return InkWell(
      onTap: () => controller.selectBasePlat(type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.amber.shade900 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlatRowCard(
    String type,
    String title,
    String subtitle,
    String selectedType,
  ) {
    final isSelected = type == selectedType;

    return InkWell(
      onTap: () {
        if (isSelected) {
          controller
              .showCustomizationBottomSheet(); // Rouvre le panneau si déjà sélectionné
        } else {
          controller.selectBasePlat(type);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Hauteur réduite et bien dosée
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.amber.shade900 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Texte à gauche
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Flèche ou indicateur à droite pour inviter à configurer
            Icon(
              Icons.tune_rounded,
              color: isSelected ? Colors.white : Colors.amber[800],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String icon,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(icon, style: TextStyle(color: color, fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: count > 0 ? Colors.red[400] : Colors.grey[300],
                ),
                onPressed: count > 0 ? onDecrement : null,
              ),
              Text(
                "$count",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.green[400],
                ),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required int currentPrice,
    required String icon,
    required Color color,
    required String label,
    required Function(int) onPriceChanged,
  }) {
    return InkWell(
      onTap: () => _showAllocoPriceBottomSheet(
        context,
        currentPrice,
        label,
        icon,
        onPriceChanged,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(icon, style: TextStyle(color: color, fontSize: 20)),
            ),

            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentPrice > 0 ? "Montant ajouté" : "Aucun supplément",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Affiche le prix actuel de l'alloco sous forme de badge cliquable
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: currentPrice > 0 ? Colors.orange[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: BoxBorder.all(
                  color: currentPrice > 0
                      ? Colors.orange.shade200
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "$currentPrice F",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: currentPrice > 0
                          ? Colors.orange[800]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: currentPrice > 0
                        ? Colors.orange[700]
                        : Colors.grey[500],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomSheet pour choisir ou saisir le montant de l'alloco (ou autres suppléments)
  void _showAllocoPriceBottomSheet(
    BuildContext context,
    int currentPrice,
    String label,
    String icon,
    Function(int) onPriceChanged,
  ) {
    final textController = TextEditingController(
      text: currentPrice > 0 ? currentPrice.toString() : "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permet au BottomSheet de monter quand le clavier s'ouvre
      backgroundColor: Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              // S'adapte automatiquement à la hauteur du clavier virtuel
              padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ), // Idéal pour garder un beau visuel sur tablette

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PETITE BARRE DE SÉPARATION (INDICATEUR VISUEL) ---
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // --- EN-TÊTE ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "Montant $label",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- INSTRUCTION ---
                    Text(
                      "Choisissez un montant rapide ou saisissez-le :",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- GRILLE DES PRIX RAPIDES ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                      children: [0, 50, 100, 150, 175, 200, 300, 400, 500].map((
                        amount,
                      ) {
                        final isSelected = currentPrice == amount;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              currentPrice = amount;
                              textController.text = amount > 0
                                  ? amount.toString()
                                  : "";
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSelected) ...[
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  amount == 0 ? "Aucun" : "$amount F",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.orange[800]
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // --- CHAMP DE SAISIE LIBRE ---
                    TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setModalState(() {
                          currentPrice =
                              int.tryParse(value) ??
                              -1; // Désélectionne les boutons grisés
                        });
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: "Autre montant (F CFA)",
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.money_rounded,
                          color: Colors.orange,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- BOUTONS D'ACTION PIED DE PAGE ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              onPriceChanged(0);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Effacer",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              int enteredPrice =
                                  int.tryParse(textController.text) ?? 0;
                              onPriceChanged(enteredPrice);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Valider",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';
import 'package:fresco_shop/app/utils/constants/food_icons.dart';

/// Composant interne : Carte de Ticket de type KDS Professionnel
class KdsTicketCard extends StatefulWidget {
  final OrderRequest order;
  final VoidCallback onAction;
  final bool isFocused; // Ajouté pour booster la visibilité au centre

  const KdsTicketCard({
    required this.order,
    required this.onAction,
    this.isFocused = false,
  });

  @override
  State<KdsTicketCard> createState() => KdsTicketCardState();
}

class KdsTicketCardState extends State<KdsTicketCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    final created = widget.order.createdAt ?? DateTime.now();
    _elapsed = DateTime.now().difference(created);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(created);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getTimerColor() {
    if (_elapsed.inMinutes >= 15) return Colors.redAccent;
    if (_elapsed.inMinutes >= 8) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSurPlace = widget.order.serviceType == 'sur_place';
    final Color timerColor = _getTimerColor();
    final bool isFocus = widget.isFocused;

    String btnText = "MARQUER COMME PRÊT";
    Color btnColor = const Color(0xFF4CAF50);
    IconData btnIcon = Icons.check_circle_outline_rounded;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_elapsed.inMinutes.remainder(60));
    final seconds = twoDigits(_elapsed.inSeconds.remainder(60));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: btnColor.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau supérieur géant si Focus
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isFocus ? 18 : 14,
            ),
            decoration: BoxDecoration(
              color: isSurPlace
                  ? const Color(0xFF00695C)
                  : const Color(0xFFD84315),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TICKET ${widget.order.ticketNumber ?? '#000'}",
                  style: TextStyle(
                    fontSize: isFocus ? 26 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isFocus ? 14 : 10,
                    vertical: isFocus ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    isSurPlace ? "ℹ️ SUR PLACE" : "🛍️ À EMPORTER",
                    style: TextStyle(
                      fontSize: isFocus ? 14 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ligne Chrono
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      size: isFocus ? 22 : 18,
                      color: timerColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$minutes:$seconds",
                      style: TextStyle(
                        fontSize: isFocus ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(widget.order.statusLabel ?? 'Préparation'),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // Liste du contenu du plat
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              controller: ScrollController(),
              children: [
                // BASE DU PLAT (Affichage très lourd pour éviter les erreurs de dosage)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.basePlat
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: isFocus ? 28 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Attiéké: ${widget.order.attiekePrice}F",
                            style: TextStyle(
                              fontSize: isFocus ? 20 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Text(
                            "🐟 ${widget.order.fishCount} Poisson(s): ${widget.order.fishPrice}F",
                            style: TextStyle(
                              fontSize: isFocus ? 20 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "SUPPLÉMENTS",
                  style: TextStyle(
                    fontSize: isFocus ? 14 : 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),

                if (widget.order.extraOeufs == 0 &&
                    widget.order.extraAllocoPrice == 0 &&
                    widget.order.extraEau == 0)
                  Text(
                    "",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  )
                else ...[
                  if (widget.order.extraOeufs > 0)
                    _buildKdsRow(
                      "${FoodIcons.oeuf} Œuf",
                      "${widget.order.extraOeufs}",
                      isFocus,
                    ),
                  if (widget.order.extraEau > 0)
                    _buildKdsRow(
                      "${FoodIcons.eau} Eau en sachet",
                      "${widget.order.extraEau}",
                      isFocus,
                    ),
                  if (widget.order.extraAllocoPrice > 0)
                    _buildKdsRow(
                      "${FoodIcons.alloco} Alloco",
                      "${widget.order.extraAllocoPrice} F",
                      isFocus,
                    ),
                  if (widget.order.extraTomatePrice > 0)
                    _buildKdsRow(
                      "${FoodIcons.tomate} Tomate",
                      "${widget.order.extraTomatePrice} F",
                      isFocus,
                    ),
                  if (widget.order.extraMayonnaisePrice > 0)
                    _buildKdsRow(
                      "${FoodIcons.mayonnaise} Mayonnaise",
                      "${widget.order.extraMayonnaisePrice} F",
                      isFocus,
                    ),
                  if (widget.order.extraBissapPrice > 0)
                    _buildKdsRow(
                      "${FoodIcons.bissap} Bissap",
                      "${widget.order.extraBissapPrice} F",
                      isFocus,
                    ),
                ],

                // NOTES CAISSE
                if (widget.order.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 6),

                  // Conteneur d'alerte pour attirer l'attention du cuisinier
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isFocus ? 14 : 10),
                    decoration: BoxDecoration(
                      color: Colors.amber[900]!.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.amber[600]!.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête de la note
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_late_rounded,
                              size: isFocus ? 18 : 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "CONSIGNES SPÉCIALES :",
                              style: TextStyle(
                                fontSize: isFocus ? 13 : 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Découpage et affichage dynamique sous forme de tirets propres
                        ...widget.order.notes
                            .split(',')
                            .map(
                              (note) => note.trim(),
                            ) // Supprime les espaces inutiles au début/fin
                            .where(
                              (note) => note.isNotEmpty,
                            ) // Évite les lignes vides s'il y a des virgules en trop
                            .map((cleanNote) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Un tiret stylisé orange pour chaque instruction
                                    Text(
                                      "• ",
                                      style: TextStyle(
                                        color: Colors.amber[600],
                                        fontSize: isFocus ? 20 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        cleanNote,
                                        style: TextStyle(
                                          fontSize: isFocus ? 18 : 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight
                                              .w600, // Un peu plus gras pour détacher le texte du fond
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bouton d'action massif pour validation tactile facile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: isFocus ? 64 : 48,
              child: ElevatedButton.icon(
                onPressed: widget.onAction,
                icon: Icon(btnIcon, size: isFocus ? 28 : 24),
                label: Text(
                  btnText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isFocus ? 18 : 14,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKdsRow(String label, String value, bool isFocus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFocus ? 18 : 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isFocus ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.orangeAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

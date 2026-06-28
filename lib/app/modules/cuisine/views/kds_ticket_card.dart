// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fresco_shop/app/data/models/order_request.dart';

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
              padding: const EdgeInsets.all(20),
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
                      Text(
                        "🐟 ${widget.order.fishCount} POISSON(S)",
                        style: TextStyle(
                          fontSize: isFocus ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                // SECTION CRITIQUE : LE PIMENT
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: widget.order.pimentAPart
                        ? Colors.redAccent.withOpacity(0.15)
                        : Colors.greenAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: widget.order.pimentAPart
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        size: isFocus ? 22 : 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.order.pimentAPart
                              ? "⚠️ PIMENT À PART (NE PAS MÉLANGER !)"
                              : "🟢 PIMENT NORMAL DANS L'ATTIÉKÉ",
                          style: TextStyle(
                            fontSize: isFocus ? 18 : 10,
                            fontWeight: FontWeight.bold,
                            color: widget.order.pimentAPart
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                      ),
                    ],
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
                      "🥚 Œufs durs",
                      "x${widget.order.extraOeufs}",
                      isFocus,
                    ),
                  if (widget.order.extraAllocoPrice > 0)
                    _buildKdsRow(
                      "🍌 Alloco",
                      "${widget.order.extraAllocoPrice}",
                      isFocus,
                    ),
                  if (widget.order.extraEau > 0)
                    _buildKdsRow(
                      "💧 Eau en sachet",
                      "x${widget.order.extraEau}",
                      isFocus,
                    ),
                ],

                // NOTES CAISSE
                if (widget.order.notes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 10),
                  Text(
                    "NOTE CAISSE :",
                    style: TextStyle(
                      fontSize: isFocus ? 13 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.order.notes,
                    style: TextStyle(
                      fontSize: isFocus ? 18 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bouton d'action massif pour validation tactile facile
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: isFocus ? 64 : 54,
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

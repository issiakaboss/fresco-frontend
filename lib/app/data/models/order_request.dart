import 'package:flutter/material.dart';

class OrderRequest {
  int? id;
  String? ticketNumber;
  DateTime? createdAt;
  String basePlat;
  int attiekePrice;
  int fishCount;
  int fishPrice;
  int extraOeufs;
  int extraAllocoPrice;
  int extraEau;
  bool pimentAPart;
  String notes;
  String serviceType;
  final String status;
  final String? statusLabel;
  Color? statusColor;

  OrderRequest({
    this.id,
    this.ticketNumber,
    this.createdAt,
    this.basePlat = 'plat_500',
    this.attiekePrice = 200,
    this.fishCount = 1,
    this.fishPrice = 300,
    this.extraOeufs = 0,
    this.extraAllocoPrice = 0,
    this.extraEau = 0,
    this.pimentAPart = false,
    this.notes = '',
    this.serviceType = 'emporter',
    this.status = 'en_attente',
    this.statusLabel,
    this.statusColor,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      id: json['id'],
      ticketNumber: json['ticket_number']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      basePlat: json['base_plat'] ?? 'plat_500',
      attiekePrice: json['attieke_price'] ?? 0,
      fishCount: json['fish_count'] ?? 0,
      fishPrice: json['fish_price'] ?? 0,
      extraOeufs: json['extra_oeufs'] ?? 0,
      extraAllocoPrice: json['extra_alloco_price'] ?? 0,
      extraEau: json['extra_eau'] ?? 0,
      pimentAPart:
          json['piment_a_part'] == 1 ||
          json['piment_a_part'] ==
              true, // Gère le booléen ou le tinyInt 0/1 de MySQL
      notes: json['notes'] ?? '',
      serviceType: json['service_type'] ?? 'emporter',
      status: json['status'] ?? 'en_attente',
      statusLabel: json['status_label'],
      statusColor: Color(int.tryParse(json['status_color']) ?? 0),
    );
  }

  // Calcul dynamique du prix total du plat + suppléments
  int get totalPrice {
    int total = attiekePrice + fishPrice;
    total += extraOeufs * 150;
    total += extraAllocoPrice;
    total += extraEau * 25;
    return total;
  }

  // Convertir en JSON pour l'envoyer à notre store() de Laravel
  Map<String, dynamic> toJson() => {
    'base_plat': basePlat,
    'attieke_price': attiekePrice,
    'fish_count': fishCount,
    'fish_price': fishPrice,
    'extra_oeufs': extraOeufs,
    'extra_alloco_price': extraAllocoPrice,
    'extra_eau': extraEau,
    'piment_a_part': pimentAPart,
    'notes': notes,
    'total_price': totalPrice,
    'service_type': serviceType,
  };
  bool get isEnAttente => status == 'en_attente';
  bool get isAnnule => status == 'annule';

  String get formattedDateTime {
    if (createdAt == null) return "--:--";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(
      createdAt!.year,
      createdAt!.month,
      createdAt!.day,
    );

    final hour = createdAt!.hour.toString().padLeft(2, '0');
    final minute = createdAt!.minute.toString().padLeft(2, '0');

    if (orderDate == today) {
      return "$hour:$minute";
    } else {
      final day = createdAt!.day.toString().padLeft(2, '0');
      final month = createdAt!.month.toString().padLeft(2, '0');
      return "$day/$month à $hour:$minute";
    }
  }
}

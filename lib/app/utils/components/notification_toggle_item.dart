import 'package:flutter/material.dart';
import 'package:fresco_shop/app/utils/helpers/storage_helper.dart';
import 'package:get/get.dart';

class NotificationToggleItem extends StatelessWidget {
  const NotificationToggleItem({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation d'un RxBool local synchronisé avec ton StorageHelper pour l'UI
    final isSoundAlertEnabled = StorageHelper.getSoundAlertStatus().obs;

    return Obx(() {
      final bool isSound = isSoundAlertEnabled.value;
      return GestureDetector(
        onTap: () async {
          bool newValue = !isSound;
          await StorageHelper.saveSoundAlertStatus(newValue);
          isSoundAlertEnabled.value = newValue;
          // Optionnel : Déclencher un petit snackbar ou message de confirmation si tu veux
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: isSound ? Colors.greenAccent : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                isSound ? "Alertes Sonores : ON" : "Alertes Sonores : MUET",
                style: TextStyle(
                  color: isSound ? Colors.white : Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
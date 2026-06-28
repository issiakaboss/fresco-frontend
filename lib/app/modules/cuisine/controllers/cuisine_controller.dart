import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../data/models/order_request.dart'; // Ajuste le chemin selon ton projet
import '../../../data/providers/order_provider.dart';

class CuisineController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();

  // Listes réactives pour séparer les flux de travail
  final ordersEnAttente = <OrderRequest>[].obs;
  final RxList<dynamic> ordersEnCours = <dynamic>[].obs;

  final isLoading = false.obs;

  final stt.SpeechToText _speech = stt.SpeechToText();
  // États observables pour l'UI
  var isSpeechInitialized = false.obs;
  var isListening =
      false.obs; // Indique si l'utilisateur VEUT que le micro écoute
  var isNativeListening =
      false.obs; // Indique si le micro Android est réellement actif

  // Anti-rebond pour éviter de harceler le moteur Android
  bool _isSwitchingState = false;

  @override
  void onInit() {
    super.onInit();
    fetchCuisineOrders();
    _initVoiceCommands();
  }

  /// Active ou désactive manuellement l'écoute globale depuis l'UI
  void toggleVoiceControl() async {
    if (_isSwitchingState) return;
    _isSwitchingState = true;

    if (isListening.value) {
      // Désactivation demandée
      isListening.value = false;
      await _speech.stop();
      isNativeListening.value = false;
      Get.snackbar(
        "Mode Vocal",
        "Reconnaissance vocale désactivée",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } else {
      // Activation demandée
      isListening.value = true;
      if (!isSpeechInitialized.value) {
        await _initVoiceCommands();
      } else {
        _startListeningLoop();
      }
    }

    _isSwitchingState = false;
  }

  Future<void> _initVoiceCommands() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print("Statut Vocal Natif : $status");
          if (status == 'listening') {
            isNativeListening.value = true;
          } else if (status == 'notListening') {
            isNativeListening.value = false;
            // Ne relance la boucle QUE si l'interrupteur global est toujours sur ON
            if (isListening.value) {
              Future.delayed(const Duration(milliseconds: 400), () {
                _startListeningLoop();
              });
            }
          }
        },
        onError: (errorNotification) {
          print("Erreur Vocale : ${errorNotification.errorMsg}");
          // Si l'erreur est "busy", on attend un peu avant de retenter la relance
          if (errorNotification.errorMsg == 'error_busy') {
            isNativeListening.value = false;
          }
        },
      );
      isSpeechInitialized.value = available;
      if (available) {
        _startListeningLoop();
      }
    } catch (e) {
      print("Échec initialisation vocale : $e");
    }
  }

  void _startListeningLoop() async {
    // Sécurité : si l'utilisateur a coupé le switch entre-temps ou si Android écoute déjà
    if (!isListening.value || _speech.isListening) return;

    await _speech.listen(
      localeId: "en_US",
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(
        seconds: 4,
      ), // Pause courte pour intercepter plus vite les mots
      onResult: (result) {
        String words = result.recognizedWords.toLowerCase().trim();
        if (words.isEmpty) return;

        print("Mots captés : $words");

        if (words.contains('next') || words.contains('suivant')) {
          _triggerNextOrder();
        } else if (words.contains('ok') ||
            words.contains('prêt') ||
            words.contains('pret') ||
            words.contains('okay')) {
          _triggerFinishOrder();
        }
      },
    );
  }

  void _triggerNextOrder() {
    if (ordersEnAttente.isNotEmpty) {
      // Prend le premier élément de la file d'attente et lance la préparation
      final nextOrder = ordersEnAttente.first;
      startPreparation(nextOrder.id!);
      Get.snackbar(
        "Vocal",
        "Commande ${nextOrder.ticketNumber} activée !",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber,
        colorText: Colors.black,
      );
    }
  }

  void _triggerFinishOrder() {
    if (ordersEnCours.isNotEmpty) {
      final currentOrder = ordersEnCours.first;
      finishPreparation(currentOrder.id!);
      Get.snackbar(
        "Vocal",
        "Commande ${currentOrder.ticketNumber} prête !",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  /// 📥 Charger les commandes actives (En attente et En préparation)
  Future<void> fetchCuisineOrders() async {
    try {
      isLoading.value = true;
      final response = await _orderProvider.getActiveOrders();

      if (response != null && response['data'] != null) {
        final List<dynamic> rawOrders = response['data'];
        List<OrderRequest> allOrders = rawOrders
            .map((json) => OrderRequest.fromJson(json))
            .toList();
        ordersEnAttente.assignAll(
          allOrders.where((o) => o.status == 'en_attente').toList(),
        );
        ordersEnCours.assignAll(
          allOrders.where((o) => o.status == 'preparation').toList(),
        );
      }
    } catch (e) {
      debugPrint("Erreur chargement cuisine : $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ⚡ Passer une commande de "En attente" à "En préparation"
  Future<void> startPreparation(int orderId) async {
    try {
      final response = await _orderProvider.updateStatus(
        orderId,
        'preparation',
      );

      if (response != null && response['error'] == null) {
        fetchCuisineOrders(); // On rafraîchit
        // Get.snackbar(
        //   "Chef ! 🍳",
        //   "Préparation commencée pour le ticket ${response['order']['ticket_number']}",
        //   backgroundColor: Colors.orange,
        //   colorText: Colors.white,
        // );
      } else if (response?['error'] != null) {
        Get.snackbar(
          "Oups 🛑",
          response['error'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Erreur startPreparation: $e");
    }
  }

  Future<void> finishPreparation(int orderId) async {
    try {
      final response = await _orderProvider.updateStatus(orderId, 'preparer');

      if (response != null) {
        fetchCuisineOrders();
        Get.snackbar(
          "Plat Prêt ! 🍽️",
          "Le ticket ${response['order']['ticket_number']} est prêt pour la distribution.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Erreur finishPreparation: $e");
    }
  }

  void addOrUpdateOrder(OrderRequest order) {
    final String status = order.status;
    removeOrderFromScreen(order.id!);

    if (status == 'en_attente') {
      ordersEnAttente.add(order);
      _sortOrders(ordersEnAttente);
    } else if (status == 'preparation') {
      ordersEnCours.add(order);
      _sortOrders(ordersEnCours);
    }
  }

  void removeOrderFromScreen(int orderId) {
    ordersEnAttente.removeWhere((order) => order.id == orderId);
    ordersEnCours.removeWhere((order) => order.id == orderId);
  }

  void _sortOrders(RxList<dynamic> list) {
    list.sort((a, b) {
      if (a is OrderRequest && b is OrderRequest) {
        return (a.id ?? 0).compareTo(b.id ?? 0);
      }
      if (a is Map && b is Map) {
        return (a['id'] ?? 0).compareTo(b['id'] ?? 0);
      }
      return 0;
    });
  }

  @override
  void onClose() {
    isListening.value = false;
    _speech.stop();
    super.onClose();
  }
}

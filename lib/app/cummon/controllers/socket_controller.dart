// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fresco_shop/app/core/websocket/echo_service.dart';
import 'package:fresco_shop/app/cummon/controllers/user_controller.dart';
import 'package:fresco_shop/app/data/models/user.dart';
import 'package:fresco_shop/app/data/providers/auth_provider.dart';
import 'package:get/get.dart';
import 'package:laravel_echo_null/laravel_echo_null.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as pusher;

class SocketController extends GetxController with WidgetsBindingObserver {
  Echo<pusher.PusherClient, PusherChannel>? echo;
  final Set<String> _activeChannels = {};
  final AuthProvider authProvider = AuthProvider();
  User? get currentUser => UserController.to.user;
  final Set<int> _trackedClientRequestIds = {};
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    if (currentUser != null) {
      connectToSocket(user: currentUser!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      debugPrint("📱 [Tiim] Premier plan : Reconnexion instantanée");
      if (currentUser != null) {
        connectToSocket(user: currentUser!);
      }
    }
  }

  /// Déconnexion complète et sécurisée du Socket
  void disconnectSocket({bool isLogout = false}) {
    if (echo != null) {
      try {
        echo!.disconnect();
      } catch (e) {
        debugPrint("Erreur lors de la déconnexion du socket: $e");
      } finally {
        echo = null;
        _activeChannels.clear();
        if (isLogout) {
          _trackedClientRequestIds.clear();
        }
        debugPrint("🛑 [Tiim] Socket arrêté proprement.");
      }
    }
  }

  void _logoutUser() async {
    await UserController.to.performLogOut();
  }



  // --- CONNECT ET SYSTEME D'ÉCOUTE AMÉLIORÉ ---

  Future<void> connectToSocket({required User user}) async {
    if (echo != null) {
      debugPrint("📡 Socket déjà initialisé pour Tiim.");
      // initialSocketSubscription(user: user);
      return;
    }

    try {
      debugPrint("🔌 Connexion à l'instance Echo de Tiim...");
      echo = await EchoService.initEcho();

      echo!.connector.onConnect((data) {
        debugPrint("✅ Socket Connecté avec succès");
        initialSocketSubscription(user: user);
      });

      echo!.connector.onDisconnect((data) {
        debugPrint("❌ Socket Déconnecté de Tiim");
      });
    } catch (e) {
      debugPrint("Socket error: $e");
      echo = null;
    }
  }

  Future<void> initialSocketSubscription({required User user}) async {
    if (user.id != null) {
      if (echo != null && _activeChannels.isNotEmpty) {
        debugPrint(
            "🔄 [Tiim] Nettoyage des anciens canaux Pusher avant réinscription...");
        for (String channelName in _activeChannels) {
          try {
            echo!.leave(channelName);
          } catch (e) {
            debugPrint("Erreur lors de l'abandon du canal $channelName: $e");
          }
        }
        _activeChannels.clear();
      }
     

      // 2. Canaux selon les rôles spécifiques de Tiim
      if (user.isAdmin) {
     
      } else {
        if (user.isCaisse) {
   
        }
      }
  
    }
  }

  void ecouter({
    required String channel,
    required String event,
    required Function action,
  }) {
    if (echo == null) return;

    // Protection anti-doublons d'écoutes locales
    String subscriptionKey = "$channel@$event";
    if (_activeChannels.contains(subscriptionKey)) {
      debugPrint(
          "⚠️ Déjà inscrit à l'écoute de : $subscriptionKey (Ignoré pour éviter les doublons)");
      return;
    }

    EchoService.listen(
      echo: echo!,
      channel: channel,
      event: event,
      action: action,
    );

    _activeChannels.add(subscriptionKey);
    debugPrint("📡 Nouvelle écoute enregistrée avec succès : $subscriptionKey");
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnectSocket(isLogout: true);
    super.onClose();
  }
}

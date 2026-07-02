import 'package:fresco_shop/app/config/env.dart';
import 'package:fresco_shop/app/data/models/token.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as pusher;
import 'package:laravel_echo_null/laravel_echo_null.dart';

class EchoService {
  static Future<Echo<pusher.PusherClient, PusherChannel>> initEcho() async {
    String? token = Token.getToken();
    return Echo.pusher(
      Env.appKey,
      authEndPoint: '${Env.apiUrl}broadcasting/auth',
      authHeaders: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      host: Env.host,
      wsPort: Env.wsPort,
      wssPort: Env.wssPort,
      encrypted: Env.encrypted,
      activityTimeout: 30000, 
      pongTimeout: 15000,
      enableLogging: true,
      autoConnect: true,
      nameSpace: null,
    );
  }

  // Subscribe to Channel & Event
  static void listen({
    required Echo<pusher.PusherClient, PusherChannel> echo,
    required String channel,
    required String event,
    required Function action,
  }) {
    Channel? myChannel;
    if (!echo.connector.channels.containsKey(channel)) {
      myChannel = echo.channel(channel);
      myChannel.listen('.$event', (data) {
        action(data);
      });
    }
  }
}

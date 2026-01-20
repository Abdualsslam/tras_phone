import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as developer;

/// ═══════════════════════════════════════════════════════════════
/// 🔌 WebSocket Service for Flutter App
/// ═══════════════════════════════════════════════════════════════
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final Map<String, Set<Function>> _listeners = {};

  /// Connect to WebSocket server
  void connect(String token, String baseUrl) {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final wsUrl = baseUrl.replaceAll('/api/v1', '');

    _socket = IO.io(
      '$wsUrl/support',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!.onConnect((_) {
      developer.log('WebSocket connected', name: 'SocketService');
    });

    _socket!.onDisconnect((_) {
      developer.log('WebSocket disconnected', name: 'SocketService');
    });

    _socket!.onError((error) {
      developer.log('WebSocket error: $error', name: 'SocketService');
    });

    _setupEventListeners();
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
  }

  /// Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Ticket events
    _socket!.on('ticket:created', (data) => _emit('ticket:created', data));
    _socket!.on('ticket:updated', (data) => _emit('ticket:updated', data));
    _socket!.on('ticket:message', (data) => _emit('ticket:message', data));
    _socket!.on('ticket:assigned', (data) => _emit('ticket:assigned', data));

    // Chat events
    _socket!.on('chat:message', (data) => _emit('chat:message', data));
    _socket!.on('chat:session:updated', (data) => _emit('chat:session:updated', data));
    _socket!.on('chat:session:waiting', (data) => _emit('chat:session:waiting', data));
    _socket!.on('chat:session:accepted', (data) => _emit('chat:session:accepted', data));
    _socket!.on('typing:start', (data) => _emit('typing:start', data));
    _socket!.on('typing:stop', (data) => _emit('typing:stop', data));
  }

  /// Join ticket room
  void joinTicket(String ticketId) {
    _socket?.emit('ticket:join', {'ticketId': ticketId});
  }

  /// Leave ticket room
  void leaveTicket(String ticketId) {
    _socket?.emit('ticket:leave', {'ticketId': ticketId});
  }

  /// Join chat room
  void joinChat(String sessionId) {
    _socket?.emit('chat:join', {'sessionId': sessionId});
  }

  /// Leave chat room
  void leaveChat(String sessionId) {
    _socket?.emit('chat:leave', {'sessionId': sessionId});
  }

  /// Send typing indicator
  void sendTyping(String sessionId, bool isTyping) {
    final event = isTyping ? 'typing:start' : 'typing:stop';
    _socket?.emit(event, {'sessionId': sessionId});
  }

  /// Subscribe to event
  Function on(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = {};
    }
    _listeners[event]!.add(callback);

    // Return unsubscribe function
    return () {
      _listeners[event]?.remove(callback);
    };
  }

  /// Emit event to listeners
  void _emit(String event, dynamic data) {
    final callbacks = _listeners[event];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback(data);
      }
    }
  }

  /// Check if connected
  bool get isConnected => _socket?.connected ?? false;
}

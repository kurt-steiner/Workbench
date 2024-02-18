import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketState extends ChangeNotifier {
  IOWebSocketChannel? _socket;
  IOWebSocketChannel get socket => _socket!;
  set socket(IOWebSocketChannel channel) => _socket = channel;


}
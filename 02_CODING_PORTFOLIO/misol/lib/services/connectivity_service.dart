import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _initConnectivity();
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      debugPrint('Failed to initialize connectivity monitoring: $e');
      // Assume online if connectivity monitoring fails
      _isOnline = true;
    }
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      _isOnline = true;
      notifyListeners();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final newStatus = result != ConnectivityResult.none;
    if (_isOnline != newStatus) {
      _isOnline = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

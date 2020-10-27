import 'caching_policy.dart';
import 'package:meta/meta.dart';

class CacheState {
  DateTime _previousRefresh; // Date of last refresh
  DateTime _mostRecentRefresh;
  bool _hasInternetConnection = false;

  CacheState();

  // Getters
  DateTime get previousRefresh => _previousRefresh;
  DateTime get mostRecentRefresh => _mostRecentRefresh;
  bool get hasInternet => _hasInternetConnection;

  // Setters
  void markRefreshDate(DateTime dateTime) {
    _previousRefresh = mostRecentRefresh;
    _mostRecentRefresh = dateTime;
  }

  void setHasInternetConnection(bool connected) {
    _hasInternetConnection = connected;
  }
}

// Timer utilities
class HomeScreenTimerUtils {
  // Check if widget should update based on time
  static bool shouldUpdateWidget(DateTime currentTime) {
    return currentTime.second % 60 == 0;
  }

  // Check if refresh is too recent
  static bool isRefreshTooRecent(DateTime? lastUpdate, int minSeconds) {
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate).inSeconds < minSeconds;
  }

  // Format time components for prayer display
  static Map<String, int> getTimeComponents(Duration timeLeft) {
    return {'hours': timeLeft.inHours, 'minutes': timeLeft.inMinutes % 60};
  }
}

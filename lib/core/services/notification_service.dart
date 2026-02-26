abstract class NotificationService {
  Future<void> requestPermission();
  Future<void> showLocalNotification({
    required String title,
    required String body,
  });
}

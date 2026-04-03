import 'package:permission_handler/permission_handler.dart';

Future<void> requestAllPermissions() async {
  try {
    // ✅ FIX FOR []15 - Request storage permission
    await Permission.storage.request();

    // ✅ FIX FOR []22 - Request manage external storage
    if (await Permission.manageExternalStorage.isRestricted) {
      // This permission requires manual approval in Settings
      await openAppSettings();
    } else {
      await Permission.manageExternalStorage.request();
    }

    // Other permissions
    await Permission.camera.request();
    await Permission.location.request();

    print("✅ All permissions requested successfully");
  } catch (e) {
    print("❌ Permission error: $e");
  }
}

// ✅ Check permission status
Future<bool> checkStoragePermissions() async {
  final storageStatus = await Permission.storage.status;
  final manageStatus = await Permission.manageExternalStorage.status;

  print("Storage: $storageStatus");
  print("Manage External: $manageStatus");

  return storageStatus.isGranted && manageStatus.isGranted;
}
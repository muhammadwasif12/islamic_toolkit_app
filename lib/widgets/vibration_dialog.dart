import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import '../view_model/counter_state_provider.dart';

void showVibrationDialog(BuildContext context, VibrationStatus status) {
  String title = "Touch Vibration Off";
  String message = "";

  switch (status) {
    case VibrationStatus.disabled:
      title = "Touch Vibration Disabled";
      message =
          "Touch screen vibration seems to be disabled.\n\n"
          "For better tasbeeh experience, please enable:\n"
          "• Touch vibration/feedback\n"
          "• Haptic feedback\n"
          "• System vibration\n\n"
          "Go to Settings > Sound > Touch vibration";
      break;
    case VibrationStatus.noHardware:
      title = "No Vibration Support";
      message =
          "Your device doesn't support vibration feedback.\n\n"
          "The tasbeeh counter will work normally without vibration.";
      break;
    case VibrationStatus.unknown:
      title = "Vibration Check Failed";
      message =
          "Unable to detect touch vibration status.\n\n"
          "If you don't feel vibration while using tasbeeh, "
          "please check your device's sound settings.";
      break;
    default:
      message = "Touch vibration may not be working properly.";
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vibration,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              if (status == VibrationStatus.disabled ||
                  status == VibrationStatus.unknown)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Enable 'Touch vibration' in Sound settings for better experience",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            if (status == VibrationStatus.disabled ||
                status == VibrationStatus.unknown)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    AppSettings.openAppSettings(type: AppSettingsType.sound);
                  },
                  icon: Icon(Icons.settings, size: 18),
                  label: Text("Open Sound Settings"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Continue Without Vibration"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
  );
}

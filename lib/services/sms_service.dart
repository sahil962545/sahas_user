import 'dart:async';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  /// Checks if SEND_SMS permission is granted.
  static Future<bool> isPermissionGranted() async {
    return await Permission.sms.isGranted;
  }

  /// Requests the SEND_SMS permission.
  static Future<PermissionStatus> requestPermission() async {
    return await Permission.sms.request();
  }

  static const String adminPhoneNumber = '9702402960';

  /// Sends the report SMS to the hardcoded administrator phone number.
  /// Returns true if successfully sent, or throws an error on failure/timeout.
  static Future<bool> sendReport({
    required String employeeName,
    required String mood,
    required String remarks,
  }) async {
    final completer = Completer<bool>();

    final formattedMood = mood.toLowerCase();
    final message = 'Sahas-$employeeName -$formattedMood-$remarks';

    try {
      await _telephony.sendSms(
        to: adminPhoneNumber,
        message: message,
        statusListener: (SendStatus status) {
          if (status == SendStatus.SENT) {
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          }
        },
      );

      // Set up a safety timeout of 12 seconds in case statusListener is not triggered by Android
      Future.delayed(const Duration(seconds: 12), () {
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException(
              'Sending timed out. Please verify your cell service and retry.',
            ),
          );
        }
      });
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }
}

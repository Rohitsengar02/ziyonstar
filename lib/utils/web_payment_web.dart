import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Web implementation using dart:js
void triggerWebPaymentSdk(
  String sessionId, {
  Function? onSuccess,
  Function? onError,
  Function? onCancelled,
}) {
  try {
    debugPrint('Triggering UPIGateway SDK with Session ID: $sessionId');
    final paymentSDK = js.JsObject(js.context['EKQR'], [
      js.JsObject.jsify({
        'sessionId': sessionId,
        'callbacks': {
          'onSuccess': (response) {
            debugPrint('SDK Success Callback: $response');
            onSuccess?.call(response);
          },
          'onError': (response) {
            debugPrint('SDK Error Callback: $response');
            onError?.call(response);
          },
          'onCancelled': (response) {
            debugPrint('SDK Cancelled Callback');
            onCancelled?.call(response);
          },
        },
      }),
    ]);
    paymentSDK.callMethod('pay');
  } catch (e) {
    debugPrint('Error calling EKQR SDK: $e');
  }
}

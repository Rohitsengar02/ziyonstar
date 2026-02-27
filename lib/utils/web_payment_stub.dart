/// Stub for non-web platforms. Does nothing.
void triggerWebPaymentSdk(
  String sessionId, {
  Function? onSuccess,
  Function? onError,
  Function? onCancelled,
}) {
  // No-op on non-web platforms
}

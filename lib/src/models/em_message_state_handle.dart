class EMMessageStateHandle {
  final String messageKey;
  final void Function(Map<String, dynamic>)? onMessageError;
  final void Function(Map<String, dynamic>)? onMessageProgressChanged;
  final void Function(Map<String, dynamic>)? onMessageSuccess;
  final void Function(Map<String, dynamic>)? onMessageReadAck;
  final void Function(Map<String, dynamic>)? onMessageDeliveryAck;
  final void Function(Map<String, dynamic>)? onMessageStatusChanged;

  EMMessageStateHandle(
    this.messageKey, {
    this.onMessageError,
    this.onMessageProgressChanged,
    this.onMessageSuccess,
    this.onMessageReadAck,
    this.onMessageDeliveryAck,
    this.onMessageStatusChanged,
  });
}

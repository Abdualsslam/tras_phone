part of 'support_enums.dart';

enum MessageSenderType {
  customer,
  agent,
  system;

  static MessageSenderType fromString(String value) {
    return MessageSenderType.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => MessageSenderType.system,
    );
  }
}

enum MessageType {
  text,
  internalNote,
  statusChange,
  assignment,
  escalation,
  cannedResponse;

  static MessageType fromString(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'internal_note':
        return MessageType.internalNote;
      case 'status_change':
        return MessageType.statusChange;
      case 'assignment':
        return MessageType.assignment;
      case 'escalation':
        return MessageType.escalation;
      case 'canned_response':
        return MessageType.cannedResponse;
      default:
        return MessageType.text;
    }
  }
}

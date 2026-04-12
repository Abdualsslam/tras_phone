part of 'support_enums.dart';

enum ChatSessionStatus {
  waiting,
  active,
  onHold,
  ended,
  abandoned;

  static ChatSessionStatus fromString(String value) {
    return ChatSessionStatus.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => ChatSessionStatus.waiting,
    );
  }

  String get displayNameAr {
    switch (this) {
      case ChatSessionStatus.waiting:
        return 'في الانتظار';
      case ChatSessionStatus.active:
        return 'نشطة';
      case ChatSessionStatus.onHold:
        return 'معلقة';
      case ChatSessionStatus.ended:
        return 'منتهية';
      case ChatSessionStatus.abandoned:
        return 'مهجورة';
    }
  }
}

enum ChatSenderType {
  visitor,
  agent,
  system,
  bot;

  static ChatSenderType fromString(String value) {
    return ChatSenderType.values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => ChatSenderType.system,
    );
  }
}

enum ChatMessageType {
  text,
  image,
  file,
  system,
  bot,
  quickReply;

  static ChatMessageType fromString(String value) {
    switch (value) {
      case 'text':
        return ChatMessageType.text;
      case 'image':
        return ChatMessageType.image;
      case 'file':
        return ChatMessageType.file;
      case 'system':
        return ChatMessageType.system;
      case 'bot':
        return ChatMessageType.bot;
      case 'quick_reply':
        return ChatMessageType.quickReply;
      default:
        return ChatMessageType.text;
    }
  }

  String get apiValue {
    switch (this) {
      case ChatMessageType.quickReply:
        return 'quick_reply';
      default:
        return name;
    }
  }
}

import 'package:flutter/material.dart';

/// حالة التذكرة
enum TicketStatus {
  open,
  awaitingResponse,
  inProgress,
  onHold,
  escalated,
  resolved,
  closed,
  reopened;

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'open':
        return TicketStatus.open;
      case 'awaiting_response':
        return TicketStatus.awaitingResponse;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'on_hold':
        return TicketStatus.onHold;
      case 'escalated':
        return TicketStatus.escalated;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'reopened':
        return TicketStatus.reopened;
      default:
        return TicketStatus.open;
    }
  }

  String get apiValue {
    switch (this) {
      case TicketStatus.awaitingResponse:
        return 'awaiting_response';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.onHold:
        return 'on_hold';
      default:
        return name;
    }
  }

  String get displayNameAr {
    switch (this) {
      case TicketStatus.open:
        return 'مفتوحة';
      case TicketStatus.awaitingResponse:
        return 'بانتظار الرد';
      case TicketStatus.inProgress:
        return 'قيد المعالجة';
      case TicketStatus.onHold:
        return 'معلقة';
      case TicketStatus.escalated:
        return 'مُصعّدة';
      case TicketStatus.resolved:
        return 'تم الحل';
      case TicketStatus.closed:
        return 'مغلقة';
      case TicketStatus.reopened:
        return 'أعيد فتحها';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.awaitingResponse:
        return Colors.orange;
      case TicketStatus.inProgress:
        return Colors.purple;
      case TicketStatus.onHold:
        return Colors.grey;
      case TicketStatus.escalated:
        return Colors.red;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey.shade700;
      case TicketStatus.reopened:
        return Colors.amber;
    }
  }
}

/// أولوية التذكرة
enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  static TicketPriority fromString(String value) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketPriority.medium,
    );
  }

  String get displayNameAr {
    switch (this) {
      case TicketPriority.low:
        return 'منخفضة';
      case TicketPriority.medium:
        return 'متوسطة';
      case TicketPriority.high:
        return 'عالية';
      case TicketPriority.urgent:
        return 'عاجلة';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.blue;
      case TicketPriority.high:
        return Colors.orange;
      case TicketPriority.urgent:
        return Colors.red;
    }
  }
}

/// مصدر التذكرة
enum TicketSource {
  web,
  mobileApp,
  email,
  phone,
  liveChat,
  socialMedia;

  static TicketSource fromString(String value) {
    switch (value) {
      case 'web':
        return TicketSource.web;
      case 'mobile_app':
        return TicketSource.mobileApp;
      case 'email':
        return TicketSource.email;
      case 'phone':
        return TicketSource.phone;
      case 'live_chat':
        return TicketSource.liveChat;
      case 'social_media':
        return TicketSource.socialMedia;
      default:
        return TicketSource.mobileApp;
    }
  }

  String get apiValue {
    switch (this) {
      case TicketSource.mobileApp:
        return 'mobile_app';
      case TicketSource.liveChat:
        return 'live_chat';
      case TicketSource.socialMedia:
        return 'social_media';
      default:
        return name;
    }
  }
}

/// نوع الحل
enum ResolutionType {
  solved,
  wontFix,
  duplicate,
  invalid,
  customerAbandoned;

  static ResolutionType fromString(String value) {
    switch (value) {
      case 'solved':
        return ResolutionType.solved;
      case 'wont_fix':
        return ResolutionType.wontFix;
      case 'duplicate':
        return ResolutionType.duplicate;
      case 'invalid':
        return ResolutionType.invalid;
      case 'customer_abandoned':
        return ResolutionType.customerAbandoned;
      default:
        return ResolutionType.solved;
    }
  }
}

/// نوع مرسل الرسالة
enum MessageSenderType {
  customer,
  agent,
  system;

  static MessageSenderType fromString(String value) {
    return MessageSenderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageSenderType.system,
    );
  }
}

/// نوع الرسالة
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

/// حالة جلسة المحادثة
enum ChatSessionStatus {
  waiting,
  active,
  onHold,
  ended,
  abandoned;

  static ChatSessionStatus fromString(String value) {
    return ChatSessionStatus.values.firstWhere(
      (e) => e.name == value,
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

/// نوع مرسل رسالة المحادثة
enum ChatSenderType {
  visitor,
  agent,
  system,
  bot;

  static ChatSenderType fromString(String value) {
    return ChatSenderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatSenderType.system,
    );
  }
}

/// نوع رسالة المحادثة
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

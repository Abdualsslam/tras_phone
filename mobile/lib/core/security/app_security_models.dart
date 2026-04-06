library;

enum AppSecurityStatus { trusted, restricted, blocked }

class LocalSecuritySignals {
  const LocalSecuritySignals({
    required this.platform,
    required this.isDebuggable,
    required this.isDebuggerAttached,
    required this.isEmulator,
    required this.hasTestKeys,
    required this.hasRootFiles,
    required this.hasMagiskFiles,
    required this.hasHookFramework,
    required this.hasFridaServer,
    required this.packageName,
    required this.appVersion,
    required this.issues,
  });

  final String platform;
  final bool isDebuggable;
  final bool isDebuggerAttached;
  final bool isEmulator;
  final bool hasTestKeys;
  final bool hasRootFiles;
  final bool hasMagiskFiles;
  final bool hasHookFramework;
  final bool hasFridaServer;
  final String? packageName;
  final String? appVersion;
  final List<String> issues;

  factory LocalSecuritySignals.fromJson(Map<Object?, Object?> json) {
    List<String> parseIssues(Object? value) {
      if (value is List) {
        return value.map((entry) => entry.toString()).toList();
      }
      return const <String>[];
    }

    return LocalSecuritySignals(
      platform: (json['platform'] ?? 'unknown').toString(),
      isDebuggable: json['isDebuggable'] == true,
      isDebuggerAttached: json['isDebuggerAttached'] == true,
      isEmulator: json['isEmulator'] == true,
      hasTestKeys: json['hasTestKeys'] == true,
      hasRootFiles: json['hasRootFiles'] == true,
      hasMagiskFiles: json['hasMagiskFiles'] == true,
      hasHookFramework: json['hasHookFramework'] == true,
      hasFridaServer: json['hasFridaServer'] == true,
      packageName: json['packageName']?.toString(),
      appVersion: json['appVersion']?.toString(),
      issues: parseIssues(json['issues']),
    );
  }

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'isDebuggable': isDebuggable,
    'isDebuggerAttached': isDebuggerAttached,
    'isEmulator': isEmulator,
    'hasTestKeys': hasTestKeys,
    'hasRootFiles': hasRootFiles,
    'hasMagiskFiles': hasMagiskFiles,
    'hasHookFramework': hasHookFramework,
    'hasFridaServer': hasFridaServer,
    'packageName': packageName,
    'appVersion': appVersion,
    'issues': issues,
  };
}

class AppSecurityAssessment {
  const AppSecurityAssessment({
    required this.status,
    required this.signals,
    required this.reasons,
    required this.enforcementEnabled,
  });

  final AppSecurityStatus status;
  final LocalSecuritySignals signals;
  final List<String> reasons;
  final bool enforcementEnabled;

  bool get shouldBlock =>
      enforcementEnabled && status == AppSecurityStatus.blocked;

  String get statusKey => status.name;
}

class DeviceIntegrityChallenge {
  const DeviceIntegrityChallenge({
    required this.nonce,
    this.expiresAt,
  });

  final String nonce;
  final String? expiresAt;

  factory DeviceIntegrityChallenge.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return DeviceIntegrityChallenge(
      nonce: (data['nonce'] ?? '').toString(),
      expiresAt: data['expiresAt']?.toString(),
    );
  }
}

class DeviceIntegrityPayload {
  const DeviceIntegrityPayload({
    required this.platform,
    required this.requestType,
    required this.localSignals,
    required this.requestHash,
    this.nonce,
    this.integrityToken,
    this.packageName,
    this.appVersion,
  });

  final String platform;
  final String requestType;
  final LocalSecuritySignals localSignals;
  final String requestHash;
  final String? nonce;
  final String? integrityToken;
  final String? packageName;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
    'platform': platform,
    'requestType': requestType,
    'requestHash': requestHash,
    'nonce': nonce,
    'integrityToken': integrityToken,
    'packageName': packageName,
    'appVersion': appVersion,
    'signals': localSignals.toJson(),
  };
}

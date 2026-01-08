/// Token Response - Model for refresh token response
library;

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return TokenResponse(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      expiresIn: data['expiresIn'],
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
}

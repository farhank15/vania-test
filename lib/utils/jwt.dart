import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtUtil {
  static final String _secretKey =
      dotenv.env['SECRET_KEY'] ?? 'default-secret-key';
  static final String _issuer = dotenv.env['ISSUER'] ?? 'default-issuer';

  static String generateToken(
    int userId, {
    Duration? expiresIn,
    bool isRefreshToken = false,
  }) {
    final now = DateTime.now();

    final claimSet = JwtClaim(
      subject: userId.toString(),
      issuer: _issuer,
      issuedAt: now,
      maxAge: expiresIn,
      otherClaims: {
        'type': isRefreshToken ? 'refresh' : 'access',
      },
    );

    final token = issueJwtHS256(claimSet, _secretKey);
    return 'Bearer $token';
  }

  /// Verifies and decodes a JWT token
  static JwtClaim verifyToken(String token) {
    try {
      final strippedToken =
          token.startsWith('Bearer ') ? token.substring(7) : token;

      final claims = verifyJwtHS256Signature(strippedToken, _secretKey);

      claims.validate(issuer: _issuer);

      return claims;
    } catch (e) {
      throw Exception('Token tidak valid: ${e.toString()}');
    }
  }

  /// Validates a refresh token
  static JwtClaim verifyRefreshToken(String token) {
    final claims = verifyToken(token);

    if (claims.payload['type'] != 'refresh') {
      throw Exception('Token bukan refresh token');
    }

    return claims;
  }
}

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtUtil {
  static final String _secretKey =
      dotenv.env['SECRET_KEY'] ?? 'default-secret-key';
  static final String _issuer = dotenv.env['ISSUER'] ?? 'default-issuer';

  /// Generate JWT Token
  static String generateToken({
    required int userId,
    required String name,
    required String email,
    bool isRefreshToken = false,
    Duration? expiresIn,
  }) {
    try {
      final now = DateTime.now();

      final claimSet = JwtClaim(
        subject: userId.toString(),
        issuer: _issuer,
        issuedAt: now,
        maxAge: expiresIn ?? const Duration(minutes: 15),
        payload: {
          'user_id': userId,
          'name': name,
          'email': email,
          'type': isRefreshToken ? 'refresh' : 'access',
        },
      );

      return issueJwtHS256(claimSet, _secretKey);
    } catch (e) {
      throw Exception('Gagal membuat token: ${e.toString()}');
    }
  }

  /// Verifies and decodes a JWT token
  static JwtClaim verifyToken(String token) {
    try {
      final strippedToken =
          token.startsWith('Bearer ') ? token.substring(7) : token;
      final claims = verifyJwtHS256Signature(strippedToken, _secretKey);

      // Validasi klaim penting
      claims.validate(issuer: _issuer);

      return claims;
    } catch (e) {
      print('JWT verification failed: $e');
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

  /// Validates an access token
  static JwtClaim verifyAccessToken(String token) {
    final claims = verifyToken(token);

    if (claims.payload['type'] != 'access') {
      throw Exception('Token bukan access token');
    }

    return claims;
  }
}

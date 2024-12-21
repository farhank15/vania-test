import 'package:vania/vania.dart';

class ResponseUtil {
  static Response createErrorResponse(String message, dynamic error,
      [int code = 500]) {
    return Response.json(
      {'status': 'error', 'message': '$message: ${error.toString()}'},
      code,
    );
  }

  static Response createSuccessResponse(String message, dynamic data,
      [int code = 200]) {
    return Response.json(
      {'status': 'success', 'message': message, 'data': data},
      code,
    );
  }
}

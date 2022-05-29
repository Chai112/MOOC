import 'package:mooc/services/networking_service.dart' as networking_service;

class Token {
  String token;
  Token(this.token);
}

class AuthUser {
  Future<Token> login(
      {required String username, required String password}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response = await networking_service
          .getServer("login", {"username": "username", "password": "password"});
      return Token(response["message"]);
    } catch (_) {
      rethrow;
    }
  }
}

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
          .getServer("login", {"username": username, "password": password});
      return Token(response["message"]);
    } catch (_) {
      rethrow;
    }
  }

  Future<Token> register(
      {required String username,
      required String password,
      required String email,
      required String firstname,
      required String lastname}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response =
          await networking_service.getServer("register", {
        "username": username,
        "password": password,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
      });
      return Token(response["message"]);
    } catch (_) {
      rethrow;
    }
  }
}

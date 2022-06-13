import 'package:mooc/services/networking_service.dart' as networking_service;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

final Storage _localStorage = window.localStorage;
final AuthUser globalUser = AuthUser();

class Token {
  final String token;
  Token(this.token);
}

class AuthUser {
  Token? token;
  String? username, email, firstName, lastName;
  AuthUser({this.token});

  Future<void> tryLogin() async {
    // load the token and other data via local cookies.
    // if success

    // pull token from local
    String authTokenSaved = _localStorage['token'] ?? "";
    if (authTokenSaved != "") {
      token =
          Token(authTokenSaved); // recieve the token (user is now logged in)
      try {
        await _getUserFromToken(); // get other info from token
      } catch (_) {
        rethrow;
      }
    }
  }

  void _saveToLocal() {
    _localStorage['token'] = token?.token ?? "";
  }

  Future<void> _getUserFromToken() async {
    try {
      Map<String, dynamic> response = await networking_service
          .getServer("getUserFromToken", {"token": token!.token});
      if (response != {}) {
        username = response["username"];
        email = response["email"];
        firstName = response["firstName"];
        lastName = response["lastName"];
      }
    } catch (_) {
      rethrow;
    }
  }

  bool isLoggedIn() {
    return token != null;
  }

  Future<void> login(
      {required String username, required String password}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response = await networking_service
          .getServer("login", {"username": username, "password": password});
      token = Token(response["token"]);
      // email, firstName and lastName are included from the server on login
      await _getUserFromToken();
      _saveToLocal();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> register(
      {required String username,
      required String password,
      required String email,
      required String firstName,
      required String lastName}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response =
          await networking_service.getServer("register", {
        "username": username,
        "password": password,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
      });
      token = Token(response["token"]);
      await _getUserFromToken();
      _saveToLocal();
    } catch (_) {
      rethrow;
    }
  }
}

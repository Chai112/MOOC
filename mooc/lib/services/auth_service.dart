import 'package:mooc/services/networking_service.dart' as networking_service;

class Token {
  final String token;
  bool isInitialized = false;
  Token({this.token = ""}) {
    isInitialized = token != "";
    print("created token ${token} and is init? ${isInitialized}");
  }
}

Token globalToken = Token();

bool isLoggedIn() {
  return globalToken.isInitialized;
}

Future<void> login({required String username, required String password}) async {
  username = username;
  password = password;
  try {
    // Await the http get response, then decode the json-formatted response.
    Map<String, dynamic> response = await networking_service
        .getServer("login", {"username": username, "password": password});
    globalToken = Token(token: response["token"]);
  } catch (_) {
    rethrow;
  }
}

Future<void> register(
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
  } catch (_) {
    rethrow;
  }
}

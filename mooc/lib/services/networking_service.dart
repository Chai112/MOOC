import 'package:http/http.dart' as http;
import 'dart:convert';

const String uriScheme = "http";
const String uriHost = "ec2-54-255-233-46.ap-southeast-1.compute.amazonaws.com";
const int uriPort = 3000;

//TODO: maybe put this in error_service instead
class NetworkingException implements Exception {
  String message;
  String? description;
  bool expandError;
  NetworkingException(this.message,
      {this.description, this.expandError = true});
}

Future<Map<String, dynamic>> getServer(
    String action, Map<String, String> queryParameters) async {
  // add action to queries
  queryParameters["action"] = action;
  // form query
  final Uri requestUri = Uri(
    scheme: uriScheme,
    host: uriHost,
    port: uriPort,
    queryParameters: queryParameters,
  );
  // request query
  http.Response? response;
  try {
    response = await http.get(requestUri);
  } catch (err) {
    throw NetworkingException("something went wrong",
        description: "Cannot connect to the server.");
  }
  print(response.statusCode);
  switch (response.statusCode) {
    case 200: // OK
      // take the response
      String resBodyStr = response.body;
      Map<String, dynamic> resBodyJson = jsonDecode(resBodyStr);
      return resBodyJson;
    case 400: // bad request  (client error)
      print(response.body);
      throw NetworkingException("something went wrong",
          description: "400: Bad request, client error");
    case 403: // forbidden    (user error)
      String resBodyStr = response.body;
      Map<String, dynamic> resBodyJson = jsonDecode(resBodyStr);
      throw NetworkingException(resBodyJson["message"], expandError: false);
    case 500: // server error (server error)
      throw NetworkingException("something went wrong",
          description: "500: Bad request, server error");
    default: // anything could happen
      throw NetworkingException("something went wrong",
          description:
              "can connect to server but recieved an unknown status code");
  }
}

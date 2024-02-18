import 'dart:convert';

String displayResponse(dynamic response) {
  Map<String, dynamic> jsonResponse;
  if (response is String) {
    jsonResponse = jsonDecode(response) as Map<String, dynamic>;
  } else if (response is Map) {
    jsonResponse = response.cast<String, dynamic>();
  } else {
    return 'Unexpected response format';
  }

  // Handle success message
  if (jsonResponse.containsKey('message')) {
    return jsonResponse['message'];
  }

  // Handle errors
  Map<String, dynamic> errors = {};
  if (jsonResponse.containsKey('errors')) {
    errors = jsonResponse['errors'] as Map<String, dynamic>;
  } else if (jsonResponse.containsKey('error')) {
    errors = {
      'general': [jsonResponse['error']]
    };
  }

  String responseMessage = '';
  errors.forEach((key, dynamic value) {
    if (value is List<dynamic> && value.isNotEmpty) {
      responseMessage += '${value[0]}\n';
    } else if (value is String) {
      responseMessage += '$value\n';
    }
  });

  if (responseMessage.isNotEmpty) {
    responseMessage = responseMessage.substring(0, responseMessage.length - 1);
  }

  return responseMessage;
}

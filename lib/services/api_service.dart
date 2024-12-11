import 'dart:convert';
import 'package:http/http.dart' as http;

const String METHOD_POST = "POST";
const String userLocal = '@user';
const String logoutLocal = '@logout';
const String SERVICE_KEY = 'CgYh5TbHicce4HDZzk11At2Z2k1DuxkR';

const String LOCAL_URL = "https://dev.support.africasystems.com";
const String DATABASE = "support_erp_db";
const Map<String, String> headers = {
  'api-key': 'Y1ZPPWYA7240ACT27P5MZNISUHB8KX8H',
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dpbiI6ImFkbWluQGFmcmljYXN5c3RlbXMuY29tIiwidWlkIjoyfQ.6xsEW-0sso5zckj-jP4Jgxi9N5IWjIpZnFR0UUFFS5k',
};

const String LOCAL_URL1 = "https://soft.metuaa.com";
const String DATABASE1 = "openeducat_erp";
const Map<String, String> headers1 = {
  'api-key': 'Y5998ZQH6V40G1AM48EJP329SN6DMUR1',
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsb2dpbiI6ImFkbWluQHNvZnRlZHVjYXQub3JnIiwidWlkIjoyfQ.4xzNf2eP5zZE5kCq-V65N5wJQZTPJEUtGljXCvOapsE',
};

Future<Map<String, dynamic>> postData(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(arg),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> postData1(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  final response = await http.post(
    Uri.parse(url),
    headers: headers1,
    body: jsonEncode(arg),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    throw Exception("Erreur de réponse: ${response.statusCode}");
  }
}

Future<Map<String, dynamic>> postDataSave(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(arg),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> putDataMRedis(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  final response = await http.put(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(arg),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> AddAmount(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};
  formData["partner_id"] = arg?['partner_id'] ?? '';
  formData["amount"] = arg?['amount'] ?? '';
  formData["journal_id"] = arg?['selectJournals'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> RechargeMobileWalletEnd(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};
  arg?.forEach((key, value) {
    formData[key] = value;
  });

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> MobileRechargeBalence(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};
  formData["service"] = SERVICE_KEY;
  formData["amount"] = arg?['amount'] ?? '';
  formData["phonenumber"] = arg?['phoneNumber'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> MobileVerifyBalence(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};
  formData["paymentId"] = arg?['paymentId'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> SentOtp(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");

  var formData = <String, String>{};
  formData["email"] = arg?['email'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> VerifyOtp(String url) async {
  print("request URL: $url");

  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

Future<Map<String, dynamic>> postDataDoc(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};
  formData["document"] = arg?['document'] ?? '';
  formData["assignment_id"] = arg?['assignment_id'] ?? '';
  formData["student_id"] = arg?['student_id'] ?? '';
  formData["submission_date"] = arg?['submission_date'] ?? '';
  formData["description"] = arg?['description'] ?? '';
  formData["note"] = arg?['note'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

String getCorrectDateFormat(String chaine) {
  DateTime date = DateTime.parse(chaine);
  return date.toIso8601String().replaceFirst('T', ' ').replaceAll(RegExp(r'\.\d+Z'), '');
}

Future<Map<String, dynamic>> postDataVehicule(String url, {Map<String, dynamic>? arg}) async {
  print("request URL: $url");
  print("request arg: ${jsonEncode(arg)}");

  var formData = <String, String>{};

  if (arg?['images'] != null) {
    var images = arg?['images'];
    if (images['face'] != null) formData["face"] = images['face'];
    if (images['dos'] != null) formData["dos"] = images['dos'];
    if (images['cote'] != null) formData["cote"] = images['cote'];
    if (images['interieur'] != null) formData["interieur"] = images['interieur'];
  }

  formData["user_id"] = arg?['UserID'].toString() ?? '';
  formData["chassisNumber"] = arg?['chassisNumber'] ?? '0';
  formData["licensePlate"] = arg?['licensePlate'] ?? '---';
  formData["vin"] = arg?['vin'] ?? '';
  formData["vehicle"] = arg?['vehicle'] ?? '';
  formData["isAssigned"] = arg?['isAssigned'].toString() ?? 'false';
  formData["address"] = arg?['address'] ?? '';
  formData["phone"] = arg?['phone'] ?? '';
  formData["position"] = arg?['position'] ?? '';
  formData["driver_id"] = arg?['driver_id'] ?? '';
  formData["barcode"] = arg?['barcode'] ?? '';

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: formData,
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("mauvaise reponse: ${response.statusCode}");
    return {};
  }
}

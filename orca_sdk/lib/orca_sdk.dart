library orca_sdk;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http_apis_secure/secure.dart' as secure;
import 'package:http/http.dart' as http;

typedef JSON = Map<String, Object?>;

//////////
/// GLOBAL
//////////

Client init(String appId) {
  if (String.fromEnvironment('ORCA_APP_KEY', defaultValue: '') == '') {
    throw Exception(
        'Orca client initialisation failed: no app key variable found in environment.');
  } else {
    return Client(
      appId,
      secure.Key.fromBase64(
        String.fromEnvironment('ORCA_APP_KEY'),
      ),
    );
  }
}

//////////
/// BASE CLIENT
//////////

class Client {
  final secure.Key key;
  final String appId;
  final http.Client client = http.Client();

  Client(this.appId, this.key);

  Future<List<Uint8List>> listFiles(String dir) async {
    final res = await http.post(
        Uri.http(
          'localhost:8083',
          'orca-services/files/list',
        ),
        headers: {'uid': appId},
        body: secure.encryptPayload(
          key,
          {'dir': dir},
        ));
    return [
      for (final encodedFile
          in (secure.decryptPayload(key, res.body)['payload']! as List)
              .cast<String>())
        base64Decode(encodedFile)
    ];
  }
}

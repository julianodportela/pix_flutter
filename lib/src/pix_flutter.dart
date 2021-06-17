import 'dart:convert';
import 'package:pix_flutter/src/models/Api.dart';
import '../pix_flutter.dart';
import 'models/models.dart';
import 'package:http/http.dart' as http;

String idPaylodFormatIndicator = "00";
String idPointOfInitiationMethod = "01";
String idMerchantAccountInformation = "26";
String idMerchantAccountInformationGUI = "00";
String idMerchantAccountInformationKey = "01";
String idMerchantAccountInformationDescription = "02";
String idMerchantAccountInformationURL = "25";
String idMerchantCategoryCode = "52";
String idTransactionCurrency = "53";
String idTransactionAmount = "54";
String idCountryCode = "58";
String idMerchantName = "59";
String idMerchantCity = "60";
String idAdditionalDataFieldTemplate = "62";
String idAdditionalDataFieldTemplateTXID = "05";
String idCRC16 = "63";

class PixFlutter {

  Api? api;
  Payload? payload;

  PixFlutter({
    this.api,
    this.payload
  });


  getStaticCode() {

    getValue(id, value) {
      final size = value.length.toString().padLeft(2, "0");
      return "$id$size$value";
    }

    getAmount() {
      return double.parse(payload!.amount!).toStringAsFixed(2);
    }

    getMerchantAccountInfo() {
      final gui = getValue(
          idMerchantAccountInformationGUI,
          "br.gov.bcb.pix"
      );
      final key = getValue(
          idMerchantAccountInformationKey,
          this.payload!.pixKey
      );

      // Há um erro no API que impede o uso de descrição
      // final description = getValue(
      //     idMerchantAccountInformationDescription,
      //     this.payload!.description
      // );

      // Há um erro no API que impede o uso de descrição
      // return getValue(
      //     idMerchantAccountInformation,
      //     "$gui$key$description"
      // );

      return getValue(
          idMerchantAccountInformation,
          "$gui$key"
      );
    }

    getAdditionalDataFieldTemplate() {
      final txid = getValue(
          idAdditionalDataFieldTemplateTXID,
          this.payload!.txid
      );
      return getValue(idAdditionalDataFieldTemplate, txid);
    }

    getCRC16(payload) {
      ord(str) {
        return str.codeUnitAt(0);
      }
      dechex(number) {
        if (number < 0) {
          number = 0xffffffff + number + 1;
        }
        return number.toRadixString(16);
      }

      payload = payload + idCRC16 + "04";

      var polinomio = 0x1021;
      var resultado = 0xffff;
      var length;

      if ((length = payload.length) > 0) {
        for (var offset = 0; offset < length; offset++) {
          resultado ^= ord(payload[offset]) << 8;
          for (var bitwise = 0; bitwise < 8; bitwise++) {
            if (((resultado <<= 1) & 0x10000) != 0) resultado ^= polinomio;
            resultado &= 0xffff;
          }
        }
      }

      return idCRC16 + "04" + dechex(resultado).toUpperCase();
    }

    String getPayload() {
      final payload =
          getValue(idPaylodFormatIndicator, "01") +
              getMerchantAccountInfo() +
              getValue(idMerchantCategoryCode, "0000") +
              getValue(idTransactionCurrency, "986") +
              getValue(idTransactionAmount, getAmount()) +
              getValue(idCountryCode, "BR") +
              getValue(idMerchantName, this.payload!.merchantName) +
              getValue(idMerchantCity, this.payload!.merchantCity) +
              getAdditionalDataFieldTemplate();

      print("$payload${getCRC16(payload)}");
      return "$payload${getCRC16(payload)}";
    }

    return getPayload();

  }

  getAccessToken() async {

    var headers = {
      'Authorization': '${api!.certificate}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var bodyFields = {
      'grant_type': 'client_credentials',
      'scope': '${api!.permissions.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(',', '')}'
    };

    var request;

    if(api!.isBancoDoBrasil!) {
      request = http.Request('POST', Uri.parse('${api!.authUrl}?gw-dev-app-key=${api!.appKey}'));
    } else {
      request = http.Request('POST', Uri.parse('${api!.authUrl}'));
    }

    request.bodyFields = bodyFields;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(await response.stream.bytesToString());

      return result['access_token'];
    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future<Map<String, dynamic>> getCobPayload({pixUrlAccessToken}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return await send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/$pixUrlAccessToken');

  }

  getCobVPayload({pixUrlAccessToken}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/cobv/$pixUrlAccessToken');

  }

  createCobTxid({txid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(headers: headers, customRequest: 'PUT', link: '${api!.baseUrl}/cob/$txid', data: request);

  }

  reviewCob({txid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PATCH', link: '${api!.baseUrl}/cob/$txid', data: request);

  }

  checkCob({txid}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/cob/$txid');

  }

  createCob({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'POST', link: '${api!.baseUrl}/cob', data: request);

  }

  checkCobList({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/cob', data: request);

  }

  createCobV({txid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PUT', link: '${api!.baseUrl}/cobv/$txid', data: request);

  }

  reviewCobV({txid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PATCH', link: '${api!.baseUrl}/cobv/$txid', data: request);

  }

  checkCobV({txid}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/cobv/$txid');

  }

  checkCobVList({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/cobv', data: request);

  }

  createLoteCobV({id, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PUT', link: '${api!.baseUrl}/lotecobv/$id', data: request);

  }

  checkLoteCobV({id}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/lotecobv/$id');

  }

  checkLoteCobVList({txid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/lotecobv', data: request);

  }

  createPayloadLocation({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'POST', link: '${api!.baseUrl}/loc', data: request);

  }

  checkLocations({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/loc', data: request);

  }

  recoverLocation({id}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/loc/$id');

  }

  deleteLocation({id}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}'
    };

    send(headers: headers, customRequest: 'DELETE', link: '${api!.baseUrl}/loc/$id/txid');

  }

  checkPix({e2eid, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/pix/$e2eid');

  }

  checkReceivedPixList({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/pix', data: request);

  }

  askRefundPix({e2eid, id, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PUT', link: '${api!.baseUrl}/pix/$e2eid/devolucao/$id', data: request);

  }

  checkRefundPix({e2eid, id}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/pix/$e2eid/devolucao/$id');

  }

  setupWebhook({chave, request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'PUT', link: '${api!.baseUrl}/webhook/$chave', data: request);

  }

  infoWebhook({chave}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/webhook/$chave');

  }

  deleteWebhook({chave}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    send(headers: headers, customRequest: 'DELETE', link: '${api!.baseUrl}/webhook/$chave');

  }

  checkWebhooks({request}) async {

    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    send(headers: headers, customRequest: 'GET', link: '${api!.baseUrl}/webhook', data: request);

  }

  Future<Map<String, dynamic>> send({headers, customRequest, link, data}) async {

    http.Request request;

    if(api!.isBancoDoBrasil!) {
      request = http.Request('$customRequest', Uri.parse('$link?gw-dev-app-key=${api!.appKey}'));
    } else {
      request = http.Request('$customRequest', Uri.parse('$link'));
    }

    if(data != null) {
      request.body = json.encode(data);
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202 || response.statusCode == 204) {
      Map<String, dynamic> result = json.decode(await response.stream.bytesToString());

      print(result);
      return result;
    }
    else {
      print(response.reasonPhrase);
    }

    return {};

  }
}
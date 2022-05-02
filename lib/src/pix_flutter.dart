import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import '../pix_flutter.dart';
import 'models/models.dart';

/// IDs necessários para gerar o QR Code Estático, como definidos pelo BACEN
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

/// Classe onde estão presentes os métodos para executar as funções da API Pix
class PixFlutter {
  Api? api;
  Payload? payload;

  PixFlutter({this.api, this.payload});

  /// Método que retorna QR Code estático ou dinâmico
  getQRCode() {
    /// Calcula o valor da string em questão, é útil para fazer os métodos seguintes.
    getValue(id, value) {
      final size = value.length.toString().padLeft(2, "0");
      return "$id$size$value";
    }

    /// Formata o valor da compra
    getAmount() {
      return this.payload!.amount != null && this.payload!.amount!.length > 0
          ? double.parse(payload!.amount!).toStringAsFixed(2)
          : '';
    }

    /// Formata informações como gui, key, url e descrição
    getMerchantAccountInfo() {
      final gui = getValue(idMerchantAccountInformationGUI, "br.gov.bcb.pix");
      final key =
          this.payload!.pixKey != null && this.payload!.pixKey!.length > 0
              ? getValue(idMerchantAccountInformationKey, this.payload!.pixKey)
              : '';
      final url = this.payload!.url != null && this.payload!.url!.length > 0
          ? getValue(idMerchantAccountInformationURL,
              this.payload!.url!.replaceAll('https://', ''))
          : '';

      /// Há um erro no API que impede o uso de descrição, justificando assim os comments abaixo. Assim que estes bugs forem consertados, o código voltará ao funcionamento completo.
      // final description = getValue(
      //     idMerchantAccountInformationDescription,
      //     this.payload!.description
      // );

      // return getValue(
      //     idMerchantAccountInformation,
      //     "$gui$key$description"
      // );

      return getValue(idMerchantAccountInformation, "$gui$key$url");
    }

    /// Formata o txid
    getAdditionalDataFieldTemplate() {
      final txid = this.payload!.txid != null && this.payload!.txid!.length > 0
          ? getValue(idAdditionalDataFieldTemplateTXID, this.payload!.txid)
          : '';
      return getValue(idAdditionalDataFieldTemplate, txid);
    }

    /// Formata o isUniquePayment
    getUniquePayment() {
      final uniquePayment = this.payload!.isUniquePayment != null &&
              this.payload!.isUniquePayment == true
          ? getValue(idPointOfInitiationMethod, '12')
          : '';

      return uniquePayment;
    }

    /// Executa o método de encripção requerido pelo BACEN
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

    /// Método final para juntar e gerar o QR Code Estático final
    String getPayload() {
      final payload = getValue(idPaylodFormatIndicator, "01") +
          getUniquePayment() +
          getMerchantAccountInfo() +
          getValue(idMerchantCategoryCode, "0000") +
          getValue(idTransactionCurrency, "986") +
          (getAmount() != ''
              ? getValue(idTransactionAmount, getAmount())
              : '') +
          getValue(idCountryCode, "BR") +
          getValue(idMerchantName, this.payload!.merchantName) +
          getValue(idMerchantCity, this.payload!.merchantCity) +
          getAdditionalDataFieldTemplate();

      print("$payload${getCRC16(payload)}");
      return "$payload${getCRC16(payload)}";
    }

    return getPayload();
  }

  /// Pega o AccessToken necessário para as outras operações do servidor do seu PSP
  getAccessToken() async {
    var bodyFields;
    var headers;
    var response;
    final dio = Dio();

    if (api!.certificatePath != '' && api!.certificatePath != null) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        SecurityContext sc = SecurityContext();
        sc.setTrustedCertificates(api!.certificatePath!, password: '');
        HttpClient httpClient = HttpClient(context: sc);
        return httpClient;
      };

      headers = {
        'Content-Type': 'application/json',
      };
      bodyFields = {
        'grant_type': 'client_credentials',
      };
    } else {
      headers = {
        'Authorization': '${api!.certificate}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      bodyFields = {
        'grant_type': 'client_credentials',
        'scope':
            '${api!.permissions.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(',', '')}'
      };
    }

    if (api!.isBancoDoBrasil!) {
      response = await dio.post('${api!.authUrl}?gw-dev-app-key=${api!.appKey}',
          data: bodyFields,
          options: Options(
              headers: headers,
              contentType: Headers.formUrlEncodedContentType));
    } else {
      response = await dio.post('${api!.authUrl}',
          data: bodyFields,
          options: Options(
              headers: headers,
              contentType: Headers.formUrlEncodedContentType));
    }

    if (response.statusCode == 200) {
      return response.data['access_token'];
    } else {
      print(response.statusMessage);
    }
  }

  /// Pega o Payload de Cobrança Imediata fazendo uso do Pix Url Access Token
  Future getCobPayload({pixUrlAccessToken}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/$pixUrlAccessToken');
  }

  /// Pega o Payload de Cobrança com Vencimento fazendo uso do Pix Url Access Token
  getCobVPayload({pixUrlAccessToken}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/cobv/$pixUrlAccessToken');
  }

  /// Cria cobrança imediata com Txid
  createCobTxid({txid, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/cob/$txid',
        data: request);
  }

  /// Revisa a cobrança para poder alterar certos detalhes a partir do Txid
  reviewCob({txid, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PATCH',
        link: '${api!.baseUrl}/cob/$txid',
        data: request);
  }

  /// Consulta o status e as informações da cobrança à partir do txid
  checkCob({txid}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/cob/$txid');
  }

  /// Cria a cobrança sem Txid, sendo este gerado automaticamente
  createCob({request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'POST',
        link: '${api!.baseUrl}/cob/',
        data: request);
  }

  /// Cria a cobrança normalmente, mas já inclui o qr code dinâmico gerado na resposta ;)
  createCobQRCode({txid, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/cobqrcode/$txid',
        data: request);
  }

  /// Consulta uma lista de cobranças imediatas
  checkCobList({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/cob/',
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Cria uma Cobrança com Vencimento
  createCobV({txid, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/cobv/$txid',
        data: request);
  }

  /// Revisa uma Cobrança com Vencimento a partir do Txid para alterar certos detalhes
  reviewCobV({txid, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PATCH',
        link: '${api!.baseUrl}/cobv/$txid',
        data: request);
  }

  /// Consulta o status e as informações de uma Cobrança com Vencimento à partir do Txid
  checkCobV({txid}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/cobv/$txid');
  }

  /// Consulta o status e as informações de uma lista de Cobranças com Vencimento a partir dp Txid de cada uma delas
  checkCobVList({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/cobv/',
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Cria um lote de Cobranças com Vencimento
  createLoteCobV({id, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/lotecobv/$id',
        data: request);
  }

  /// Consulta um lote de Cobranças com Vencimento a partir da location dele
  checkLoteCobV({id}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/lotecobv/$id');
  }

  /// Consulta uma lista de lotes de Cobranças com Vencimento a partir da location de cada um deles
  checkLoteCobVList({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/lotecobv/',
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Cria uma location para o Payload
  createPayloadLocation({request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'POST',
        link: '${api!.baseUrl}/loc/',
        data: request);
  }

  /// Consulta as locations em questão
  checkLocations({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/loc/',
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Recupera uma location
  recoverLocation({id}) async {
    var headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/loc/$id');
  }

  /// Deleta permanentemente uma location
  deleteLocation({id}) async {
    var headers = {'Authorization': 'Bearer ${await getAccessToken()}'};

    return send(
        headers: headers,
        customRequest: 'DELETE',
        link: '${api!.baseUrl}/loc/$id/txid');
  }

  /// Checa o status de um Pix através do e2eid
  checkPix({e2eid}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/pix/$e2eid');
  }

  /// Checa uma lista de Pix recebidos através dos e2eid
  checkReceivedPixList({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: api!.baseUrl,
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Solicita reembolso de um Pix
  askRefundPix({e2eid, id, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/pix/$e2eid/devolucao/$id',
        data: request);
  }

  /// Checa status do reembolso de um Pix
  checkRefundPix({e2eid, id}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/pix/$e2eid/devolucao/$id');
  }

  /// Configura um webhook para determinada chave
  setupWebhook({chave, request}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'PUT',
        link: '${api!.baseUrl}/webhook/$chave',
        data: request);
  }

  /// Solicita informações sobre determinado webhook
  infoWebhook({chave}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/webhook/$chave');
  }

  /// Deleta permanentemente um webhook
  deleteWebhook({chave}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
    };

    return send(
        headers: headers,
        customRequest: 'DELETE',
        link: '${api!.baseUrl}/webhook/$chave');
  }

  /// Consulta os dados de uma lista de webhooks
  checkWebhooks({queryParameters}) async {
    var headers = {
      'Authorization': 'Bearer ${await getAccessToken()}',
      'Content-Type': 'application/json'
    };

    return send(
        headers: headers,
        customRequest: 'GET',
        link: '${api!.baseUrl}/webhook/',
        isQuery: true,
        queryParameters: queryParameters);
  }

  /// Método para enviar as informações necessárias à API do seu PSP de preferência
  Future send(
      {headers, customRequest, link, data, isQuery, queryParameters}) async {
    final dio = Dio();
    String url = '$link${isQuery != null ? {
        isQuery ? '/?$queryParameters' : ''
      } : ''}${api!.isBancoDoBrasil! ? '${link.toString().contains('?') ? "&" : "?"}gw-dev-app-key=${api!.appKey}' : ''}';
    Response request = customRequest == 'PUT' ||
            customRequest == 'POST' ||
            customRequest == 'PATCH'
        ? await dio.request(url,
            options: Options(method: '$customRequest', headers: headers),
            data: data)
        : await dio.request(url,
            options: Options(method: '$customRequest', headers: headers));

    if (request.statusCode == 200 ||
        request.statusCode == 201 ||
        request.statusCode == 202 ||
        request.statusCode == 204) {
      print(request.data);
      return request.data;
    } else {
      print(request.statusMessage);
    }

    return {};
  }
}

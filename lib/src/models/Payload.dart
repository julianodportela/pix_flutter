/// Modelo para criar QR Code estático ou dinâmico. Segue informações disponíveis na documentação do API Pix
class Payload {
  String? pixKey;
  String? description;
  String? merchantName;
  String? merchantCity;
  String? txid;
  String? amount;
  String? url;
  bool? isUniquePayment;

  Payload(
      {this.pixKey,
      this.description,
      this.merchantName,
      this.merchantCity,
      this.txid,
      this.amount,
      this.url,
      this.isUniquePayment});
}

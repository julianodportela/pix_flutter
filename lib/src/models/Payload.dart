/// Modelo para criar QR Code estático. Segue informações disponíveis na documentação do API Pix
class Payload {
  String? pixKey;
  String? description;
  String? merchantName;
  String? merchantCity;
  String? txid;
  String? amount;

  Payload({
    this.pixKey,
    this.description,
    this.merchantName,
    this.merchantCity,
    this.txid,
    this.amount,
  });
}

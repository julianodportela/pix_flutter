/// Modelo para criar QR Code dinâmico. Segue informações disponíveis na documentação do API Pix
class Api {
  final String? baseUrl;
  final String? authUrl;
  final String? certificate;
  final String? appKey;
  final String? certificatePath;
  final List? permissions;
  final bool? isBancoDoBrasil;

  Api({
    this.baseUrl,
    this.authUrl,
    this.certificate,
    this.appKey,
    this.certificatePath,
    this.permissions,
    this.isBancoDoBrasil,
  });
}

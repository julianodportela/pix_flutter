/// Classe que facilita o uso das permissões necessárias para o uso da API.
class PixPermissions {
  static String get cobWrite => 'cob.write';
  static String get cobRead => 'cob.read';
  static String get cobVWrite => 'cobv.write';
  static String get cobVRead => 'cobv.read';
  static String get loteCobVWrite => 'lotecobv.write';
  static String get loteCobVRead => 'lotecobv.read';
  static String get pixWrite => 'pix.write';
  static String get pixRead => 'pix.read';
  static String get pixSend => 'pix.send';
  static String get webhookWrite => 'webhook.write';
  static String get webhookRead => 'webhook.read';
  static String get payloadLocationWrite => 'payloadlocation.write';
  static String get payloadLocationRead => 'payloadlocation.read';
  static String get gnPixEvpWrite => 'gn.pix.evp.write';
  static String get gnPixEvpRead => 'gn.pix.evp.read';
  static String get gnBalanceRead => 'gn.balance.read';
  static String get gnSettingsWrite => 'gn.settings.write';
  static String get gnSettingsRead => 'gn.settings.read';
}

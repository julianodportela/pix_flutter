# pix_flutter

[![pub package](https://img.shields.io/pub/v/pix_flutter?color=blue)](https://pub.dev/packages/pix_flutter)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=juliano0365@gmail.com)

Wrapper para usar o API PIX, compatível com a maioria do PSPs. Para mais informações, acesse a documentação do PSP de sua escolha ou a oficial, disponível em: [`documentação`](https://openpix.com.br/api/API-Pix-2-1-0.html).

Este plug-in permite:
- Gerar QR Code Pix estático
- Criar, revisar e consultar cobranças imediatas
- Criar, revisar e consultar cobranças com vencimento
- Criar e consultar cobranças com vencimento em lote
- Criar, consultar, recuperar e desvincular locations para payloads
- Consultar, solicitar devolução e consultar devolução de Pix
- Configurar, consultar e cancelar webhooks

## Como usar o pix_flutter
1. Adicione dependência a `pubspec.yaml`

```dart
dependencies:
    pix_flutter: ^1.0.0
```

2. Importar o pacote
```dart
import 'package:pix_flutter/pix_flutter.dart';
```

### Gerar QR Code Pix Estático

``` dart
PixFlutter pixFlutter = PixFlutter(
      payload: Payload(
          pixKey: 'SUA_CHAVE_PIX',
          description: 'DESCRIÇÃO_DA_COMPRA',
          merchantName: 'MERCHANT_NAME',
          merchantCity: 'CITY_NAME',
          txid: 'TXID',
          amount: 'AMOUNT'
      )
);

pixFlutter.getStaticCode();

```

### Criar, revisar e consultar cobranças imediatas

``` dart

// Criar

var request = {
    "calendario": {
        "expiracao": "36000"
    },
    "devedor": {
        "cpf": "12345678909",
        "nome": "Francisco da Silva"
    },
    "valor": {
        "original": "130.44"
    },
    "chave": "7f6844d0-de89-47e5-9ef7-e0a35a681615",
    "solicitacaoPagador": "Cobrança dos serviços prestados."
};

pixFlutter.createCobTxid(request: request, txid: 'dg7dng876d8g79d8gsmdg8');

// Revisar

var request = {
    "loc": {
        "id": "7768"
    },
    "devedor": {
        "cpf": "12345678909",
        "nome": "Francisco da Silva"
    },
    "valor": {
        "original": "123.45"
    },
    "solicitacaoPagador": "Cobrança dos serviços prestados."
};

pixFlutter.reviewCob(request: request, txid: 'dg7dng876d8g79d8gsmdg8');

// Consultar

pixFlutter.checkCob(txid: 'dg7dng876d8g79d8gsmdg8');

// Consultar Lista

var request = {
    "parametros": {
      "inicio": "2020-04-01T00:00:00Z",
      "fim": "2020-04-02T10:00:00Z",
      "paginação": {
        "paginaAtual": 0,
        "itensPorPagina": 100,
        "quantidadeDePaginas": 1,
        "quantidadeTotalDeItens": 2
      }
    },
    "cobs": [
      {
        "allOf": [
          {
            "ref463464": "#/components/examples/cobResponse1/value"
          }
        ]
      },
      {
        "allOf": [
          {
            "ref4646346": "#/components/examples/cobResponse2/value"
          }
        ]
      }
    ]
};

pixFlutter.checkCobList(request: request);

```

### Criar, revisar e consultar cobranças com vencimento

``` dart

// Criar

var request = {
    "calendario": {
      "dataDeVencimento": "2020-12-31",
      "validadeAposVencimento": 30
    },
    "loc": {
      "id": "789"
    },
    "devedor": {
      "logradouro": "Alameda Souza, Numero 80, Bairro Braz",
      "cidade": "Recife",
      "uf": "PE",
      "cep": "70011750",
      "cpf": "12345678909",
      "nome": "Francisco da Silva"
    },
    "valor": {
      "original": "123.45",
      "multa": {
        "modalidade": "2",
        "valorPerc": "15.00"
      },
      "juros": {
        "modalidade": "2",
        "valorPerc": "2.00"
      },
      "desconto": {
        "modalidade": "1",
        "descontoDataFixa": [
          {
            "data": "2020-11-30",
            "valorPerc": "30.00"
          }
        ]
      }
    },
    "chave": "5f84a4c5-c5cb-4599-9f13-7eb4d419dacc",
    "solicitacaoPagador": "Cobrança dos serviços prestados."
};

pixFlutter.createCobV(request: request, txid: 'dg7dng876d8g79d8gsmdg8');

// Revisar

var request = {
    "loc": {
      "id": "7768"
    },
    "devedor": {
      "cpf": "12345678909",
      "nome": "Francisco da Silva"
    },
    "valor": {
      "original": "123.45"
    },
    "solicitacaoPagador": "Cobrança dos serviços prestados."
};

pixFlutter.reviewCobV(request: request, txid: 'dg7dng876d8g79d8gsmdg8');

// Consultar

pixFlutter.checkCobV(txid: 'dg7dng876d8g79d8gsmdg8');

// Consultar Lista

var request = {
    "parametros": {
      "inicio": "2020-04-01T00:00:00Z",
      "fim": "2020-04-01T23:59:59Z",
      "paginacao": {
        "paginaAtual": 0,
        "itensPorPagina": 100,
        "quantidadeDePaginas": 1,
        "quantidadeTotalDeItens": 1
      }
    },
    "cobs": [
      {
        "allOf": [
          {
            "ref5646464": "#/components/examples/cobResponse4/value"
          }
        ]
      }
    ]
};

pixFlutter.checkCobVList(request: request);

```

### Criar e consultar cobranças com vencimento em lote

``` dart
// Criar

var request = {
    "descricao": "Cobranças dos alunos do turno vespertino",
    "cobsv": [
      {
        "calendario": {
          "dataDeVencimento": "2020-12-31",
          "validadeAposVencimento": 30
        },
        "txid": "fb2761260e554ad593c7226beb5cb650",
        "loc": {
          "id": "789"
        },
        "devedor": {
          "logradouro": "Alameda Souza, Numero 80, Bairro Braz",
          "cidade": "Recife",
          "uf": "PE",
          "cep": "70011750",
          "cpf": "08577095428",
          "nome": "João Souza"
        },
        "valor": {
          "original": "100.00"
        },
        "chave": "7c084cd4-54af-4172-a516-a7d1a12b75cc",
        "solicitacaoPagador": "Informar matrícula"
      },
      {
        "calendario": {
          "dataDeVencimento": "2020-12-31",
          "validadeAposVencimento": 30
        },
        "txid": "7978c0c97ea847e78e8849634473c1f1",
        "loc": {
          "id": "57221"
        },
        "devedor": {
          "logradouro": "Rua 15, Numero 1, Bairro Campo Grande",
          "cidade": "Recife",
          "uf": "PE",
          "cep": "70055751",
          "cpf": "15311295449",
          "nome": "Manoel Silva"
        },
        "valor": {
          "original": "100.00"
        },
        "chave": "7c084cd4-54af-4172-a516-a7d1a12b75cc",
        "solicitacaoPagador": "Informar matrícula"
      }
    ]
};

pixFlutter.createLoteCobV(request: request, id: '');

// Consultar

pixFlutter.checkLoteCobV(id: '');

// Consultar Lista

var request  = {
    "parametros": {
      "inicio": "2020-01-01T00:00:00Z",
      "fim": "2020-12-01T23:59:59Z",
      "paginacao": {
        "paginaAtual": 0,
        "itensPorPagina": 100,
        "quantidadeDePaginas": 1,
        "quantidadeTotalDeItens": 2
      }
    },
    "lotes": [
      {
        "allOf": [
          {
            "ref46436363567": "#/components/examples/loteCobVResponse1/value"
          }
        ]
      },
      {
        "allOf": [
          {
            "ref62463572": "#/components/examples/loteCobVResponse2/value"
          }
        ]
      }
    ]
};

pixFlutter.checkLoteCobVList(request: request, txid: '');

```

- *Observações*
    * Para informações sobre as outras funções do pacote, siga fielmente o modelo apresentado na documentação do API Pix. [`documentação`](https://openpix.com.br/api/API-Pix-2-1-0.html)
    * Este pacote não fará a geração de QR Code, para isto, é recomendado usar o pacote [`qr_flutter`](https://pub.dev/packages/qr_flutter). Para um exemplo com a utilização deste pacote, consulte o aplicativo de exemplo.
    
Consulte o aplicativo de exemplo deste plugin para obter um exemplo completo. Consulte [LICENÇA](./LICENSE) para obter detalhes.
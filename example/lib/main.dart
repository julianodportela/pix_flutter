import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pix Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Exemplo API Pix Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var query;

  PixFlutter pixFlutter = PixFlutter(
      api: Api(
          baseUrl: 'SEU_BASE_URL',
          authUrl: 'SEU_AUTH_URL',
          certificate: 'SEU_CODIGO_BASIC',
          appKey: 'SEU_APP_KEY',
          permissions: [], // Lista das permissoes, use PixPermissions,
          isBancoDoBrasil: false // Use true se estiver usando API do BB,
      ),
      payload: Payload(
          pixKey: 'SUA_CHAVE_PIX',
          description: 'DESCRIÇÃO_DA_COMPRA',
          merchantName: 'MERCHANT_NAME',
          merchantCity: 'CITY_NAME',
          txid: 'TXID',
          amount: 'AMOUNT'
      )
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            query != null ? Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 255,
                  width: 255,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black,
                        width: 5
                    ),
                  ),
                  child: QrImage(
                    data: query['location'],
                    version: QrVersions.auto,
                    size: 250.0,
                  ),
                ),
              ),
            ) : Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 255,
                  width: 255,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.black,
                        width: 5
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Crie uma compra para que o QR apareça aqui',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Cobrança Imediata',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () async {

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

                    query = await pixFlutter.createCobTxid(request: request, txid: '');
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(11.0),
                      child: Center(
                        child: Text(
                          'Criar',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ),
                TextButton(
                    onPressed: () async {

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

                      query = await pixFlutter.reviewCob(request: request, txid: '');
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                            'Revisar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {
                      pixFlutter.checkCob(txid: '');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                            'Consultar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {

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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Consultar lista',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                  'Cobrança com Vencimento',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () async {

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

                      query = await pixFlutter.createCobV(request: request, txid: '');
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.lightGreenAccent,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Criar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () async {

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

                      query = await pixFlutter.reviewCobV(request: request, txid: '');
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Revisar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {
                      pixFlutter.checkCobV(txid: '');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Consultar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {

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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Consultar lista',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                  'Cobrança com Vencimento em Lote',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {

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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.lightGreenAccent,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Criar lote',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {
                      pixFlutter.checkLoteCobV(id: '');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Consultar lote',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                TextButton(
                    onPressed: () {

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
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: Center(
                          child: Text(
                              'Consultar lista de lotes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}

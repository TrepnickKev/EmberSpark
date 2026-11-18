import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ember_spark/services/lnbits_service.dart';

const _offer = 'lno1qgsqvgnwgcg35z6ee2h3yczraddm72xrfua9uve2rlrm9deu7xyfzr';
const _invoice = 'lni1qqgtestinvoice';

void main() {
  late List<http.Request> requests;

  LNbitsService service(
    http.Response Function(http.Request) handler, {
    bool readOnly = false,
  }) {
    requests = [];
    return LNbitsService(
      baseUrl: 'https://lnbits.example',
      adminKey: 'admin',
      readOnly: readOnly,
      client: MockClient((req) async {
        requests.add(req);
        return handler(req);
      }),
    );
  }

  Map<String, dynamic> body(http.Request r) =>
      jsonDecode(r.body) as Map<String, dynamic>;

  test('pays the offer through LNbits core', () async {
    final svc = service((_) => http.Response('{"payment_hash":"x"}', 201));
    await svc.payBolt12Offer(offer: _offer, amountSats: 21, memo: 'thanks');
    expect(requests, hasLength(1));
    expect(requests.single.url.path, '/api/v1/payments');
    expect(body(requests.single), {
      'out': true,
      'payment_request': _offer,
      'amount': 21,
      'unit': 'sat',
      'memo': 'thanks',
    });
  });

  test('falls back to the BOLT12 extension when core rejects the offer',
      () async {
    var coreCalls = 0;
    final svc = service((req) {
      switch (req.url.path) {
        case '/bolt12/api/v1/fetchinvoice':
          return http.Response(jsonEncode({'invoice': _invoice}), 200);
        case '/api/v1/payments':
          coreCalls++;
          return coreCalls == 1
              ? http.Response('{"detail":"invalid bolt11"}', 400)
              : http.Response('{"payment_hash":"y"}', 201);
      }
      return http.Response('', 404);
    });
    await svc.payBolt12Offer(offer: _offer, amountSats: 21);
    expect(requests.map((r) => r.url.path), [
      '/api/v1/payments',
      '/bolt12/api/v1/fetchinvoice',
      '/api/v1/payments',
    ]);
    expect(body(requests.last)['bolt11'], _invoice);
  });

  test('throws the core error when the extension is missing too', () async {
    final svc = service((req) => req.url.path == '/api/v1/payments'
        ? http.Response('{"detail":"BOLT12 not supported"}', 400)
        : http.Response('Not found', 404));
    await expectLater(
      svc.payBolt12Offer(offer: _offer, amountSats: 21),
      throwsA(predicate((e) => e.toString().contains('BOLT12 not supported'))),
    );
  });

  test('does not fall back on a server error', () async {
    final svc = service((_) => http.Response('boom', 500));
    await expectLater(
      svc.payBolt12Offer(offer: _offer, amountSats: 21),
      throwsException,
    );
    expect(requests, hasLength(1));
  });

  test('a read-only wallet cannot pay', () async {
    final svc = service((_) => http.Response('', 201), readOnly: true);
    await expectLater(
      svc.payBolt12Offer(offer: _offer, amountSats: 21),
      throwsA(isA<ReadOnlyWalletException>()),
    );
    expect(requests, isEmpty);
  });
}

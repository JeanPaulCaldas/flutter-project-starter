import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/config/env.dart';
import 'package:flutter_starter/core/network/dio_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClientAdapter extends Mock implements HttpClientAdapter;

void main() {
  test('dio is configured with base url and timeouts', () {
    final container = ProviderContainer.test(retry: (_, _) => null);

    final options = container.read(dioProvider).options;

    expect(options.baseUrl, Env.baseUrl);
    expect(options.connectTimeout, const Duration(seconds: 10));
    expect(options.receiveTimeout, const Duration(seconds: 15));
    expect(options.headers['Accept'], 'application/json');
  });

  test('dio is closed when its container is disposed', () {
    final container = ProviderContainer.test(retry: (_, _) => null);
    final adapter = _MockHttpClientAdapter();
    container.read(dioProvider).httpClientAdapter = adapter;

    container.dispose();

    verify(() => adapter.close(force: any(named: 'force'))).called(1);
  });
}

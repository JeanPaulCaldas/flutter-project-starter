import 'package:flutter_starter/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baseUrl defaults to JSONPlaceholder', () {
    expect(Env.baseUrl, 'https://jsonplaceholder.typicode.com');
  });
}

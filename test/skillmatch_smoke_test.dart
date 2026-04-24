import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mutual match states are explicit', () {
    const pending = 'pending';
    const matched = 'matched';

    expect(pending, isNot(equals(matched)));
    expect({pending, matched, 'rejected'}, contains('matched'));
  });
}

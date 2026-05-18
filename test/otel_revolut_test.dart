// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_revolut/otel_revolut.dart';
import 'package:test/test.dart';

void main() {
  group('otel_revolut', () {
    test('suppression toggles in zone', () async {
      expect(revolutInstrumentationSuppressed(), isFalse);
      await runWithoutRevolutInstrumentationAsync(() async {
        expect(revolutInstrumentationSuppressed(), isTrue);
      });
      expect(revolutInstrumentationSuppressed(), isFalse);
    });

    test('RevolutResult fields default null', () {
      const r = RevolutResult();
      expect(r.statusCode, isNull);
    });
  });
}

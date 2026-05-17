# otel_revolut

Dartastic OpenTelemetry bridge for Revolut Business (multi-currency banking + cards).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_revolut/otel_revolut.dart';

await tracedRevolut<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return RevolutCallResult(value: r, result: RevolutResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutRevolutInstrumentationAsync(() async {
  await client.someInternalSync();
});
```

// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_revolut/otel_revolut.dart';

/// Traces Revolut calls with OpenTelemetry.
///
/// `otel_revolut` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Revolut call in
/// [tracedRevolut]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'revolut-example');

  // Traces a Revolut call.
  final revolutId = await tracedRevolut<String>(
    operation: 'create',
    invoke: () async {
      // Make the Revolut call here, then report what it returned.
      const id = 'revolut_8f3a2c';
      return const RevolutCallResult(
          value: id,
          result: RevolutResult(
              businessId: 'business_8f3a2c',
              counterpartyId: 'counterparty_8f3a2c',
              accountId: 'account_8f3a2c',
              cardId: 'card_8f3a2c',
              transactionId: 'transaction_8f3a2c',
              type: 'standard',
              amount: 0.5,
              currency: 'usd',
              state: 'active',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedRevolut create returned $revolutId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRevolutInstrumentationAsync.
  await runWithoutRevolutInstrumentationAsync(
    () => tracedRevolut<String>(
      operation: 'create',
      invoke: () async {
        const id = 'revolut_8f3a2c';
        return const RevolutCallResult(
            value: id,
            result: RevolutResult(
                businessId: 'business_8f3a2c',
                counterpartyId: 'counterparty_8f3a2c',
                accountId: 'account_8f3a2c',
                cardId: 'card_8f3a2c',
                transactionId: 'transaction_8f3a2c',
                type: 'standard',
                amount: 0.5,
                currency: 'usd',
                state: 'active',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}

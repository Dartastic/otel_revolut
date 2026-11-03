// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_revolut_suppression.dart';

class RevolutResult {
  /// Creates a result.
  const RevolutResult({
    this.businessId,
    this.counterpartyId,
    this.accountId,
    this.cardId,
    this.transactionId,
    this.type,
    this.amount,
    this.currency,
    this.state,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? businessId;
  final String? counterpartyId;
  final String? accountId;
  final String? cardId;
  final String? transactionId;
  final String? type;
  final double? amount;
  final String? currency;
  final String? state;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class RevolutCallResult<T> {
  /// Creates a call result.
  const RevolutCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final RevolutResult? result;
}

Future<T> tracedRevolut<T>({
  required String operation,
  required Future<RevolutCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (revolutInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_revolut');
  final span = t.startSpan('revolut $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'revolut')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.businessId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.business.id', res.businessId!)]));
      }
      if (res.counterpartyId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'revolut.counterparty.id', res.counterpartyId!)
        ]));
      }
      if (res.accountId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.account.id', res.accountId!)]));
      }
      if (res.cardId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.card.id', res.cardId!)]));
      }
      if (res.transactionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('revolut.transaction.id', res.transactionId!)
        ]));
      }
      if (res.type != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.transaction.type', res.type!)]));
      }
      if (res.amount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('revolut.amount', res.amount!)]));
      }
      if (res.currency != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.currency', res.currency!)]));
      }
      if (res.state != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.state', res.state!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('revolut.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              ErrorAttributes.errorType.key, res.errorCode ?? 'revolut.error')
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

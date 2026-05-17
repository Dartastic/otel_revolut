// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_revolut_suppression.dart';

class RevolutResult {
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

class RevolutCallResult<T> {
  const RevolutCallResult({required this.value, this.result});
  final T value;
  final RevolutResult? result;
}

Future<T> tracedRevolut<T>({
  required String operation,
  required Future<RevolutCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (revolutInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_revolut');
  final span = t.startSpan('revolut $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'revolut');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.businessId != null) {
        span.setStringAttribute('revolut.business.id', res.businessId!);
      }
      if (res.counterpartyId != null) {
        span.setStringAttribute('revolut.counterparty.id', res.counterpartyId!);
      }
      if (res.accountId != null) {
        span.setStringAttribute('revolut.account.id', res.accountId!);
      }
      if (res.cardId != null) {
        span.setStringAttribute('revolut.card.id', res.cardId!);
      }
      if (res.transactionId != null) {
        span.setStringAttribute('revolut.transaction.id', res.transactionId!);
      }
      if (res.type != null) {
        span.setStringAttribute('revolut.transaction.type', res.type!);
      }
      if (res.amount != null) {
        span.setDoubleAttribute('revolut.amount', res.amount!);
      }
      if (res.currency != null) {
        span.setStringAttribute('revolut.currency', res.currency!);
      }
      if (res.state != null) {
        span.setStringAttribute('revolut.state', res.state!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('revolut.error.code', res.errorCode!);
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
            ErrorResource.errorType.key, res.errorCode ?? 'revolut.error');
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

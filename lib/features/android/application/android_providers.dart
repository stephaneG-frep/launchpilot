import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/android_reader.dart';
import '../domain/deliverables.dart';

final androidReaderProvider = Provider<AndroidReader>(
  (ref) => const AndroidReader(),
);

/// Inspection des livrables : dans un isolat en temps normal (fichiers de
/// plusieurs dizaines de Mo), remplacée par un appel direct dans les tests.
typedef DeliverableInspector = Future<List<Deliverable>> Function(
  DeliverableJob job,
);

final deliverableInspectorProvider = Provider<DeliverableInspector>(
  (ref) =>
      (job) => Isolate.run(() => inspectDeliverables(job)),
);

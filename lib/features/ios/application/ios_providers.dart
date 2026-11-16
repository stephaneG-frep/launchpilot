import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/ios_reader.dart';
import '../domain/app_store.dart';

final iosReaderProvider = Provider<IosReader>((ref) => const IosReader());

/// Système hôte : un build iOS local n'est possible que sur macOS.
final hostIsLinuxProvider = Provider<bool>((ref) => Platform.isLinux);

final iosConfigRepositoryProvider = Provider<IosConfigRepository>(
  (ref) => IosConfigRepository(ref.watch(sharedPreferencesProvider)),
);

final iosConfigProvider = NotifierProvider<IosConfigController, IosConfig>(
  IosConfigController.new,
);

class IosConfigController extends Notifier<IosConfig> {
  @override
  IosConfig build() {
    final id = ref.watch(currentProjectIdProvider);
    return id == null
        ? const IosConfig()
        : ref.read(iosConfigRepositoryProvider).load(id);
  }

  Future<void> update(IosConfig next) async {
    final id = ref.read(currentProjectIdProvider);
    if (id == null || next == state) return;
    state = next;
    await ref.read(iosConfigRepositoryProvider).save(id, next);
  }
}

import 'dart:isolate';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../commands/application/command_providers.dart';
import '../../projects/application/project_providers.dart';
import '../data/changelog_service.dart';
import '../data/content_repository.dart';
import '../domain/icons.dart';

@immutable
class PickedImage {
  const PickedImage(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

/// Sélection d'images sur le disque, remplaçable dans les tests.
abstract interface class ImagePicker {
  Future<PickedImage?> pickOne();
  Future<List<PickedImage>> pickMany();
}

class NativeImagePicker implements ImagePicker {
  const NativeImagePicker();

  static const _images = fs.XTypeGroup(
    label: 'Images',
    extensions: ['png', 'jpg', 'jpeg', 'webp'],
  );

  @override
  Future<PickedImage?> pickOne() async {
    final file = await fs.openFile(acceptedTypeGroups: const [_images]);
    if (file == null) return null;
    return PickedImage(file.name, await file.readAsBytes());
  }

  @override
  Future<List<PickedImage>> pickMany() async {
    final files = await fs.openFiles(acceptedTypeGroups: const [_images]);
    return [for (final f in files) PickedImage(f.name, await f.readAsBytes())];
  }
}

final imagePickerProvider = Provider<ImagePicker>(
  (ref) => const NativeImagePicker(),
);

/// Génération d'icônes : dans un isolat en temps normal, remplacée par un
/// appel direct dans les tests de widgets.
typedef IconGenerator = Future<Map<String, Uint8List>> Function(IconJob job);

final iconGeneratorProvider = Provider<IconGenerator>(
  (ref) =>
      (job) => Isolate.run(() => runIconJob(job)),
);

final changelogServiceProvider = Provider<ChangelogService>(
  (ref) => ChangelogService(ref.watch(commandRunnerProvider)),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(appDatabaseProvider)),
);

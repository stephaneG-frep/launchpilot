import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/application/content_providers.dart';
import '../../projects/application/project_providers.dart';
import '../domain/chat.dart';

/// Clé de l'historique du chat dans la session.
const chatHistoryKey = 'chat.history';

/// Conversation de la session active. Enregistrée dans la session (sans
/// session : gardée en mémoire jusqu'à la fermeture).
final chatControllerProvider =
    NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);

class ChatController extends Notifier<List<ChatMessage>> {
  int? get _sessionId => ref.read(
    currentWorkspaceProvider.select((ws) => ws.value?.activeSession?.id),
  );

  @override
  List<ChatMessage> build() {
    final sessionId = ref.watch(
      currentWorkspaceProvider.select((ws) => ws.value?.activeSession?.id),
    );
    if (sessionId != null) _load(sessionId);
    return const [];
  }

  Future<void> _load(int sessionId) async {
    final saved = await ref
        .read(contentRepositoryProvider)
        .latestJson(sessionId, chatHistoryKey);
    if (!ref.mounted || saved is! List || _sessionId != sessionId) return;
    state = [
      for (final m in saved)
        if (m is Map) ChatMessage.fromJson(m.cast()),
    ];
  }

  Future<void> add(ChatMessage message) async {
    final next = [...state, message];
    state = next.length > ChatPrompt.keptMessages
        ? next.sublist(next.length - ChatPrompt.keptMessages)
        : next;
    await _save();
  }

  Future<void> clear() async {
    state = const [];
    await _save();
  }

  Future<void> _save() async {
    final id = _sessionId;
    if (id == null) return;
    await ref.read(contentRepositoryProvider).saveJson(id, chatHistoryKey, [
      for (final m in state) m.toJson(),
    ]);
  }
}

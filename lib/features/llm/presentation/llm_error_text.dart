import '../../../l10n/app_localizations.dart';
import '../domain/llm_types.dart';

extension LlmErrorText on LlmErrorKind {
  String message(AppLocalizations l10n) => switch (this) {
    LlmErrorKind.missingKey => l10n.llmErrMissingKey,
    LlmErrorKind.invalidKey => l10n.llmErrInvalidKey,
    LlmErrorKind.permissionDenied => l10n.llmErrPermission,
    LlmErrorKind.billing => l10n.llmErrBilling,
    LlmErrorKind.modelNotFound => l10n.llmErrModelNotFound,
    LlmErrorKind.badRequest => l10n.llmErrBadRequest,
    LlmErrorKind.requestTooLarge => l10n.llmErrTooLarge,
    LlmErrorKind.rateLimited => l10n.llmErrRateLimited,
    LlmErrorKind.overloaded => l10n.llmErrOverloaded,
    LlmErrorKind.serverError => l10n.llmErrServer,
    LlmErrorKind.timeout => l10n.llmErrTimeout,
    LlmErrorKind.cancelled => l10n.llmErrCancelled,
    LlmErrorKind.network => l10n.llmErrNetwork,
    LlmErrorKind.invalidResponse => l10n.llmErrInvalidResponse,
    LlmErrorKind.refused => l10n.llmErrRefused,
    LlmErrorKind.truncated => l10n.llmErrTruncated,
    LlmErrorKind.keyringUnavailable => l10n.apiKeyStorageError,
  };
}

/// Message principal et détail technique (déjà nettoyé) d'une erreur.
(String, String?) describeLlmError(AppLocalizations l10n, LlmException e) => (
  e.kind.message(l10n),
  e.detail == null ? null : l10n.llmErrDetail(e.detail!),
);

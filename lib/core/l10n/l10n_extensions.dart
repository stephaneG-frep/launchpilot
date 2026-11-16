import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../domain/action_level.dart';
import '../domain/explanation_level.dart';
import '../domain/step_status.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String formatDate(DateTime date) {
    final locale = Localizations.localeOf(this).toLanguageTag();
    return DateFormat.yMMMMd(locale).add_Hm().format(date);
  }
}

extension StepStatusL10n on StepStatus {
  String label(AppLocalizations l10n) => switch (this) {
    StepStatus.todo => l10n.statusTodo,
    StepStatus.running => l10n.statusRunning,
    StepStatus.succeeded => l10n.statusSucceeded,
    StepStatus.failed => l10n.statusFailed,
    StepStatus.needsValidation => l10n.statusNeedsValidation,
    StepStatus.pedagogical => l10n.statusPedagogical,
  };
}

extension ActionLevelL10n on ActionLevel {
  String label(AppLocalizations l10n) => switch (this) {
    ActionLevel.analyze => l10n.levelAnalyze,
    ActionLevel.prepare => l10n.levelPrepare,
    ActionLevel.build => l10n.levelBuild,
    ActionLevel.publish => l10n.levelPublish,
  };

  String description(AppLocalizations l10n) => switch (this) {
    ActionLevel.analyze => l10n.levelAnalyzeDesc,
    ActionLevel.prepare => l10n.levelPrepareDesc,
    ActionLevel.build => l10n.levelBuildDesc,
    ActionLevel.publish => l10n.levelPublishDesc,
  };
}

extension ExplanationLevelL10n on ExplanationLevel {
  String label(AppLocalizations l10n) => switch (this) {
    ExplanationLevel.beginner => l10n.modeBeginner,
    ExplanationLevel.guided => l10n.modeGuided,
    ExplanationLevel.expert => l10n.modeExpert,
  };

  String description(AppLocalizations l10n) => switch (this) {
    ExplanationLevel.beginner => l10n.modeBeginnerDesc,
    ExplanationLevel.guided => l10n.modeGuidedDesc,
    ExplanationLevel.expert => l10n.modeExpertDesc,
  };
}

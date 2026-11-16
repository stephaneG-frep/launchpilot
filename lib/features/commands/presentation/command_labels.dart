import 'package:flutter/material.dart';

import '../../../core/theme/launch_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/command_result.dart';
import '../domain/command_spec.dart';

extension RiskLevelUi on RiskLevel {
  String label(AppLocalizations l10n) => switch (this) {
    RiskLevel.readOnly => l10n.riskReadOnly,
    RiskLevel.local => l10n.riskLocal,
    RiskLevel.sensitive => l10n.riskSensitive,
    RiskLevel.forbidden => l10n.riskForbidden,
  };

  String description(AppLocalizations l10n) => switch (this) {
    RiskLevel.readOnly => l10n.riskReadOnlyDesc,
    RiskLevel.local => l10n.riskLocalDesc,
    RiskLevel.sensitive => l10n.riskSensitiveDesc,
    RiskLevel.forbidden => l10n.riskForbiddenDesc,
  };

  Color color(BuildContext context) {
    final p = LaunchPalette.of(context);
    return switch (this) {
      RiskLevel.readOnly => p.statusSucceeded,
      RiskLevel.local => p.statusRunning,
      RiskLevel.sensitive => p.statusWarning,
      RiskLevel.forbidden => p.statusFailed,
    };
  }

  IconData get icon => switch (this) {
    RiskLevel.readOnly => Icons.visibility_outlined,
    RiskLevel.local => Icons.build_outlined,
    RiskLevel.sensitive => Icons.edit_note,
    RiskLevel.forbidden => Icons.block,
  };
}

extension PolicyIssueUi on PolicyIssue {
  String text(AppLocalizations l10n) => switch (this) {
    PolicyIssue.notAllowlisted => l10n.issueNotAllowlisted,
    PolicyIssue.shell => l10n.issueShell,
    PolicyIssue.privileged => l10n.issuePrivileged,
    PolicyIssue.invalidExecutable => l10n.issueInvalidExecutable,
    PolicyIssue.invalidArgument => l10n.issueInvalidArgument,
    PolicyIssue.outsideProject => l10n.issueOutsideProject,
    PolicyIssue.workingDirectoryOutside => l10n.issueWorkingDirectoryOutside,
    PolicyIssue.publication => l10n.issuePublication,
    PolicyIssue.gitPush => l10n.issueGitPush,
    PolicyIssue.destructive => l10n.issueDestructive,
    PolicyIssue.systemChange => l10n.issueSystemChange,
    PolicyIssue.globalInstall => l10n.issueGlobalInstall,
    PolicyIssue.remoteCode => l10n.issueRemoteCode,
    PolicyIssue.unknownSubcommand => l10n.issueUnknownSubcommand,
    PolicyIssue.runsProjectScript => l10n.issueRunsProjectScript,
    PolicyIssue.createsTag => l10n.issueCreatesTag,
    PolicyIssue.productionDeploy => l10n.issueProductionDeploy,
    PolicyIssue.previewDeploy => l10n.issuePreviewDeploy,
    PolicyIssue.network => l10n.issueNetwork,
    PolicyIssue.storePublication => l10n.issueStorePublication,
  };
}

extension RunStatusUi on RunStatus {
  String label(AppLocalizations l10n) => switch (this) {
    RunStatus.succeeded => l10n.runSucceeded,
    RunStatus.failed => l10n.runFailed,
    RunStatus.cancelled => l10n.runCancelled,
    RunStatus.timedOut => l10n.runTimedOut,
    RunStatus.blocked => l10n.runBlocked,
    RunStatus.simulated => l10n.runSimulated,
    RunStatus.startFailed => l10n.runStartFailed,
  };

  Color color(BuildContext context) {
    final p = LaunchPalette.of(context);
    return switch (this) {
      RunStatus.succeeded => p.statusSucceeded,
      RunStatus.simulated => p.statusPedagogy,
      RunStatus.cancelled || RunStatus.timedOut => p.statusWarning,
      _ => p.statusFailed,
    };
  }
}

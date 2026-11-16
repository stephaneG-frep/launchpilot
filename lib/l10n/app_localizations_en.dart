// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LaunchPilot';

  @override
  String get appTagline => 'Prepare, check, build, publish.';

  @override
  String get navGroupProject => 'Project';

  @override
  String get navGroupTools => 'Tools';

  @override
  String get navGroupApp => 'Application';

  @override
  String get navHome => 'Home';

  @override
  String get navDetection => 'Detection';

  @override
  String get navPublication => 'Publishing';

  @override
  String get navChecklist => 'Checklist';

  @override
  String get navTerminal => 'Terminal';

  @override
  String get navAgent => 'Agent';

  @override
  String get navContent => 'Content';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help';

  @override
  String get navOpenMenu => 'Open navigation menu';

  @override
  String navShortcutTooltip(String label, String key) {
    return '$label (Ctrl+$key)';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get demoTag => 'DEMO';

  @override
  String get demoBannerTitle => 'Demo mode';

  @override
  String get demoBannerMessage =>
      'Fictional data, clearly labelled. No real project is read or modified.';

  @override
  String get demoBannerExit => 'Leave demo mode';

  @override
  String laterPhaseTooltip(int phase) {
    return 'Available in a later phase (phase $phase)';
  }

  @override
  String phaseBadge(int phase) {
    return 'Phase $phase';
  }

  @override
  String percentValue(int percent) {
    return '$percent%';
  }

  @override
  String get levelAnalyze => 'Analyze';

  @override
  String get levelAnalyzeDesc => 'Read-only. No file is modified.';

  @override
  String get levelPrepare => 'Prepare';

  @override
  String get levelPrepareDesc =>
      'Generates texts and configuration, with a preview before any write.';

  @override
  String get levelBuild => 'Build';

  @override
  String get levelBuildDesc =>
      'Compiles the project and creates the deliverables.';

  @override
  String get levelPublish => 'Publish';

  @override
  String get levelPublishDesc =>
      'Sends to a store or host, only after explicit confirmation.';

  @override
  String get statusTodo => 'To do';

  @override
  String get statusRunning => 'Running';

  @override
  String get statusSucceeded => 'Succeeded';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusNeedsValidation => 'Needs validation';

  @override
  String get statusPedagogical => 'Learning step';

  @override
  String get homeTitle => 'Welcome to LaunchPilot';

  @override
  String get homeSubtitle =>
      'Open a project to analyze it, prepare its release and understand every step.';

  @override
  String get homeOpenProject => 'Open a project folder';

  @override
  String get homeOpenProjectHint =>
      'Choose your project folder. Analysis then runs when you ask, read-only.';

  @override
  String get homeRecentTitle => 'Recent projects';

  @override
  String get homeRecentEmptyTitle => 'No project yet';

  @override
  String get homeRecentEmptyMessage =>
      'Opened projects will appear here with their progress, favorites and last opening date.';

  @override
  String get homeResumeTitle => 'Resume a session';

  @override
  String get homeResumeEmptyTitle => 'No session in progress';

  @override
  String get homeResumeEmptyMessage =>
      'Each release preparation creates a session you can resume later.';

  @override
  String get homeResumeAction => 'Resume';

  @override
  String get homeFavorite => 'Favorite';

  @override
  String homeLastOpened(String date) {
    return 'Opened on $date';
  }

  @override
  String homeSessionStarted(String date) {
    return 'Session started on $date';
  }

  @override
  String homeCurrentLevel(String level) {
    return 'Current level: $level';
  }

  @override
  String get homeHowTitle => 'How LaunchPilot works';

  @override
  String get homeTryDemo => 'Try demo mode';

  @override
  String get homeDemoHint =>
      'Explore the interface with a fictional project, without reading or changing anything on your disk.';

  @override
  String get detectionTitle => 'Detection report';

  @override
  String get detectionSubtitle =>
      'Technologies, targets, evidence and confidence level.';

  @override
  String get detectionEmptyMessage =>
      'Once a folder is opened, LaunchPilot will list here what it recognized and why. You will be able to confirm or correct the targets.';

  @override
  String get detectionTechnologies => 'Detected technologies';

  @override
  String detectionConfidence(int percent) {
    return 'Confidence: $percent%';
  }

  @override
  String get detectionEvidence => 'Evidence';

  @override
  String get detectionTargets => 'Publishing targets';

  @override
  String get detectionTargetDetected => 'Detected';

  @override
  String get detectionTargetNotDetected => 'Not detected';

  @override
  String get detectionRescan => 'Analyze again';

  @override
  String get publicationTitle => 'Publishing board';

  @override
  String get publicationSubtitle =>
      'Four separate levels. You can stop after any of them.';

  @override
  String get publicationGlobalProgress => 'Overall progress';

  @override
  String get publicationNeverAuto =>
      'Publishing is never triggered automatically after a build.';

  @override
  String publicationStepsDone(int done, int total) {
    return '$done / $total steps';
  }

  @override
  String get checklistTitle => 'Learning checklist';

  @override
  String get checklistSubtitle =>
      'Each step explains its goal, its risks and how to verify it.';

  @override
  String get checklistEmptyMessage =>
      'The checklist will be built from your project\'s confirmed targets.';

  @override
  String get checklistLevelLabel => 'Explanation level';

  @override
  String get checklistExplanation => 'Explanation';

  @override
  String get checklistWhy => 'Why it is required';

  @override
  String get checklistFiles => 'Affected files';

  @override
  String get checklistCommands => 'Commands';

  @override
  String get checklistExpected => 'Expected result';

  @override
  String get checklistRisks => 'Risks';

  @override
  String get checklistVerification => 'How to verify';

  @override
  String get checklistRollback => 'How to roll back';

  @override
  String get checklistNoRollback => 'No automatic rollback is possible.';

  @override
  String get checklistShowVerify => 'Show me how to verify';

  @override
  String get checklistHideVerify => 'Hide verification';

  @override
  String get checklistRequiresConfirmation => 'Confirmation required';

  @override
  String get checklistIrreversible => 'Irreversible';

  @override
  String get checklistRun => 'Run step';

  @override
  String get checklistShowDetails => 'Show details';

  @override
  String get checklistHideDetails => 'Hide details';

  @override
  String get terminalTitle => 'Built-in terminal';

  @override
  String get terminalSubtitle => 'Live command output, with secrets masked.';

  @override
  String get terminalEmptyMessage =>
      'Approved commands will stream here. Every command is previewed before it runs.';

  @override
  String get terminalFilterAll => 'All';

  @override
  String get terminalFilterStdout => 'stdout';

  @override
  String get terminalFilterStderr => 'stderr';

  @override
  String get terminalCopy => 'Copy output';

  @override
  String get terminalCopied => 'Output copied to clipboard.';

  @override
  String get terminalStop => 'Stop';

  @override
  String get terminalSimulated => 'Simulated output';

  @override
  String terminalExitCode(int code) {
    return 'Exit code: $code';
  }

  @override
  String get agentTitle => 'LaunchPilot agent';

  @override
  String get agentSubtitle =>
      'Ask questions, get a step rephrased or ask for contextual help.';

  @override
  String get agentComposerHint => 'Type your question…';

  @override
  String get agentSend => 'Send';

  @override
  String get agentYou => 'You';

  @override
  String get agentAssistant => 'Agent';

  @override
  String get contentTitle => 'Content and previews';

  @override
  String get contentSubtitle =>
      'Store texts, icons, screenshots and SEO previews.';

  @override
  String get contentTexts => 'Listing texts';

  @override
  String get contentIcons => 'Icons';

  @override
  String get contentScreenshots => 'Screenshots';

  @override
  String get contentPreview => 'Listing preview';

  @override
  String get contentIconsEmpty =>
      'Import a source icon (1024 × 1024 minimum) to generate Android, iOS, favicon and PWA sizes without distortion.';

  @override
  String get contentScreenshotsEmpty =>
      'Import your screenshots to check their dimensions and choose a presentation frame.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldSubtitle => 'Subtitle';

  @override
  String get fieldShortDescription => 'Short description';

  @override
  String get fieldKeywords => 'Keywords';

  @override
  String get reportsTitle => 'Reports and history';

  @override
  String get reportsSubtitle => 'Past sessions and HTML/PDF exports.';

  @override
  String get reportsEmptyTitle => 'No report';

  @override
  String get reportsEmptyMessage =>
      'Start a release session on a project: its report (deliverables, commands, audits, remaining actions) can then be exported here.';

  @override
  String get reportsExport => 'Export as HTML';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Appearance, language, guidance and AI providers.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get settingsAnimations => 'Animations';

  @override
  String get settingsAnimationsHint =>
      'Short, subtle transitions. Turn them off if they bother you.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsGuidance => 'Guidance mode';

  @override
  String get modeBeginner => 'Beginner';

  @override
  String get modeBeginnerDesc =>
      'Detailed explanations, defined vocabulary, commented commands and frequent checks.';

  @override
  String get modeGuided => 'Guided';

  @override
  String get modeGuidedDesc =>
      'Condensed explanations, grouped actions and confirmation of important changes.';

  @override
  String get modeExpert => 'Expert';

  @override
  String get modeExpertDesc =>
      'Denser interface and grouped actions. Safety confirmations remain mandatory.';

  @override
  String get settingsAi => 'Artificial intelligence';

  @override
  String get settingsAiProvider => 'Preferred provider';

  @override
  String get settingsApiKeys => 'API keys';

  @override
  String get settingsApiKeysHint =>
      'Keys are stored in the system keyring (libsecret), never in plain text in a file. They are never shown again.';

  @override
  String get apiKeyStored => 'Key stored';

  @override
  String get apiKeyMissing => 'No key';

  @override
  String apiKeyFieldLabel(String provider) {
    return '$provider API key';
  }

  @override
  String apiKeyFieldReplaceLabel(String provider) {
    return 'New $provider API key';
  }

  @override
  String get apiKeySave => 'Save';

  @override
  String get apiKeyReplace => 'Replace';

  @override
  String apiKeySaved(String provider) {
    return '$provider key saved to the keyring.';
  }

  @override
  String apiKeyDeleted(String provider) {
    return '$provider key deleted.';
  }

  @override
  String apiKeyDeleteTitle(String provider) {
    return 'Delete the $provider key?';
  }

  @override
  String get apiKeyDeleteMessage =>
      'The key will be erased from the system keyring. You will have to enter it again to use this provider.';

  @override
  String get apiKeyErrorEmpty => 'Enter a key before saving.';

  @override
  String get apiKeyErrorTooShort => 'This key looks too short.';

  @override
  String get apiKeyErrorTooLong => 'This key is too long.';

  @override
  String get apiKeyErrorInvalidChars =>
      'A key contains no spaces or invisible characters.';

  @override
  String get apiKeyStorageError =>
      'The system keyring is locked or unavailable: LaunchPilot cannot read the keys. Unlock it (\"Passwords and Keys\" app, or by logging in again), or check that gnome-keyring is running, then try again.';

  @override
  String apiKeyWhereToGet(String url) {
    return 'Get a key: $url';
  }

  @override
  String get settingsHosting => 'Preferred hosts';

  @override
  String get settingsHostingHint =>
      'The host chosen here is suggested by default for each new site; you can change it per project in Content → Hosting.';

  @override
  String get settingsDemo => 'Demo mode';

  @override
  String get settingsDemoHint =>
      'Shows a fictional project to discover the interface. Demo data is always labelled.';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyText =>
      'LaunchPilot runs locally. No account or remote service is required to open the application.';

  @override
  String get helpTitle => 'Help and glossary';

  @override
  String get helpSubtitle =>
      'User guide, keyboard shortcuts and technical vocabulary.';

  @override
  String get helpGuideTitle => 'User guide';

  @override
  String get helpGuideStep1 => 'Open your project folder from the home screen.';

  @override
  String get helpGuideStep2 =>
      'Check the detection report and confirm the targets.';

  @override
  String get helpGuideStep3 =>
      'Follow the checklist level by level: Analyze, Prepare, Build, Publish.';

  @override
  String get helpGuideStep4 =>
      'Approve each sensitive action after reading its summary.';

  @override
  String get helpGuideStep5 => 'Export the final report to keep a record.';

  @override
  String get helpGuideNote =>
      'LaunchPilot 1.0.0 covers the whole journey: projects and sessions, detection, checklist, safe commands, content, web, Android, iOS via CI, chat with the agent and reports. Every write goes through a preview, every publication through a reinforced confirmation.';

  @override
  String get helpShortcutsTitle => 'Keyboard shortcuts';

  @override
  String get helpShortcutNav => 'Go directly to a navigation screen';

  @override
  String get helpShortcutTab => 'Move between elements';

  @override
  String get helpShortcutActivate => 'Activate the focused element';

  @override
  String get helpGlossaryTitle => 'Glossary';

  @override
  String get helpGlossarySearch => 'Search a term';

  @override
  String get helpGlossaryNoResult => 'No term matches your search.';

  @override
  String get helpKeysTab => 'Tab / Shift+Tab';

  @override
  String get helpKeysActivate => 'Enter / Space';

  @override
  String get homeFilterAll => 'All';

  @override
  String get homeFilterFavorites => 'Favorites';

  @override
  String get homeFavoritesEmpty =>
      'No favorites. Click a project\'s star to find it here.';

  @override
  String get homeAddFavorite => 'Add to favorites';

  @override
  String get homeRemoveFavorite => 'Remove from favorites';

  @override
  String get homeOpen => 'Open';

  @override
  String get homeProjectMenu => 'Project actions';

  @override
  String get homeNewSession => 'New session';

  @override
  String get homeRelocate => 'Relocate';

  @override
  String get homeRemove => 'Remove from list';

  @override
  String get homeFolderMissing => 'Folder not found';

  @override
  String get homeFolderMissingHint =>
      'The folder may have been moved or deleted. Relocate it or remove the project from the list.';

  @override
  String homeSessionActive(String version) {
    return 'Session $version in progress';
  }

  @override
  String get homeLoadError => 'Unable to read local data.';

  @override
  String homeResumeSince(String date) {
    return 'Last activity on $date';
  }

  @override
  String get addProjectTitle => 'Add a project';

  @override
  String get addProjectPathLabel => 'Folder path';

  @override
  String get addProjectPathHint => '~/projects/my-app';

  @override
  String get addProjectNameLabel => 'Display name (optional)';

  @override
  String get addProjectPickerNote =>
      'Paste the folder\'s full path, or use the Browse button.';

  @override
  String get addProjectConfirm => 'Add';

  @override
  String get pathErrorEmpty => 'Enter a path.';

  @override
  String get pathErrorNotAbsolute => 'Enter a full path, starting with / or ~.';

  @override
  String get pathErrorNotFound =>
      'This folder does not exist or is not accessible.';

  @override
  String get pathErrorAlreadyRegistered =>
      'This folder is already used by another project.';

  @override
  String projectAdded(String name) {
    return 'Project \"$name\" added.';
  }

  @override
  String projectAlreadyKnown(String name) {
    return '\"$name\" was already in the list: it has been reopened.';
  }

  @override
  String relocateTitle(String name) {
    return 'Relocate \"$name\"';
  }

  @override
  String relocateOldPath(String path) {
    return 'Previous path: $path';
  }

  @override
  String get relocateConfirm => 'Relocate';

  @override
  String get projectRelocated => 'New path saved.';

  @override
  String removeProjectTitle(String name) {
    return 'Remove \"$name\" from LaunchPilot?';
  }

  @override
  String removeProjectMessage(int sessions, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessions',
      one: '1 session',
      zero: 'no session',
    );
    String _temp1 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps checklist steps',
      one: '1 checklist step',
      zero: 'no checklist step',
    );
    return 'Its local history will be erased: $_temp0 and $_temp1. Your project files are not touched.';
  }

  @override
  String get removeProjectConfirm => 'Remove';

  @override
  String get projectRemoved => 'Project removed from the list.';

  @override
  String newSessionTitle(String name) {
    return 'New session for \"$name\"';
  }

  @override
  String get newSessionVersionLabel => 'Version being prepared';

  @override
  String get newSessionVersionHint => '1.3.0+14';

  @override
  String get newSessionHint =>
      'A session groups the preparation of one release: checklist, approved texts and reports. You can resume it later.';

  @override
  String get newSessionConfirm => 'Start';

  @override
  String get versionErrorEmpty => 'Enter the version being prepared.';

  @override
  String get versionErrorInvalid =>
      'Digits, letters, dots, dashes, + and _ only, no spaces (64 characters maximum).';

  @override
  String get sessionErrorActiveExists =>
      'A session is already in progress for this project. Resume or close it first.';

  @override
  String sessionStarted(String version) {
    return 'Session $version started.';
  }

  @override
  String get closeSession => 'Close session';

  @override
  String closeSessionTitle(String version) {
    return 'Close session $version?';
  }

  @override
  String get closeSessionMessage =>
      'The session will be marked as finished and can no longer be resumed. Its history is kept.';

  @override
  String get closeSessionConfirm => 'Close';

  @override
  String get sessionClosed => 'Session closed.';

  @override
  String get publicationNoProjectTitle => 'No project open';

  @override
  String get publicationNoProjectMessage =>
      'Open or add a project from the home screen to prepare its release.';

  @override
  String get publicationGoHome => 'Go to home';

  @override
  String get publicationNoSessionTitle =>
      'No session in progress for this project';

  @override
  String get publicationNoSessionMessage =>
      'Start a session to prepare a new release.';

  @override
  String get settingsLocalData => 'Local data';

  @override
  String get settingsLocalDataHint =>
      'Projects, sessions and checklists are stored in an SQLite database on this computer. No API key is stored there.';

  @override
  String settingsLocalDataLocation(String path) {
    return 'Location: $path';
  }

  @override
  String get statProjects => 'Projects';

  @override
  String get statSessions => 'Sessions';

  @override
  String get statSteps => 'Checklist steps';

  @override
  String get settingsClearData => 'Erase all local data';

  @override
  String get clearDataTitle => 'Erase all local data?';

  @override
  String get clearDataMessage =>
      'All projects, sessions, checklists and reports saved by LaunchPilot will be deleted from this computer. Your project files and API keys are not touched. This cannot be undone.';

  @override
  String clearDataTypeWord(String word) {
    return 'To confirm, type $word';
  }

  @override
  String get clearDataWord => 'ERASE';

  @override
  String get clearDataConfirm => 'Erase everything';

  @override
  String get clearDataDone => 'Local data erased.';

  @override
  String get llmErrMissingKey => 'No API key saved for this provider.';

  @override
  String get llmErrInvalidKey =>
      'API key rejected by the provider. Check or replace it.';

  @override
  String get llmErrPermission => 'This key has no access to this resource.';

  @override
  String get llmErrBilling =>
      'Billing or quota problem on the provider account.';

  @override
  String get llmErrModelNotFound =>
      'Model not found or not available for this account.';

  @override
  String get llmErrBadRequest =>
      'Request rejected by the provider (invalid parameters).';

  @override
  String get llmErrTooLarge => 'Content too large for this provider.';

  @override
  String get llmErrRateLimited => 'Too many requests: try again in a moment.';

  @override
  String get llmErrOverloaded =>
      'Provider service overloaded: try again in a moment.';

  @override
  String get llmErrServer => 'Temporary error at the provider.';

  @override
  String get llmErrTimeout => 'No response within the time limit.';

  @override
  String get llmErrCancelled => 'Request cancelled.';

  @override
  String get llmErrNetwork => 'Cannot connect: check your Internet access.';

  @override
  String get llmErrInvalidResponse =>
      'Unusable response: it does not match the expected format.';

  @override
  String get llmErrRefused => 'The model declined to answer this request.';

  @override
  String get llmErrTruncated =>
      'Incomplete response: the length limit was reached.';

  @override
  String get llmErrConsent =>
      'Sending blocked: the confirmation does not match this content or was already used.';

  @override
  String llmErrDetail(String detail) {
    return 'Technical detail: $detail';
  }

  @override
  String get llmModelLabel => 'Model';

  @override
  String llmModelDefault(String model) {
    return 'Default: $model';
  }

  @override
  String get llmChooseModel => 'Choose from available models';

  @override
  String get llmTest => 'Test connection';

  @override
  String get llmTestCancel => 'Cancel test';

  @override
  String llmTestOk(int ms, int count) {
    return 'Connected in $ms ms · $count models available';
  }

  @override
  String llmTestModelOk(String model) {
    return 'Model \"$model\" is available.';
  }

  @override
  String llmTestModelMissing(String model) {
    return 'Model \"$model\" is not in this account\'s list.';
  }

  @override
  String get settingsAiNetworkPolicy =>
      'LaunchPilot only contacts a provider when you ask. The connection test lists models without using tokens.';

  @override
  String get llmTrialTitle => 'Generation trial';

  @override
  String get llmTrialHint =>
      'Sends a fixed question, with no project data, to the preferred provider to check the structured response. This trial uses a few tokens.';

  @override
  String get llmTrialButton => 'Run a trial';

  @override
  String llmTrialNeedsKey(String provider) {
    return 'Save a key for $provider first.';
  }

  @override
  String get llmTrialPrompt =>
      'Explain in two sentences, to a beginner, what a build number is in a mobile app, then list three related technical terms.';

  @override
  String get llmTrialLanguage => 'English';

  @override
  String get llmTrialAnswer => 'Answer';

  @override
  String get llmTrialTerms => 'Related terms';

  @override
  String sendTitle(String provider) {
    return 'Send to $provider?';
  }

  @override
  String sendModel(String model) {
    return 'Model: $model';
  }

  @override
  String sendSize(int tokens) {
    return 'About $tokens input tokens (estimate)';
  }

  @override
  String sendRedactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secrets masked before sending',
      one: '1 secret masked before sending',
      zero: 'No secret detected',
    );
    return '$_temp0';
  }

  @override
  String sendExcluded(String files) {
    return 'Sensitive files excluded: $files';
  }

  @override
  String get sendNoProjectData => 'No data from your project is included.';

  @override
  String get sendProjectData =>
      'Excerpts from your project are included: review the preview.';

  @override
  String get sendShowPreview => 'See exactly what will be sent';

  @override
  String get sendHidePreview => 'Hide preview';

  @override
  String get sendSystemLabel => 'Instructions';

  @override
  String get sendUserLabel => 'Content';

  @override
  String get sendConsentNote =>
      'This confirmation only applies to this exact sending.';

  @override
  String get sendConfirm => 'Send';

  @override
  String get sendInProgress => 'Request in progress…';

  @override
  String get sendCancelRequest => 'Cancel request';

  @override
  String get sendDoneTitle => 'Response received';

  @override
  String sendUsage(int input, int output, String seconds) {
    return '$input input tokens · $output output · $seconds s';
  }

  @override
  String sendServedBy(String model) {
    return 'Response produced by $model';
  }

  @override
  String get sendFailedTitle => 'Request failed';

  @override
  String get commonClose => 'Close';

  @override
  String get homeChooseFolder => 'Choose a folder…';

  @override
  String get homeEnterPath => 'Enter a path';

  @override
  String get pickerConfirm => 'Choose this folder';

  @override
  String get addProjectBrowse => 'Browse…';

  @override
  String get detectionAnalyze => 'Analyze project';

  @override
  String get detectionAnalyzing => 'Analysis in progress…';

  @override
  String get detectionReadOnlyNote =>
      'Analysis is read-only: LaunchPilot reads configuration files (pubspec.yaml, package.json, manifests…) without changing anything. Sensitive files (keys, .env) are never read.';

  @override
  String get detectionNeverScanned => 'This project has not been analyzed yet.';

  @override
  String detectionScannedAt(String date, int count) {
    return 'Analyzed on $date · $count files scanned';
  }

  @override
  String detectionFailed(String error) {
    return 'Analysis failed: $error';
  }

  @override
  String detectionPartial(String reasons) {
    return 'Partial analysis ($reasons): results may be incomplete.';
  }

  @override
  String get partialMaxFiles => 'more than 20,000 files';

  @override
  String get partialMaxDepth => 'folders too deep';

  @override
  String get partialReadBudget => 'maximum read volume reached';

  @override
  String get partialTimeout => 'maximum duration reached';

  @override
  String get partialUnreadable => 'unreadable folders';

  @override
  String get detectionNoTechnology =>
      'No technology recognized. Check that the chosen folder is the project root.';

  @override
  String get detectionInformative => 'For information';

  @override
  String get detectionTargetsHint =>
      'Tick the targets you want to publish. Your choices are kept in later analyses.';

  @override
  String get detectionTargetSelected => 'Selected';

  @override
  String detectionTargetsReviewed(String date) {
    return 'Targets confirmed on $date';
  }

  @override
  String get detectionTargetsToReview =>
      'Targets to confirm: they follow detection until you confirm them.';

  @override
  String get detectionValidateTargets => 'Confirm targets';

  @override
  String get detectionTargetsValidated => 'Targets confirmed.';

  @override
  String get detectionIosLinuxNote =>
      'On Linux, the iOS build will go through macOS CI.';

  @override
  String get detectionPackages => 'Packages and scripts';

  @override
  String get detectionNoLockFile => 'No lock file';

  @override
  String get detectionNoScripts => 'No script declared';

  @override
  String get detectionGitAbsent =>
      'No Git repository. Creating one before any change is recommended, to be able to roll back.';

  @override
  String detectionGitBranch(String branch) {
    return 'Branch: $branch';
  }

  @override
  String detectionGitDetached(String commit) {
    return 'Detached HEAD at $commit';
  }

  @override
  String detectionGitTags(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags: $list',
      one: '1 tag: $list',
      zero: 'No tag',
    );
    return '$_temp0';
  }

  @override
  String get detectionGitWorktree =>
      'Linked repository (worktree or submodule): details not read.';

  @override
  String get detectionGitStatusLater =>
      'Live status (uncommitted changes) is shown on the publishing board, Project protection section.';

  @override
  String get detectionPublishingFiles => 'Publishing files';

  @override
  String get categoryIcon => 'Icons';

  @override
  String get categoryScreenshot => 'Screenshots';

  @override
  String get categoryFastlane => 'Fastlane';

  @override
  String get categoryCi => 'Continuous integration';

  @override
  String get categoryHosting => 'Hosting';

  @override
  String get categoryPwa => 'PWA';

  @override
  String get categoryLegal => 'Legal documents';

  @override
  String get categorySigning => 'Signing';

  @override
  String get detectionNothingFound => 'Nothing found';

  @override
  String get signingNotRead => 'present, not read';

  @override
  String get detectionSeo => 'SEO';

  @override
  String get seoTitle => 'Title tag';

  @override
  String get seoDescription => 'Meta description';

  @override
  String get seoCanonical => 'Canonical URL';

  @override
  String get seoOpenGraph => 'Open Graph';

  @override
  String get seoTwitterCard => 'Twitter Card';

  @override
  String get seoStructuredData => 'Structured data (schema.org)';

  @override
  String get seoRobots => 'robots.txt';

  @override
  String get seoSitemap => 'sitemap.xml';

  @override
  String get detectionPermissions => 'Declared permissions';

  @override
  String get detectionNoPermissions => 'No permission detected';

  @override
  String get detectionServices => 'Third-party services';

  @override
  String get detectionNoServices => 'No third-party SDK detected';

  @override
  String get serviceAnalytics => 'Analytics';

  @override
  String get serviceAds => 'Advertising';

  @override
  String get serviceCrash => 'Crash reporting';

  @override
  String get serviceMessaging => 'Notifications';

  @override
  String get serviceBackend => 'Backend';

  @override
  String get servicePayments => 'Payments';

  @override
  String detectionSensitive(String files) {
    return 'Sensitive files found and not read: $files';
  }

  @override
  String get riskReadOnly => 'Read-only';

  @override
  String get riskLocal => 'Generated files';

  @override
  String get riskSensitive => 'Changes the project';

  @override
  String get riskForbidden => 'Forbidden';

  @override
  String get riskReadOnlyDesc =>
      'Changes nothing. Runs even in simulation mode.';

  @override
  String get riskLocalDesc =>
      'Only writes generated files in the project (build, dependencies, cache).';

  @override
  String get riskSensitiveDesc =>
      'Changes project files or Git state: read carefully before confirming.';

  @override
  String get riskForbiddenDesc => 'Refused by LaunchPilot\'s safeguards.';

  @override
  String get issueNotAllowlisted =>
      'Tool outside the allowed list (git, flutter, dart, npm, pnpm, yarn, bun, node).';

  @override
  String get issueShell =>
      'Shells are forbidden: LaunchPilot never runs an interpreted string.';

  @override
  String get issuePrivileged => 'Privileged commands (sudo…) are forbidden.';

  @override
  String get issueInvalidExecutable =>
      'Give only the tool name, without a path.';

  @override
  String get issueInvalidArgument =>
      'Invalid argument (line break or null character).';

  @override
  String get issueOutsideProject =>
      'An argument points to a path outside the project.';

  @override
  String get issueWorkingDirectoryOutside =>
      'The working folder must be inside the project.';

  @override
  String get issuePublication =>
      'Publishing goes through a dedicated flow, with reinforced confirmation.';

  @override
  String get issueGitPush =>
      'Pushing to a remote repository is forbidden here.';

  @override
  String get issueDestructive =>
      'Destructive or irreversible operation: forbidden. Restores go through LaunchPilot\'s targeted mechanism.';

  @override
  String get issueSystemChange => 'Configuration or system change: forbidden.';

  @override
  String get issueGlobalInstall => 'Global installs are forbidden.';

  @override
  String get issueRemoteCode =>
      'Running downloaded or arbitrary code: forbidden.';

  @override
  String get issueUnknownSubcommand =>
      'Subcommand not recognized by the safety policy: refused as a precaution.';

  @override
  String get issueRunsProjectScript =>
      'Runs a script defined by the project: check its content (package.json).';

  @override
  String get issueCreatesTag => 'Creates a Git tag: reinforced confirmation.';

  @override
  String get cmdPreviewTitle => 'Command preview';

  @override
  String cmdWorkingDir(String path) {
    return 'Folder: $path';
  }

  @override
  String get cmdSimulationNote =>
      'Simulation mode: this command will only be previewed, not run.';

  @override
  String get cmdRun => 'Run';

  @override
  String get cmdSimulate => 'Simulate';

  @override
  String get cmdConfirmReinforced =>
      'I have read the summary and confirm this action.';

  @override
  String get cmdNoShellNote =>
      'Operators |, &&, > … have no effect: no command goes through a shell.';

  @override
  String get cmdParseError => 'Unclosed quote.';

  @override
  String get terminalSimulationOn =>
      'Simulation mode on: only read-only commands run.';

  @override
  String get terminalSimulationOff =>
      'Simulation mode off: confirmed commands really run.';

  @override
  String get terminalSimulationToggle => 'Simulation mode';

  @override
  String get terminalQuick => 'Suggested commands';

  @override
  String get terminalCustom => 'Custom command';

  @override
  String get terminalCustomHint => 'git log --oneline -n 20';

  @override
  String get terminalPreview => 'Preview';

  @override
  String terminalDuration(String seconds) {
    return '$seconds s';
  }

  @override
  String get terminalHistory => 'History';

  @override
  String get terminalHistoryEmpty => 'No command run for this project.';

  @override
  String get terminalNoOutput => 'No output.';

  @override
  String get terminalTruncated =>
      'Beginning of output truncated (very long output).';

  @override
  String terminalStartFailed(String exe) {
    return 'Cannot start \"$exe\": check that it is installed and in PATH.';
  }

  @override
  String get runSucceeded => 'Succeeded';

  @override
  String get runFailed => 'Failed';

  @override
  String get runCancelled => 'Cancelled';

  @override
  String get runTimedOut => 'Timed out';

  @override
  String get runBlocked => 'Blocked';

  @override
  String get runSimulated => 'Simulated';

  @override
  String get runStartFailed => 'Could not start';

  @override
  String get protectionTitle => 'Project protection';

  @override
  String get protectionNoGit =>
      'No Git repository: LaunchPilot still backs up each file before changing it, but a Git repository is strongly recommended.';

  @override
  String get protectionClean => 'Clean repository: no uncommitted change.';

  @override
  String protectionDirty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uncommitted changes',
      one: '1 uncommitted change',
    );
    return '$_temp0';
  }

  @override
  String get protectionDirtyHint =>
      'LaunchPilot will never touch your changes. Consider committing them or working on a dedicated branch.';

  @override
  String get protectionDetached => 'Detached HEAD';

  @override
  String get protectionRefresh => 'Refresh';

  @override
  String protectionCreateBranch(String name) {
    return 'Create branch $name';
  }

  @override
  String protectionOnBranch(String name) {
    return 'You are working on branch $name.';
  }

  @override
  String get protectionGitignoreTitle => 'Sensitive files not ignored by Git';

  @override
  String protectionGitignoreHint(String files) {
    return 'They could be committed by mistake: $files';
  }

  @override
  String get protectionGitignoreAction => 'Prepare .gitignore update';

  @override
  String get protectionGitignoreLabel => 'Sensitive files protection';

  @override
  String get protectionChanges => 'Changes made by LaunchPilot';

  @override
  String get protectionChangesEmpty =>
      'LaunchPilot has not changed any file in this project yet.';

  @override
  String get protectionRestore => 'Restore';

  @override
  String protectionRestored(String date) {
    return 'Restored on $date';
  }

  @override
  String get changeCreated => 'created';

  @override
  String get changeModified => 'modified';

  @override
  String get restoreDone => 'File restored.';

  @override
  String get restoreConflict =>
      'Restore refused: the file was changed since. Your changes are kept.';

  @override
  String get restoreBackupMissing => 'Backup copy not found: cannot restore.';

  @override
  String get writePreviewTitle => 'Changes preview';

  @override
  String get writeFileNew => 'New file';

  @override
  String writeDirtyWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The repository has $count uncommitted changes.',
      one: 'The repository has 1 uncommitted change.',
    );
    return '$_temp0 LaunchPilot will not touch them; its own changes can be undone file by file.';
  }

  @override
  String get writeBackupNote =>
      'A copy of each file is saved before writing, so it can be restored.';

  @override
  String get writeConfirm => 'Write files';

  @override
  String get writeDone => 'Changes written.';

  @override
  String get writeChangedSincePreview =>
      'A file changed since the preview: nothing was written. Run the preview again.';

  @override
  String writeRefused(String path) {
    return 'Write refused: $path';
  }

  @override
  String get writeTooBig => 'File too large for a line-by-line preview.';

  @override
  String get settingsExecution => 'Command execution';

  @override
  String get settingsSimulationHint =>
      'On: only read-only commands (git status, flutter analyze…) run; the others are only previewed. Forbidden commands (push, publishing, deletion…) stay refused in every case.';

  @override
  String get checklistBlocked => 'Blocked';

  @override
  String checklistBlockedBy(String steps) {
    return 'Finish first: $steps';
  }

  @override
  String checklistLaterPhase(int phase) {
    return 'Automation planned for phase $phase: until then, follow the explanations and mark the step as done.';
  }

  @override
  String get checklistGlossary => 'Terms';

  @override
  String get kindCommand => 'Command';

  @override
  String get kindManual => 'Check';

  @override
  String get kindPedagogical => 'To understand';

  @override
  String get checklistDone => 'It\'s checked';

  @override
  String get checklistUnderstood => 'Got it';

  @override
  String get checklistReset => 'Start over';

  @override
  String get checklistNeedsDetectionTitle => 'Project not analyzed yet';

  @override
  String get checklistNeedsDetectionMessage =>
      'The checklist is built from the detection report and the selected targets.';

  @override
  String get checklistGoDetection => 'Go to detection';

  @override
  String get checklistTargetsNotReviewed =>
      'Targets not confirmed yet: the checklist follows detection.';

  @override
  String checklistActiveTargets(String list) {
    return 'Targets: $list';
  }

  @override
  String checklistNext(String title) {
    return 'Next step: $title';
  }

  @override
  String get checklistAllDone => 'All steps are done.';

  @override
  String get checklistRunOk => 'Step succeeded.';

  @override
  String get checklistRunFailed =>
      'The command failed: the output is in the terminal.';

  @override
  String get checklistSimulated =>
      'Simulated command: the step stays to do. Turn off simulation mode to really run it.';

  @override
  String get checklistOpenTerminal => 'See output';

  @override
  String get contentTabVersion => 'Version';

  @override
  String get contentTabChangelog => 'Changelog';

  @override
  String get contentTabTexts => 'Texts';

  @override
  String get contentTabLegal => 'Legal';

  @override
  String get contentNeedsProject =>
      'Open a project to prepare its version, icons, screenshots, texts and legal documents.';

  @override
  String get contentNeedsSession =>
      'Start a session (publishing board) to save this content.';

  @override
  String get contentPreviewWrite => 'Preview and write';

  @override
  String get versionNoManifest =>
      'No version file found (pubspec.yaml or package.json).';

  @override
  String get versionNoLine => 'This file has no \"version\" line.';

  @override
  String versionCurrent(String version) {
    return 'Current version: $version';
  }

  @override
  String versionUnparsable(String version) {
    return 'Format \"$version\" not recognized: enter the new version by hand.';
  }

  @override
  String get versionBumpMajor => 'Major';

  @override
  String get versionBumpMinor => 'Minor';

  @override
  String get versionBumpPatch => 'Patch';

  @override
  String get versionBumpNone => 'Build only';

  @override
  String get versionBumpHelp =>
      'Major: incompatible change · Minor: feature · Patch: fix.';

  @override
  String get versionIncrementBuild => 'Increase the build number';

  @override
  String get versionCustom => 'Or type the version';

  @override
  String versionProposed(String from, String to) {
    return '$from → $to';
  }

  @override
  String versionUseSession(String version) {
    return 'Use the session version ($version)';
  }

  @override
  String get versionInvalid =>
      'Invalid version: use the 1.2.3 or 1.2.3+4 format.';

  @override
  String get versionNotHigher =>
      'Warning: this version is not higher than the current one.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get changelogRead => 'Read commits';

  @override
  String changelogSinceTag(int count, String tag) {
    return '$count commits since $tag';
  }

  @override
  String changelogLimited(int count) {
    return 'No tag found: the last $count commits';
  }

  @override
  String get changelogNoGit =>
      'No Git repository: write the changelog by hand.';

  @override
  String get changelogTechnical => 'Technical';

  @override
  String get changelogPublic => 'General public';

  @override
  String get changelogPublicFallback => 'Various improvements and fixes.';

  @override
  String get changelogGroupBreaking => 'Breaking changes';

  @override
  String get changelogGroupFeatures => 'New features';

  @override
  String get changelogGroupFixes => 'Fixes';

  @override
  String get changelogGroupPerformance => 'Performance';

  @override
  String get changelogGroupDocs => 'Documentation';

  @override
  String get changelogGroupOther => 'Other changes';

  @override
  String get changelogAi => 'Rephrase with AI';

  @override
  String changelogAiInstruction(String version) {
    return 'Rephrase these commit messages into two Markdown changelogs for version $version: \"technical\" for developers, \"public\" simple and jargon-free for the general public. Start each with \"## $version\". Do not invent any change.';
  }

  @override
  String get changelogWrite => 'Write to CHANGELOG.md';

  @override
  String changelogTag(String tag) {
    return 'Create tag $tag';
  }

  @override
  String get changelogTagNote =>
      'The tag stays local: LaunchPilot never pushes to a remote repository.';

  @override
  String get changelogEmpty => 'No commit to summarize.';

  @override
  String get iconsChoose => 'Choose the source image';

  @override
  String iconsSourceInfo(String name, int width, int height) {
    return '$name · $width × $height px';
  }

  @override
  String get iconsIssueTooSmall =>
      'Image too small: 512 px minimum, 1024 px recommended.';

  @override
  String get iconsIssueBelowRecommended =>
      'Under 1024 px: large icons may look blurry.';

  @override
  String get iconsIssueNotSquare =>
      'Non-square image: it will be centered on a transparent background, never stretched.';

  @override
  String get iconsIssueTransparent =>
      'Transparent areas: filled with the background color for opaque icons (App Store).';

  @override
  String get iconsIssueUnreadable => 'Unreadable image.';

  @override
  String get iconsBackground => 'Background color (opaque and maskable icons)';

  @override
  String iconsTargets(int count) {
    return '$count files to produce';
  }

  @override
  String get iconsNoTarget =>
      'No target with icons: select Android, iOS or Web in detection.';

  @override
  String get iconsGenerate => 'Generate icons';

  @override
  String get iconsGenerating => 'Generating…';

  @override
  String get iconsLabel => 'App icons';

  @override
  String get shotsImport => 'Import screenshots';

  @override
  String get slotPlay => 'Play Store';

  @override
  String get slotIphone69 => 'iPhone 6.9\"';

  @override
  String get slotIphone65 => 'iPhone 6.5\"';

  @override
  String get slotIpad13 => 'iPad 13\"';

  @override
  String get shotsMask => 'Mask areas';

  @override
  String shotsMaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count masked areas',
      one: '1 masked area',
      zero: 'No masked area',
    );
    return '$_temp0';
  }

  @override
  String get shotsMaskHelp =>
      'Drag on the image to cover personal data (name, email, number…). The cover is permanent in the export.';

  @override
  String get shotsMaskClear => 'Clear all';

  @override
  String get shotsMaskApply => 'Apply';

  @override
  String get shotsRemove => 'Remove';

  @override
  String get shotsCaption => 'Caption';

  @override
  String get shotsFrame => 'Frame';

  @override
  String get frameNone => 'None';

  @override
  String get frameIndigo => 'Indigo';

  @override
  String get frameLight => 'Light';

  @override
  String get frameSunset => 'Sunset';

  @override
  String get shotsFormat => 'Export format';

  @override
  String get formatPlay => 'Play Store 1080 × 1920';

  @override
  String get formatIphone => 'iPhone 1290 × 2796';

  @override
  String get formatIpad => 'iPad 2048 × 2732';

  @override
  String get shotsExport => 'Prepare export';

  @override
  String get shotsLabel => 'Store screenshots';

  @override
  String get textsLanguage => 'Listing language';

  @override
  String get textsPitch => 'Describe the app in one sentence';

  @override
  String get textsPitchHint => 'A simple, ad-free local weather app.';

  @override
  String get textsAi => 'Generate with AI';

  @override
  String textsAiInstruction(String app, String language, String pitch) {
    return 'Write the store listing of the app \"$app\" in $language. Description: $pitch. Strictly respect the limits: title and subtitle 30 characters, short description 80, keywords 100 (comma-separated), promotional text 170, long description 4000. Do not invent any feature missing from the description.';
  }

  @override
  String get fieldLongDescription => 'Long description';

  @override
  String get fieldPromoText => 'Promotional text';

  @override
  String textsCounter(int count, int limit) {
    return '$count / $limit';
  }

  @override
  String get textsSave => 'Save texts';

  @override
  String get textsSaved => 'Texts saved in the session.';

  @override
  String get textsOverLimit => 'Some fields exceed the store limits.';

  @override
  String get textsPreviewStore => 'Listing preview';

  @override
  String get textsPreviewSocial => 'Share preview';

  @override
  String get textsNote =>
      'Texts are kept in the session; sending them to the stores comes with Fastlane (phase 9).';

  @override
  String get legalDisclaimer =>
      'These documents are templates generated from your answers. They do not guarantee legal compliance: review them, complete them and have a professional validate them if needed.';

  @override
  String get legalPublisherType => 'Publisher';

  @override
  String get publisherIndividual => 'Individual';

  @override
  String get publisherCompany => 'Company';

  @override
  String get legalAppName => 'App name';

  @override
  String get legalPublisherName => 'Publisher name';

  @override
  String get legalAddress => 'Address';

  @override
  String get legalEmail => 'Contact email';

  @override
  String get legalCompanyId => 'Company number';

  @override
  String get legalHostName => 'Host';

  @override
  String get legalHostAddress => 'Host address';

  @override
  String get legalData => 'Data collected';

  @override
  String get dataContact => 'Contact';

  @override
  String get dataLocation => 'Location';

  @override
  String get dataPhotos => 'Photos / camera';

  @override
  String get dataAudio => 'Audio';

  @override
  String get dataContacts => 'Address book';

  @override
  String get dataUsage => 'Usage analytics';

  @override
  String get dataCrash => 'Crash reports';

  @override
  String get dataAdId => 'Advertising ID';

  @override
  String get dataPayment => 'Payment';

  @override
  String get legalPrefilled => 'Prefilled from detection: check them.';

  @override
  String get legalThirdParties => 'Third-party services';

  @override
  String get legalAddThirdParty => 'Add a service';

  @override
  String legalRetention(int months) {
    return 'Retention: $months months';
  }

  @override
  String get legalCookies => 'The site uses analytics or advertising cookies';

  @override
  String get legalMinors => 'The app also targets under-15s';

  @override
  String legalMissing(String fields) {
    return 'To complete: $fields';
  }

  @override
  String get legalSave => 'Save answers';

  @override
  String get legalSaved => 'Answers saved.';

  @override
  String get legalDocLanguage => 'Documents language';

  @override
  String get legalGenerate => 'Generate templates';

  @override
  String get legalLabel => 'Legal documents (templates)';

  @override
  String get checklistOpenTool => 'Open the tool';

  @override
  String writeBinary(int size) {
    return 'Binary file · $size bytes';
  }

  @override
  String get writeImageBefore => 'Before';

  @override
  String get writeImageAfter => 'After';

  @override
  String get issueProductionDeploy =>
      'Public deployment: reinforced confirmation.';

  @override
  String get issuePreviewDeploy =>
      'Deployment to a preview address: reinforced confirmation.';

  @override
  String get issueNetwork =>
      'Queries the live site and writes a report in the project.';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonCopied => 'Copied to the clipboard.';

  @override
  String get auditAreaResponsive => 'Mobile display';

  @override
  String get auditAreaAccessibility => 'Accessibility';

  @override
  String get auditAreaLinks => 'Links';

  @override
  String get auditAreaForms => 'Forms';

  @override
  String get auditAreaErrors => 'Error pages';

  @override
  String get webGapNoScript =>
      'The project declares no build command (no \"build\" script): LaunchPilot does not invent one. Add one to package.json, or point to the folder that is ready to publish.';

  @override
  String get webGapServer =>
      'This framework renders pages on the server: there is no static folder to upload. Use the Vercel or Netlify Git integration, or configure a static export.';

  @override
  String get webNoPlan =>
      'No website recognized in this project. Run the analysis or check the Web target in the detection report.';

  @override
  String get webBuildTitle => 'Build';

  @override
  String webFramework(String name) {
    return 'Technology: $name';
  }

  @override
  String get webOutputDir => 'Output folder (relative to the project)';

  @override
  String get webOutputGuessed =>
      'Framework convention, not confirmed: check it then press Enter.';

  @override
  String get webOutputReady => 'The output folder contains index.html.';

  @override
  String get webOutputMissing =>
      'No index.html in the output folder yet: build the site.';

  @override
  String get webBuild => 'Build (command preview)';

  @override
  String get webAuditTitle => 'Site audit';

  @override
  String get webAuditHelp =>
      'Static checks, no network: SEO, mobile display, PWA, accessibility, internal links, mixed content, forms and 404 page.';

  @override
  String get webAuditOutput => 'Built site';

  @override
  String get webAuditSources => 'Sources';

  @override
  String get webAuditRun => 'Run the audit';

  @override
  String get webAuditNoFolder => 'This folder does not exist yet.';

  @override
  String webAuditSummary(int failures, int warnings, int ok) {
    return '$failures problem(s), $warnings warning(s), $ok check(s) passed';
  }

  @override
  String get webAuditTruncated => 'Large site: only part of it was examined.';

  @override
  String get webAuditLimits =>
      'The audit reads files: it does not replace testing on real devices, Lighthouse, or checking external links.';

  @override
  String get webPreviewTitle => 'Local preview';

  @override
  String get webPreviewHelp =>
      'Serves the output folder on your machine only (127.0.0.1), to test it in a browser or with Lighthouse.';

  @override
  String get webServeStart => 'Start the preview';

  @override
  String get webServeStop => 'Stop the preview';

  @override
  String get webPreviewChecks =>
      'Check by hand: mobile display (browser responsive mode), navigation, forms, 404 page and offline mode.';

  @override
  String get webLighthouseMissing =>
      'Lighthouse is not installed: it is optional. To add it (Node.js and Chrome or Chromium required), run in your own terminal:';

  @override
  String get webLighthouseHelp =>
      'Measures performance, accessibility, best practices and SEO of an address (local preview or live site). The report is written to lighthouse-report.json at the project root.';

  @override
  String get webLighthouseUrl => 'Address to audit';

  @override
  String get webLighthouseRun => 'Run Lighthouse';

  @override
  String get webLighthouseRead => 'Read the latest report';

  @override
  String get webLighthouseUnreadable => 'The Lighthouse report cannot be read.';

  @override
  String get seoLabel => 'SEO';

  @override
  String get seoAnalyticsLabel => 'Analytics';

  @override
  String get seoHelp =>
      'This information describes the site to search engines and social networks. LaunchPilot prepares the tags, robots.txt, sitemap.xml and schema.org data; you see every change before writing.';

  @override
  String get seoSiteUrl => 'Public site address';

  @override
  String get seoSiteUrlInvalid =>
      'Invalid address: it must start with https:// and contain a domain.';

  @override
  String get seoSiteName => 'Site name';

  @override
  String get seoImage => 'Share image (full address)';

  @override
  String get seoImageHint =>
      'Recommended: 1200 × 630 px, published on the site (for example in the public folder).';

  @override
  String get seoTwitter => 'X / Twitter account (optional)';

  @override
  String get seoLocale => 'Language and country (Open Graph)';

  @override
  String get seoSchema => 'schema.org type';

  @override
  String get seoSchemaWebsite => 'Website';

  @override
  String get seoSchemaApp => 'Web application';

  @override
  String get seoSchemaOrg => 'Organization';

  @override
  String get seoExtraPaths => 'Other sitemap pages (one per line)';

  @override
  String get seoSpaNote =>
      'Single-page app: the sitemap contains the home page. Add other public routes later if needed.';

  @override
  String seoFiles(String files) {
    return 'Files involved: $files';
  }

  @override
  String get seoManagedHead =>
      'This framework generates <head> itself: LaunchPilot does not edit its files. Copy these tags into the page head configuration (metadata, useHead…).';

  @override
  String get seoNeedsUrl => 'Enter the public site address first.';

  @override
  String get seoPreviewSearch => 'Search engine preview';

  @override
  String get seoPreviewSocial => 'Share preview';

  @override
  String get seoPreviewNoImage => 'No share image';

  @override
  String get seoAnalyticsTitle => 'Privacy-friendly analytics';

  @override
  String get seoAnalyticsHelp =>
      'Plausible and Umami measure traffic without cookies or resold personal data. You need an account (or your own instance); LaunchPilot only adds the script to the page.';

  @override
  String get seoAnalyticsNone => 'None';

  @override
  String get seoAnalyticsScript =>
      'Script address (optional, self-hosted instance)';

  @override
  String get seoAnalyticsUmamiId => 'Umami website ID';

  @override
  String get seoAnalyticsLegal =>
      'Remember to mention it in the privacy policy (Legal tool).';

  @override
  String get seoAnalyticsAdd => 'Add to the page (preview)';

  @override
  String get seoAnalyticsRemove => 'Remove analytics (preview)';

  @override
  String get pwaLabel => 'PWA';

  @override
  String get pwaHelp =>
      'A PWA installs like an app from the browser. The manifest describes its name, colours and icons; the service worker (optional) enables offline mode.';

  @override
  String get pwaName => 'Full name';

  @override
  String get pwaShortName => 'Short name';

  @override
  String get pwaShortNameHint =>
      'Shown under the icon: 12 characters at most recommended.';

  @override
  String get pwaDescription => 'Description';

  @override
  String get pwaThemeColor => 'Theme colour';

  @override
  String get pwaBackgroundColor => 'Background colour (splash screen)';

  @override
  String get pwaColorInvalid => 'Expected format: #RRGGBB';

  @override
  String get pwaDisplay => 'Display mode';

  @override
  String get pwaIconsOk => '192 and 512 px icons present.';

  @override
  String get pwaIconsMissing =>
      '192 and 512 px icons missing: generate them with the Icons tool.';

  @override
  String get pwaWorker => 'Add an offline service worker';

  @override
  String get pwaWorkerHelp =>
      'Creates sw.js (pages network-first with offline fallback, files cached) and registers it in the page.';

  @override
  String get pwaWorkerFlutter =>
      'Flutter\'s automatic service worker is deprecated. This one replaces it: then build with \"--pwa-strategy=none\" if your Flutter version still offers it, to avoid two workers.';

  @override
  String get pwaOfflineTest =>
      'To test: build, start the local preview, open developer tools → Application → tick \"Offline\", then reload the page.';

  @override
  String pwaProblems(String fields) {
    return 'To fix: $fields';
  }

  @override
  String get hostingGapFirebase =>
      'Enter the Firebase project ID (shown in the Firebase console).';

  @override
  String get hostingGapGithub => 'Enter the GitHub repository as user/repo.';

  @override
  String get hostingGapBuild =>
      'No known build command: the GitHub workflow would not know how to build the site.';

  @override
  String hostingLabel(String host) {
    return '$host hosting';
  }

  @override
  String get hostingChoose => 'Host';

  @override
  String get hostingChooseHelp =>
      'Choose where to publish the site. Your default choice is set in Settings.';

  @override
  String get hostingFirebaseProject => 'Firebase project ID';

  @override
  String get hostingNetlifySite =>
      'Netlify site name or ID (optional if the folder is linked)';

  @override
  String get hostingGithubRepo => 'GitHub repository (user/repo)';

  @override
  String get hostingDomain => 'Custom domain (optional)';

  @override
  String get hostingInvalid => 'Invalid format.';

  @override
  String hostingFiles(String files) {
    return 'Prepared files: $files';
  }

  @override
  String get hostingPrepare => 'Prepare the configuration (preview)';

  @override
  String get hostingDeployTitle => 'Deployment';

  @override
  String get hostingGithubDeploy =>
      'GitHub Pages publishes the site on every push to main, thanks to the workflow prepared above. LaunchPilot never pushes: commit then push yourself, then in GitHub → Settings → Pages, pick \"GitHub Actions\" as the source.';

  @override
  String hostingCliMissing(String cli) {
    return 'The \"$cli\" tool is not installed. Install it in your own terminal (global install, never run by LaunchPilot):';
  }

  @override
  String hostingLogin(String command) {
    return 'Sign in: run \"$command\" in your own terminal. LaunchPilot neither sees nor stores your credentials.';
  }

  @override
  String get hostingVercelLink =>
      'On the first deployment, Vercel may ask to link the folder to a project: run \"vercel link\" in your terminal if the command fails.';

  @override
  String get hostingNetlifyLink =>
      'Without a site name, Netlify uses the site linked to the folder (\"netlify link\" in your terminal).';

  @override
  String get hostingBuildFirst =>
      'Build the site first (Website tab): the output folder does not contain index.html.';

  @override
  String get hostingDeployNote =>
      'Each deployment goes through a summary to tick, then the command preview with reinforced confirmation. In simulation mode, nothing is published.';

  @override
  String get hostingDeployPreview => 'Deploy a preview';

  @override
  String get hostingDeployProduction => 'Deploy to production';

  @override
  String get hostingDnsTitle => 'Domain and DNS';

  @override
  String get hostingDnsNever =>
      'LaunchPilot never changes DNS: enter these records yourself at your domain provider.';

  @override
  String get hostingDnsNeedsDomain =>
      'Enter a custom domain to see the recommended records.';

  @override
  String get hostingDnsFirebase =>
      'Firebase provides values specific to your project: Firebase console → Hosting → Add custom domain, then copy the records shown.';

  @override
  String get hostingDnsVercel =>
      'Vercel\'s general-purpose values. Vercel may recommend project-specific values: check the dashboard (Domains) or \"vercel domains inspect\".';

  @override
  String get hostingDnsNetlify =>
      'Netlify does not support IPv6 on this address: remove any AAAA record on the root domain. If your provider allows it, prefer an ALIAS to apex-loadbalancer.netlify.com.';

  @override
  String get hostingDnsGithub =>
      'Also add the domain in GitHub → Settings → Pages (the CNAME file is prepared with the configuration), then enable \"Enforce HTTPS\".';

  @override
  String get hostingDnsPropagation => 'Propagation can take up to 24 hours.';

  @override
  String get hostingDnsCheck => 'Check resolution';

  @override
  String get hostingDnsNone => 'The domain does not resolve yet.';

  @override
  String hostingDnsResolved(String addresses) {
    return 'The domain points to: $addresses';
  }

  @override
  String get hostingOnlineTitle => 'Online check';

  @override
  String get hostingOnlineHelp =>
      'Queries the public site address: HTTPS response, redirect from HTTP and HSTS header.';

  @override
  String get hostingOnlineCheck => 'Check the live site';

  @override
  String hostingHttpsFailed(String error) {
    return 'HTTPS unreachable ($error).';
  }

  @override
  String hostingHttpsStatus(int code) {
    return 'HTTPS answers (code $code).';
  }

  @override
  String get hostingRedirectUnknown =>
      'HTTP → HTTPS redirect could not be checked.';

  @override
  String get hostingRedirectOk => 'HTTP redirects to HTTPS.';

  @override
  String get hostingRedirectMissing => 'HTTP does not redirect to HTTPS.';

  @override
  String get hostingHstsOk => 'HSTS header present.';

  @override
  String get hostingHstsMissing =>
      'No HSTS header (optional, strengthens HTTPS).';

  @override
  String get deployRecapProd => 'Summary: production deployment';

  @override
  String get deployRecapPreview => 'Summary: preview deployment';

  @override
  String deployRecapHost(String host) {
    return 'Host: $host';
  }

  @override
  String deployRecapProject(String name) {
    return 'Project: $name';
  }

  @override
  String deployRecapFolder(String folder) {
    return 'Published folder: $folder';
  }

  @override
  String get deployRecapProdEffect =>
      'The public site will be replaced by this content, visible to everyone.';

  @override
  String get deployRecapPreviewEffect =>
      'A temporary address, reachable by anyone who knows it, will be created.';

  @override
  String get deployRecapDirty =>
      'The repository has uncommitted changes: the published site will not match any commit.';

  @override
  String get deployRecapSimulation =>
      'Simulation mode on: the command will only be previewed, nothing will be published.';

  @override
  String get deployRecapAck => 'I have read this summary and want to publish.';

  @override
  String get deployRecapContinue => 'Continue to the command preview';

  @override
  String get contentTabWeb => 'Website';

  @override
  String get contentTabHosting => 'Hosting';

  @override
  String get contentWebNotSelected =>
      'The Web target is not selected for this project: tick it in the detection report to use this tool.';

  @override
  String get settingsPreferredHost => 'Default host';

  @override
  String get settingsHostNone => 'None';

  @override
  String get settingsAnalytics => 'Analytics suggested for websites';

  @override
  String get webSeoTitle => 'Title (<title> tag)';

  @override
  String get webSeoDescription => 'Description';

  @override
  String get issueStorePublication =>
      'Upload to Google Play: reinforced confirmation.';

  @override
  String get androidAreaIdentity => 'Identity';

  @override
  String get androidAreaVersion => 'Version';

  @override
  String get androidAreaSdk => 'Android versions';

  @override
  String get androidAreaSigning => 'Signing';

  @override
  String get androidAreaSecurity => 'Security';

  @override
  String get androidAreaPermissions => 'Permissions';

  @override
  String get androidAreaIcons => 'Icons';

  @override
  String get androidNoModule =>
      'No android folder in this Flutter project: generate it with \"flutter create --platforms=android .\" in your terminal.';

  @override
  String get androidEnvTitle => 'Android environment';

  @override
  String get androidEnvHelp =>
      'Checks the Android SDK, Java and licenses with \"flutter doctor -v\" (read-only). Gradle, Android plugin and Kotlin versions are read from the project.';

  @override
  String androidToolVersions(String gradle, String agp, String kotlin) {
    return 'Gradle $gradle · Android plugin $agp · Kotlin $kotlin';
  }

  @override
  String get androidDoctor => 'Check the environment (flutter doctor -v)';

  @override
  String get androidDoctorEmpty =>
      'No Android section in the output: the Android SDK may not be installed.';

  @override
  String androidJava(String version) {
    return 'Java: $version';
  }

  @override
  String get androidLicenses =>
      'To accept the licenses, run \"flutter doctor --android-licenses\" in your own terminal (interactive questions).';

  @override
  String get androidAuditTitle => 'Android audit';

  @override
  String get androidAuditHelp =>
      'ID, version, target API, signing, security, permissions (compared with the project\'s plugins) and icons. Signing files are never read.';

  @override
  String get androidAuditRun => 'Run the Android audit';

  @override
  String get androidDataSafety =>
      'Detected permissions and SDKs feed the Play Console \"Data safety\" section and the legal questionnaire (Legal tool).';

  @override
  String get androidSigningTitle => 'Signing key';

  @override
  String get androidSigningHelp =>
      'Each published release is signed with your upload key (keystore). You create it once in your terminal: passwords never go through LaunchPilot, which reads neither key.properties nor the keystore.';

  @override
  String get androidKeyPropertiesPresent =>
      'android/key.properties is present (not read).';

  @override
  String get androidKeyPropertiesMissing =>
      'android/key.properties is missing.';

  @override
  String get androidKeytoolStep =>
      '1. Create the keystore (in your terminal, outside the project)';

  @override
  String get androidKeyPropertiesStep =>
      '2. Create android/key.properties (fill it in yourself)';

  @override
  String get androidPlayAppSigning =>
      'With Play App Signing (on by default), Google keeps the final key; yours is only for uploading and can be reset if lost. Back it up outside the project anyway.';

  @override
  String get androidSigningConfigure =>
      '3. Configure release signing (preview)';

  @override
  String get androidGitignore => 'Ignore signing secrets (preview)';

  @override
  String get androidGitignoreDone =>
      '.gitignore already contains these entries.';

  @override
  String get androidGitignoreLabel => 'Android signing secrets';

  @override
  String get androidSigningLabel => 'Android release signing';

  @override
  String get androidSigningAlready => 'Release signing is already configured.';

  @override
  String get androidSigningUnrecognized =>
      'This file does not match the Flutter template: LaunchPilot does not edit it. Copy this snippet by hand.';

  @override
  String get androidBuildTitle => 'Build';

  @override
  String get androidBuildHelp =>
      'The App Bundle (.aab) is the format required by Google Play. The APK is for testing or distribution outside the store; \"per architecture\" produces lighter files.';

  @override
  String get androidBuildAab => 'Build the App Bundle';

  @override
  String get androidBuildApk => 'Build the APK';

  @override
  String get androidSplitPerAbi => 'One APK per architecture';

  @override
  String get androidDeliverablesTitle => 'Deliverables';

  @override
  String get androidDeliverablesHelp =>
      'Path, size, SHA-256 fingerprint and signing of the produced files.';

  @override
  String get androidDeliverablesCheck => 'Check the deliverables';

  @override
  String get androidDeliverablesNone =>
      'No deliverable found: build the App Bundle or APK first.';

  @override
  String get androidSignedDebug =>
      'Signed with the debug key: Google Play will reject it.';

  @override
  String get androidSignedRelease => 'Signed with your key.';

  @override
  String get androidUnsigned => 'No signature found.';

  @override
  String get playFieldTitle => 'App name';

  @override
  String get playFieldShort => 'Short description';

  @override
  String get playFieldFull => 'Full description';

  @override
  String get playFieldChangelog => 'Release notes (this version)';

  @override
  String get playSaved => 'Play Store listing saved in the session.';

  @override
  String get playListingTitle => 'Play Store listing';

  @override
  String get playListingHelp =>
      'Prefilled with the session\'s store texts and public changelog; Google Play limits show under each field.';

  @override
  String get playVisualsTitle => 'Graphics';

  @override
  String get playVisualsHelp =>
      'Google Play asks for a 512 × 512 icon, a 1024 × 500 feature graphic and at least 2 screenshots. LaunchPilot prepares the icon and graphic from an image of at least 512 px, without distorting it; screenshots come from the Screenshots tool (Play format).';

  @override
  String get playIconPick => 'Choose the icon image';

  @override
  String get playIconTooSmall =>
      'Image too small: at least 512 × 512 px is needed.';

  @override
  String playScreenshots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count screenshots ready',
      one: '1 screenshot: at least 2 are needed',
      zero: 'No Play-format screenshot (Screenshots tool)',
    );
    return '$_temp0';
  }

  @override
  String get playFastlaneLabel => 'Fastlane Google Play';

  @override
  String get playFastlaneHelp =>
      'Prepares android/fastlane: Appfile (ID), Fastfile (upload to the internal track as a draft, listing update) and \"supply\" metadata (texts, icon, graphic, screenshots). No key is written there.';

  @override
  String get playNoPackage =>
      'Application ID not found in build.gradle: run the Android audit.';

  @override
  String playPackage(String package, int code) {
    return 'App $package · versionCode $code';
  }

  @override
  String get playExamplePackage =>
      '\"com.example\" ID: Google Play will reject it. Change it before the first upload.';

  @override
  String get playFastlanePrepare => 'Prepare Fastlane (preview)';

  @override
  String get playListingIncomplete =>
      'Fill in at least the name and both descriptions for one language.';

  @override
  String get playUploadTitle => 'Upload to the internal testing track';

  @override
  String get playFirstUpload =>
      'The very first App Bundle must be uploaded by hand in the Play Console (app creation): Fastlane can only take over afterwards.';

  @override
  String get playFastlaneMissing =>
      'Fastlane is not installed. Install it in your own terminal (system install, never run by LaunchPilot):';

  @override
  String get playFastfileFirst => 'Prepare the Fastlane files above first.';

  @override
  String get playCheckAab => 'Check the App Bundle';

  @override
  String playAabReady(String size) {
    return 'App Bundle signed with your key ($size).';
  }

  @override
  String get playJsonKey => 'Service account key (path to the .json file)';

  @override
  String get playJsonKeyHelp =>
      'Created in Google Cloud and granted in the Play Console. LaunchPilot neither reads nor copies this file: only its path is passed to Fastlane. Keep it outside the project.';

  @override
  String get playJsonKeyInvalid =>
      'Absolute path of an existing .json file expected.';

  @override
  String get playJsonKeyInProject =>
      'This key is inside the project: move it elsewhere or make sure Git ignores it.';

  @override
  String get playValidateKey => 'Validate the key';

  @override
  String get playUploadInternal => 'Upload to the internal track (draft)';

  @override
  String get playUploadMetadata => 'Update the listing';

  @override
  String get playUploadNote =>
      'The release is created as a draft: you roll it out to testers yourself in the Play Console. LaunchPilot never publishes to production.';

  @override
  String get playRecapInternal => 'Summary: upload to the internal track';

  @override
  String get playRecapMetadata => 'Summary: listing update';

  @override
  String playRecapPackage(String package) {
    return 'App: $package';
  }

  @override
  String playRecapVersionCode(int code) {
    return 'versionCode: $code (can never be reused)';
  }

  @override
  String get playRecapInternalEffect =>
      'The App Bundle is sent to Google Play and a draft release is created on the internal testing track.';

  @override
  String get playRecapMetadataEffect =>
      'The public listing\'s texts, icon, graphic and screenshots are replaced.';

  @override
  String get contentTabAndroid => 'Android';

  @override
  String get contentTabPlay => 'Play Store';

  @override
  String get contentAndroidNotSelected =>
      'The Android target is not selected for this Flutter project: tick it in the detection report to use this tool.';

  @override
  String get iosAreaLinux => 'Host machine';

  @override
  String get iosAreaPrivacy => 'Privacy';

  @override
  String get iosNoModule =>
      'No ios folder in this Flutter project: generate it with \"flutter create --platforms=ios .\" in your terminal (possible on Linux).';

  @override
  String get iosLimitsTitle =>
      'iOS from Linux: what is possible and what is not';

  @override
  String get iosMacTitle =>
      'Mac detected: LaunchPilot still prepares everything for a CI';

  @override
  String get iosLimitsCannot => 'Impossible on Linux:';

  @override
  String get iosLimit1 =>
      'build the app (flutter build ios / ipa): it needs Xcode, which only exists on macOS;';

  @override
  String get iosLimit2 =>
      'sign with an Apple certificate and a provisioning profile, or open the project in Xcode;';

  @override
  String get iosLimit3 => 'run the iOS simulator or take screenshots on it;';

  @override
  String get iosLimit4 =>
      'upload a build to App Store Connect (the upload is done from the macOS CI).';

  @override
  String get iosLimitsCan => 'Possible here, with a preview before writing:';

  @override
  String get iosCan1 =>
      'audit the project, complete Info.plist and the privacy manifest;';

  @override
  String get iosCan2 =>
      'prepare the App Store listing, screenshots (Screenshots tool) and Fastlane;';

  @override
  String get iosCan3 =>
      'generate the GitHub Actions (macOS runner) or Codemagic configuration.';

  @override
  String get iosNeverFake =>
      'LaunchPilot never shows an iOS build as successful without seeing it: only the CI dashboard is authoritative.';

  @override
  String get iosAuditTitle => 'iOS audit';

  @override
  String get iosAuditHelp =>
      'Reads Info.plist, project.pbxproj and the App Store icon: ID, access texts required by plugins, privacy manifest, encryption, team and signing.';

  @override
  String get iosAuditRun => 'Run the iOS audit';

  @override
  String get iosPlistTitle => 'Access texts and encryption (Info.plist)';

  @override
  String get iosPlistRunAudit =>
      'Run the audit first: missing or vague texts will appear here, with a suggestion to adapt.';

  @override
  String get iosPlistHelp =>
      'Each text is shown to the user when access is requested: explain concretely what it is for.';

  @override
  String get iosEncryption => 'The app only uses standard encryption (HTTPS)';

  @override
  String get iosEncryptionHelp =>
      'Declares ITSAppUsesNonExemptEncryption = false so you no longer answer the question at each upload. Turn off if the app encrypts data itself.';

  @override
  String get iosPlistLabel => 'iOS Info.plist';

  @override
  String get iosPlistUnrecognized =>
      'Info.plist does not have the expected shape: edit it by hand.';

  @override
  String get iosPrivacyTitle => 'Privacy manifest (PrivacyInfo.xcprivacy)';

  @override
  String get iosPrivacyHelp =>
      'Prepared from the legal questionnaire (or detection) then added to the Runner target of the Xcode project, as Xcode would. Plugins declare their own sensitive APIs.';

  @override
  String get iosTracking => 'The app tracks users across apps (ad tracking)';

  @override
  String get iosTrackingHelp =>
      'If yes, you must also list the tracking domains and ask for ATT permission: complete the file afterwards.';

  @override
  String get iosPrivacyPrepare => 'Prepare the manifest (preview)';

  @override
  String get iosPrivacyLabel => 'iOS privacy manifest';

  @override
  String get iosPbxUnrecognized =>
      'The Xcode project does not match the Flutter template: only the file is prepared. Add it to the Runner target in Xcode, on a Mac.';

  @override
  String get iosPrivacyNote =>
      'This manifest is a starting point to review: it does not guarantee compliance with Apple\'s rules.';

  @override
  String get iosAppleTitle => 'What remains to do at Apple';

  @override
  String get iosAppleHelp =>
      'These steps are done in a browser, on Linux as anywhere else. LaunchPilot never signs in there.';

  @override
  String get iosApple1 =>
      'Join the Apple Developer Program (yearly subscription) and note your Team ID (Membership).';

  @override
  String get iosApple2 =>
      'Register the app identifier (Identifiers → App IDs) with the same bundle ID as the project.';

  @override
  String get iosApple3 =>
      'Create the app record in App Store Connect (My Apps → +): name, language, bundle ID.';

  @override
  String get iosApple4 =>
      'Create an App Store Connect API key (Users and Access → Integrations) for the CI; the .p8 file can only be downloaded once.';

  @override
  String get iosApple5 =>
      'Fill in \"App Privacy\" and the age rating in App Store Connect.';

  @override
  String get iosApple6 =>
      'After the first build arrives, add TestFlight testers.';

  @override
  String get iosCertificates =>
      'Distribution certificate: proves the app comes from your team. Provisioning profile: ties that certificate, the app identifier and its entitlements together. With automatic signing, the CI creates and renews them using the API key (Admin role recommended so it can create certificates).';

  @override
  String get iosCiTitle => 'Build and upload with a macOS CI';

  @override
  String get iosCiHelp =>
      'GitHub Actions: macOS 26 runner with Xcode 26, automatic signing with the API key, upload to TestFlight. Codemagic: signing and publishing handled by its App Store Connect integration.';

  @override
  String get iosTeamId => 'Apple Team ID';

  @override
  String get iosTeamIdHelp =>
      '10 characters, shown in the developer account \"Membership\". It is not a secret.';

  @override
  String get iosAppleAppId => 'App Apple ID';

  @override
  String get iosAppleAppIdHelp =>
      'Number shown in App Store Connect → App Information. Used to compute the next build number.';

  @override
  String iosCiGithubSecrets(String names) {
    return 'Secrets to create in GitHub (Settings → Secrets and variables → Actions): $names. Values never go through LaunchPilot.';
  }

  @override
  String get iosCiCodemagicSetup =>
      'In Codemagic: add the App Store Connect API key (Teams → Integrations) under the name \"launchpilot\", then connect the repository.';

  @override
  String get iosCiPrepare => 'Prepare the CI configuration (preview)';

  @override
  String iosCiLabel(String provider) {
    return 'iOS CI $provider';
  }

  @override
  String get iosCiNote =>
      'The build only starts when you launch it yourself on the CI, after committing and pushing these files: LaunchPilot never pushes and never triggers a build.';

  @override
  String get iosKeyBase64 =>
      'For ASC_KEY_P8_BASE64, encode the .p8 file in your terminal: \"base64 -w0 AuthKey_XXXXXXXXXX.p8\", then paste the result into GitHub.';

  @override
  String get asFieldName => 'App name';

  @override
  String get asFieldSubtitle => 'Subtitle';

  @override
  String get asFieldDescription => 'Description';

  @override
  String get asFieldKeywords => 'Keywords';

  @override
  String get asFieldPromo => 'Promotional text';

  @override
  String get asFieldReleaseNotes => 'What\'s new in this version';

  @override
  String get asKeywordsHint =>
      'Comma-separated, no spaces; no need to repeat the name.';

  @override
  String get asSaved => 'App Store listing saved in the session.';

  @override
  String get asListingTitle => 'App Store listing';

  @override
  String get asListingHelp =>
      'Prefilled with the session\'s store texts and changelog; Apple\'s limits show under each field.';

  @override
  String get asSupportUrl => 'Support URL (required)';

  @override
  String get asPrivacyUrl => 'Privacy policy URL (required)';

  @override
  String get asPrivacyUrlHelp =>
      'The policy prepared by the Legal tool, once published on your site.';

  @override
  String get asMarketingUrl => 'Marketing URL (optional)';

  @override
  String get asCopyright => 'Copyright';

  @override
  String get asScreenshotsTitle => 'Screenshots';

  @override
  String get asScreenshotsHelp =>
      'They come from the Screenshots tool (iPhone 1290 × 2796 and iPad 2048 × 2732 formats), since the iOS simulator does not exist on Linux. You need 1 to 10 per device.';

  @override
  String asIphoneShots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iPhone screenshots ready',
      one: '1 iPhone screenshot ready',
      zero: 'No iPhone screenshot: at least one is needed',
    );
    return '$_temp0';
  }

  @override
  String asIpadShots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iPad screenshots ready',
      one: '1 iPad screenshot ready',
      zero: 'No iPad screenshot: needed because the app supports iPad',
    );
    return '$_temp0';
  }

  @override
  String get asPrivacyTitle => 'App Privacy (App Store labels)';

  @override
  String get asPrivacyHelp =>
      'According to the legal questionnaire, these are the data to declare:';

  @override
  String get asPrivacyNone =>
      'No data declared in the questionnaire: check it before answering \"Data Not Collected\".';

  @override
  String get asPrivacyManual =>
      'These answers are entered by hand in App Store Connect (App Privacy). They must match the privacy manifest and the published policy.';

  @override
  String get asFastlaneLabel => 'Fastlane App Store';

  @override
  String get asFastlaneHelp =>
      'Prepares ios/fastlane: Appfile (public IDs), Fastfile (metadata and beta lanes) and \"deliver\" metadata (texts, URLs, screenshots). The App Store Connect key comes from CI environment variables: no key is written.';

  @override
  String get asFastlanePrepare => 'Prepare Fastlane (preview)';

  @override
  String get asFastlaneMissing =>
      'You need the name, description and keywords for one language, and https support and privacy URLs.';

  @override
  String get asFastlaneWhere =>
      'These lanes run on a Mac or in the macOS CI (\"fastlane ios metadata\"): LaunchPilot does not run them on Linux.';

  @override
  String get contentTabIos => 'iOS';

  @override
  String get contentTabAppStore => 'App Store';

  @override
  String get contentIosNotSelected =>
      'The iOS target is not selected for this Flutter project: tick it in the detection report to use this tool.';

  @override
  String get chatTooLarge =>
      'The message and selected context are too long: untick a context item or shorten the question.';

  @override
  String get chatClearTitle => 'Clear the conversation?';

  @override
  String get chatClearMessage =>
      'This session\'s messages will be removed from LaunchPilot. AI providers keep their own logs according to their terms.';

  @override
  String get chatQuickNext => 'Explain the next step of my checklist simply.';

  @override
  String get chatQuickSimpler =>
      'Rephrase your last answer more simply, with an example.';

  @override
  String get chatQuickError =>
      'What does my last command\'s error mean, and what can I try?';

  @override
  String get chatQuickRemaining => 'What is left to do before publishing?';

  @override
  String get chatNoKeyTitle => 'No API key for the selected provider';

  @override
  String chatNoKeyMessage(String provider) {
    return 'The chat uses $provider. Save a key in Settings (it stays in the system keyring) or choose another provider.';
  }

  @override
  String get chatOpenSettings => 'Open settings';

  @override
  String get chatSafety =>
      'Each question goes through a preview of what will be sent, with secrets masked, then your confirmation. The agent only advises: it cannot run any command or change any file.';

  @override
  String get chatEmpty =>
      'Ask a question about your project, a step, an error or a technical term.';

  @override
  String get chatClear => 'Clear the conversation';

  @override
  String get chatContextTitle => 'Context attached to the question';

  @override
  String get chatCtxProject => 'Project summary';

  @override
  String get chatCtxChecklist => 'Checklist status';

  @override
  String get chatCtxCommand => 'Last command';

  @override
  String get chatContextHelp =>
      'Only ticked items are sent, along with the latest exchanges. No project file is sent.';

  @override
  String chatModel(String model) {
    return 'Answer from $model';
  }

  @override
  String get reportStatusCompleted => 'Closed session';

  @override
  String get reportStatusActive => 'Active session';

  @override
  String get reportWriteFailed =>
      'Unable to write the report at this location.';

  @override
  String get reportSaved => 'Report saved.';

  @override
  String get reportsHistoryTitle => 'Session history';

  @override
  String reportsProgress(int done, int total) {
    return '$done / $total steps';
  }

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exported reports',
      one: '1 exported report',
    );
    return '$_temp0';
  }

  @override
  String get reportsOpen => 'Report preview';

  @override
  String reportsDetailTitle(String project, String version) {
    return 'Report: $project $version';
  }

  @override
  String reportsStepsLine(int done, int total) {
    return 'Checklist: $done of $total steps done';
  }

  @override
  String reportsFilesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files created or changed',
      one: '1 file created or changed',
      zero: 'No file changed',
    );
    return '$_temp0';
  }

  @override
  String reportsCommandsLine(int count, int checks) {
    return '$count command(s) run, including $checks test(s) or analysis(es)';
  }

  @override
  String reportsDeliverablesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deliverables',
      one: '1 deliverable',
      zero: 'No deliverable found',
    );
    return '$_temp0';
  }

  @override
  String reportsAuditLine(String title, int failures, int warnings) {
    return '$title audit: $failures problem(s), $warnings warning(s)';
  }

  @override
  String get reportsContents =>
      'The report also contains technologies and targets, commands (secrets masked), remaining actions, the manual publishing procedure and the glossary.';

  @override
  String get reportsPdfHint =>
      'Standalone HTML file: open it in a browser, then Print → Save as PDF to get a PDF.';

  @override
  String get reportsPrevious => 'Reports already exported for this session';

  @override
  String get helpManualTitle => 'Full manual';

  @override
  String get helpManualSearch => 'Search the manual';
}

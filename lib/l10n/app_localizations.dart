import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Préparer, contrôler, construire, publier.'**
  String get appTagline;

  /// No description provided for @navGroupProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet'**
  String get navGroupProject;

  /// No description provided for @navGroupTools.
  ///
  /// In fr, this message translates to:
  /// **'Outils'**
  String get navGroupTools;

  /// No description provided for @navGroupApp.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get navGroupApp;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navDetection.
  ///
  /// In fr, this message translates to:
  /// **'Détection'**
  String get navDetection;

  /// No description provided for @navPublication.
  ///
  /// In fr, this message translates to:
  /// **'Publication'**
  String get navPublication;

  /// No description provided for @navChecklist.
  ///
  /// In fr, this message translates to:
  /// **'Checklist'**
  String get navChecklist;

  /// No description provided for @navTerminal.
  ///
  /// In fr, this message translates to:
  /// **'Terminal'**
  String get navTerminal;

  /// No description provided for @navAgent.
  ///
  /// In fr, this message translates to:
  /// **'Agent'**
  String get navAgent;

  /// No description provided for @navContent.
  ///
  /// In fr, this message translates to:
  /// **'Contenus'**
  String get navContent;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get navHelp;

  /// No description provided for @navOpenMenu.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le menu de navigation'**
  String get navOpenMenu;

  /// No description provided for @navShortcutTooltip.
  ///
  /// In fr, this message translates to:
  /// **'{label} (Ctrl+{key})'**
  String navShortcutTooltip(String label, String key);

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @demoTag.
  ///
  /// In fr, this message translates to:
  /// **'DÉMO'**
  String get demoTag;

  /// No description provided for @demoBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo'**
  String get demoBannerTitle;

  /// No description provided for @demoBannerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Données fictives, clairement identifiées. Aucun projet réel n\'est lu ni modifié.'**
  String get demoBannerMessage;

  /// No description provided for @demoBannerExit.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le mode démo'**
  String get demoBannerExit;

  /// No description provided for @laterPhaseTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Disponible dans une phase ultérieure (phase {phase})'**
  String laterPhaseTooltip(int phase);

  /// No description provided for @phaseBadge.
  ///
  /// In fr, this message translates to:
  /// **'Phase {phase}'**
  String phaseBadge(int phase);

  /// No description provided for @percentValue.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String percentValue(int percent);

  /// No description provided for @levelAnalyze.
  ///
  /// In fr, this message translates to:
  /// **'Analyser'**
  String get levelAnalyze;

  /// No description provided for @levelAnalyzeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule. Aucun fichier n\'est modifié.'**
  String get levelAnalyzeDesc;

  /// No description provided for @levelPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer'**
  String get levelPrepare;

  /// No description provided for @levelPrepareDesc.
  ///
  /// In fr, this message translates to:
  /// **'Génère textes et configurations, avec un aperçu avant toute écriture.'**
  String get levelPrepareDesc;

  /// No description provided for @levelBuild.
  ///
  /// In fr, this message translates to:
  /// **'Construire'**
  String get levelBuild;

  /// No description provided for @levelBuildDesc.
  ///
  /// In fr, this message translates to:
  /// **'Compile le projet et crée les livrables.'**
  String get levelBuildDesc;

  /// No description provided for @levelPublish.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get levelPublish;

  /// No description provided for @levelPublishDesc.
  ///
  /// In fr, this message translates to:
  /// **'Envoie vers un store ou un hébergeur, uniquement après une confirmation explicite.'**
  String get levelPublishDesc;

  /// No description provided for @statusTodo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get statusTodo;

  /// No description provided for @statusRunning.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusRunning;

  /// No description provided for @statusSucceeded.
  ///
  /// In fr, this message translates to:
  /// **'Réussi'**
  String get statusSucceeded;

  /// No description provided for @statusFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get statusFailed;

  /// No description provided for @statusNeedsValidation.
  ///
  /// In fr, this message translates to:
  /// **'Validation requise'**
  String get statusNeedsValidation;

  /// No description provided for @statusPedagogical.
  ///
  /// In fr, this message translates to:
  /// **'Étape pédagogique'**
  String get statusPedagogical;

  /// No description provided for @homeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans LaunchPilot'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre un projet pour l\'analyser, préparer sa publication et comprendre chaque étape.'**
  String get homeSubtitle;

  /// No description provided for @homeOpenProject.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir un dossier de projet'**
  String get homeOpenProject;

  /// No description provided for @homeOpenProjectHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisis le dossier de ton projet. L\'analyse se fait ensuite sur ta demande, en lecture seule.'**
  String get homeOpenProjectHint;

  /// No description provided for @homeRecentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Projets récents'**
  String get homeRecentTitle;

  /// No description provided for @homeRecentEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet pour l\'instant'**
  String get homeRecentEmptyTitle;

  /// No description provided for @homeRecentEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les projets ouverts apparaîtront ici avec leur progression, leurs favoris et leur date de dernière ouverture.'**
  String get homeRecentEmptyMessage;

  /// No description provided for @homeResumeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre une session'**
  String get homeResumeTitle;

  /// No description provided for @homeResumeEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session en cours'**
  String get homeResumeEmptyTitle;

  /// No description provided for @homeResumeEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Chaque préparation de version crée une session que tu pourras reprendre plus tard.'**
  String get homeResumeEmptyMessage;

  /// No description provided for @homeResumeAction.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get homeResumeAction;

  /// No description provided for @homeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Favori'**
  String get homeFavorite;

  /// No description provided for @homeLastOpened.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert le {date}'**
  String homeLastOpened(String date);

  /// No description provided for @homeSessionStarted.
  ///
  /// In fr, this message translates to:
  /// **'Session commencée le {date}'**
  String homeSessionStarted(String date);

  /// No description provided for @homeCurrentLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau actuel : {level}'**
  String homeCurrentLevel(String level);

  /// No description provided for @homeHowTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment LaunchPilot travaille'**
  String get homeHowTitle;

  /// No description provided for @homeTryDemo.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir le mode démo'**
  String get homeTryDemo;

  /// No description provided for @homeDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Explore l\'interface avec un projet fictif, sans rien lire ni modifier sur ton disque.'**
  String get homeDemoHint;

  /// No description provided for @detectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport de détection'**
  String get detectionTitle;

  /// No description provided for @detectionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Technologies, cibles, preuves et niveau de confiance.'**
  String get detectionSubtitle;

  /// No description provided for @detectionEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Après l\'ouverture d\'un dossier, LaunchPilot listera ici ce qu\'il a reconnu et pourquoi. Tu pourras confirmer ou corriger les cibles.'**
  String get detectionEmptyMessage;

  /// No description provided for @detectionTechnologies.
  ///
  /// In fr, this message translates to:
  /// **'Technologies détectées'**
  String get detectionTechnologies;

  /// No description provided for @detectionConfidence.
  ///
  /// In fr, this message translates to:
  /// **'Confiance : {percent} %'**
  String detectionConfidence(int percent);

  /// No description provided for @detectionEvidence.
  ///
  /// In fr, this message translates to:
  /// **'Preuves'**
  String get detectionEvidence;

  /// No description provided for @detectionTargets.
  ///
  /// In fr, this message translates to:
  /// **'Cibles de publication'**
  String get detectionTargets;

  /// No description provided for @detectionTargetDetected.
  ///
  /// In fr, this message translates to:
  /// **'Détectée'**
  String get detectionTargetDetected;

  /// No description provided for @detectionTargetNotDetected.
  ///
  /// In fr, this message translates to:
  /// **'Non détectée'**
  String get detectionTargetNotDetected;

  /// No description provided for @detectionRescan.
  ///
  /// In fr, this message translates to:
  /// **'Relancer l\'analyse'**
  String get detectionRescan;

  /// No description provided for @publicationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de publication'**
  String get publicationTitle;

  /// No description provided for @publicationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quatre niveaux distincts. Tu peux t\'arrêter après chacun d\'eux.'**
  String get publicationSubtitle;

  /// No description provided for @publicationGlobalProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression globale'**
  String get publicationGlobalProgress;

  /// No description provided for @publicationNeverAuto.
  ///
  /// In fr, this message translates to:
  /// **'La publication n\'est jamais déclenchée automatiquement après un build.'**
  String get publicationNeverAuto;

  /// No description provided for @publicationStepsDone.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} étapes'**
  String publicationStepsDone(int done, int total);

  /// No description provided for @checklistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Checklist pédagogique'**
  String get checklistTitle;

  /// No description provided for @checklistSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Chaque étape explique son objectif, ses risques et comment la vérifier.'**
  String get checklistSubtitle;

  /// No description provided for @checklistEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'La checklist sera construite à partir des cibles confirmées de ton projet.'**
  String get checklistEmptyMessage;

  /// No description provided for @checklistLevelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'explication'**
  String get checklistLevelLabel;

  /// No description provided for @checklistExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Explication'**
  String get checklistExplanation;

  /// No description provided for @checklistWhy.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi c\'est nécessaire'**
  String get checklistWhy;

  /// No description provided for @checklistFiles.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers concernés'**
  String get checklistFiles;

  /// No description provided for @checklistCommands.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get checklistCommands;

  /// No description provided for @checklistExpected.
  ///
  /// In fr, this message translates to:
  /// **'Résultat attendu'**
  String get checklistExpected;

  /// No description provided for @checklistRisks.
  ///
  /// In fr, this message translates to:
  /// **'Risques'**
  String get checklistRisks;

  /// No description provided for @checklistVerification.
  ///
  /// In fr, this message translates to:
  /// **'Comment vérifier'**
  String get checklistVerification;

  /// No description provided for @checklistRollback.
  ///
  /// In fr, this message translates to:
  /// **'Comment revenir en arrière'**
  String get checklistRollback;

  /// No description provided for @checklistNoRollback.
  ///
  /// In fr, this message translates to:
  /// **'Aucun retour arrière automatique possible.'**
  String get checklistNoRollback;

  /// No description provided for @checklistShowVerify.
  ///
  /// In fr, this message translates to:
  /// **'Montre-moi comment vérifier'**
  String get checklistShowVerify;

  /// No description provided for @checklistHideVerify.
  ///
  /// In fr, this message translates to:
  /// **'Masquer la vérification'**
  String get checklistHideVerify;

  /// No description provided for @checklistRequiresConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation requise'**
  String get checklistRequiresConfirmation;

  /// No description provided for @checklistIrreversible.
  ///
  /// In fr, this message translates to:
  /// **'Irréversible'**
  String get checklistIrreversible;

  /// No description provided for @checklistRun.
  ///
  /// In fr, this message translates to:
  /// **'Exécuter l\'étape'**
  String get checklistRun;

  /// No description provided for @checklistShowDetails.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les détails'**
  String get checklistShowDetails;

  /// No description provided for @checklistHideDetails.
  ///
  /// In fr, this message translates to:
  /// **'Masquer les détails'**
  String get checklistHideDetails;

  /// No description provided for @terminalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Terminal intégré'**
  String get terminalTitle;

  /// No description provided for @terminalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sortie des commandes en direct, avec les secrets masqués.'**
  String get terminalSubtitle;

  /// No description provided for @terminalEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes validées s\'afficheront ici en direct. Chaque commande est prévisualisée avant son exécution.'**
  String get terminalEmptyMessage;

  /// No description provided for @terminalFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get terminalFilterAll;

  /// No description provided for @terminalFilterStdout.
  ///
  /// In fr, this message translates to:
  /// **'stdout'**
  String get terminalFilterStdout;

  /// No description provided for @terminalFilterStderr.
  ///
  /// In fr, this message translates to:
  /// **'stderr'**
  String get terminalFilterStderr;

  /// No description provided for @terminalCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier la sortie'**
  String get terminalCopy;

  /// No description provided for @terminalCopied.
  ///
  /// In fr, this message translates to:
  /// **'Sortie copiée dans le presse-papiers.'**
  String get terminalCopied;

  /// No description provided for @terminalStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get terminalStop;

  /// No description provided for @terminalSimulated.
  ///
  /// In fr, this message translates to:
  /// **'Sortie simulée'**
  String get terminalSimulated;

  /// No description provided for @terminalExitCode.
  ///
  /// In fr, this message translates to:
  /// **'Code de sortie : {code}'**
  String terminalExitCode(int code);

  /// No description provided for @agentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agent LaunchPilot'**
  String get agentTitle;

  /// No description provided for @agentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pose tes questions, fais reformuler une étape ou demande une aide contextualisée.'**
  String get agentSubtitle;

  /// No description provided for @agentComposerHint.
  ///
  /// In fr, this message translates to:
  /// **'Écris ta question…'**
  String get agentComposerHint;

  /// No description provided for @agentSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get agentSend;

  /// No description provided for @agentYou.
  ///
  /// In fr, this message translates to:
  /// **'Toi'**
  String get agentYou;

  /// No description provided for @agentAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Agent'**
  String get agentAssistant;

  /// No description provided for @contentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contenus et aperçus'**
  String get contentTitle;

  /// No description provided for @contentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Textes de store, icônes, captures et aperçus SEO.'**
  String get contentSubtitle;

  /// No description provided for @contentTexts.
  ///
  /// In fr, this message translates to:
  /// **'Textes de la fiche'**
  String get contentTexts;

  /// No description provided for @contentIcons.
  ///
  /// In fr, this message translates to:
  /// **'Icônes'**
  String get contentIcons;

  /// No description provided for @contentScreenshots.
  ///
  /// In fr, this message translates to:
  /// **'Captures d\'écran'**
  String get contentScreenshots;

  /// No description provided for @contentPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de la fiche'**
  String get contentPreview;

  /// No description provided for @contentIconsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Importe une icône source (1024 × 1024 minimum) pour générer les tailles Android, iOS, favicon et PWA sans déformation.'**
  String get contentIconsEmpty;

  /// No description provided for @contentScreenshotsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Importe tes captures pour vérifier leurs dimensions et choisir un cadre de présentation.'**
  String get contentScreenshotsEmpty;

  /// No description provided for @fieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get fieldTitle;

  /// No description provided for @fieldSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titre'**
  String get fieldSubtitle;

  /// No description provided for @fieldShortDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description courte'**
  String get fieldShortDescription;

  /// No description provided for @fieldKeywords.
  ///
  /// In fr, this message translates to:
  /// **'Mots-clés'**
  String get fieldKeywords;

  /// No description provided for @reportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapports et historique'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sessions passées et exports HTML/PDF.'**
  String get reportsSubtitle;

  /// No description provided for @reportsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rapport'**
  String get reportsEmptyTitle;

  /// No description provided for @reportsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Démarre une session de version sur un projet : son rapport (livrables, commandes, audits, actions restantes) pourra ensuite être exporté ici.'**
  String get reportsEmptyMessage;

  /// No description provided for @reportsExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en HTML'**
  String get reportsExport;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Apparence, langue, accompagnement et fournisseurs d\'IA.'**
  String get settingsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @settingsTextSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get settingsTextSize;

  /// No description provided for @textSizeNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get textSizeNormal;

  /// No description provided for @textSizeLarge.
  ///
  /// In fr, this message translates to:
  /// **'Grande'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In fr, this message translates to:
  /// **'Très grande'**
  String get textSizeExtraLarge;

  /// No description provided for @settingsAnimations.
  ///
  /// In fr, this message translates to:
  /// **'Animations'**
  String get settingsAnimations;

  /// No description provided for @settingsAnimationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Transitions courtes et sobres. Désactive-les si elles te gênent.'**
  String get settingsAnimationsHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsGuidance.
  ///
  /// In fr, this message translates to:
  /// **'Mode d\'accompagnement'**
  String get settingsGuidance;

  /// No description provided for @modeBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get modeBeginner;

  /// No description provided for @modeBeginnerDesc.
  ///
  /// In fr, this message translates to:
  /// **'Explications détaillées, vocabulaire défini, commandes commentées et validations fréquentes.'**
  String get modeBeginnerDesc;

  /// No description provided for @modeGuided.
  ///
  /// In fr, this message translates to:
  /// **'Accompagné'**
  String get modeGuided;

  /// No description provided for @modeGuidedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Explications condensées, actions regroupées et confirmation des modifications importantes.'**
  String get modeGuidedDesc;

  /// No description provided for @modeExpert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get modeExpert;

  /// No description provided for @modeExpertDesc.
  ///
  /// In fr, this message translates to:
  /// **'Interface plus dense et actions groupées. Les confirmations de sécurité restent obligatoires.'**
  String get modeExpertDesc;

  /// No description provided for @settingsAi.
  ///
  /// In fr, this message translates to:
  /// **'Intelligence artificielle'**
  String get settingsAi;

  /// No description provided for @settingsAiProvider.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur préféré'**
  String get settingsAiProvider;

  /// No description provided for @settingsApiKeys.
  ///
  /// In fr, this message translates to:
  /// **'Clés API'**
  String get settingsApiKeys;

  /// No description provided for @settingsApiKeysHint.
  ///
  /// In fr, this message translates to:
  /// **'Les clés sont stockées dans le trousseau du système (libsecret), jamais en clair dans un fichier. Elles ne sont jamais réaffichées.'**
  String get settingsApiKeysHint;

  /// No description provided for @apiKeyStored.
  ///
  /// In fr, this message translates to:
  /// **'Clé enregistrée'**
  String get apiKeyStored;

  /// No description provided for @apiKeyMissing.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clé'**
  String get apiKeyMissing;

  /// No description provided for @apiKeyFieldLabel.
  ///
  /// In fr, this message translates to:
  /// **'Clé API {provider}'**
  String apiKeyFieldLabel(String provider);

  /// No description provided for @apiKeyFieldReplaceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle clé API {provider}'**
  String apiKeyFieldReplaceLabel(String provider);

  /// No description provided for @apiKeySave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get apiKeySave;

  /// No description provided for @apiKeyReplace.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer'**
  String get apiKeyReplace;

  /// No description provided for @apiKeySaved.
  ///
  /// In fr, this message translates to:
  /// **'Clé {provider} enregistrée dans le trousseau.'**
  String apiKeySaved(String provider);

  /// No description provided for @apiKeyDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Clé {provider} supprimée.'**
  String apiKeyDeleted(String provider);

  /// No description provided for @apiKeyDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la clé {provider} ?'**
  String apiKeyDeleteTitle(String provider);

  /// No description provided for @apiKeyDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'La clé sera effacée du trousseau du système. Tu devras la saisir à nouveau pour utiliser ce fournisseur.'**
  String get apiKeyDeleteMessage;

  /// No description provided for @apiKeyErrorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Saisis une clé avant d\'enregistrer.'**
  String get apiKeyErrorEmpty;

  /// No description provided for @apiKeyErrorTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé semble trop courte.'**
  String get apiKeyErrorTooShort;

  /// No description provided for @apiKeyErrorTooLong.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé est trop longue.'**
  String get apiKeyErrorTooLong;

  /// No description provided for @apiKeyErrorInvalidChars.
  ///
  /// In fr, this message translates to:
  /// **'Une clé ne contient ni espace ni caractère invisible.'**
  String get apiKeyErrorInvalidChars;

  /// No description provided for @apiKeyStorageError.
  ///
  /// In fr, this message translates to:
  /// **'Le trousseau du système est verrouillé ou indisponible : LaunchPilot ne peut pas lire les clés. Déverrouille-le (application « Mots de passe et clés », ou en te reconnectant), ou vérifie que gnome-keyring est lancé, puis réessaie.'**
  String get apiKeyStorageError;

  /// No description provided for @apiKeyWhereToGet.
  ///
  /// In fr, this message translates to:
  /// **'Obtenir une clé : {url}'**
  String apiKeyWhereToGet(String url);

  /// No description provided for @settingsHosting.
  ///
  /// In fr, this message translates to:
  /// **'Hébergeurs préférés'**
  String get settingsHosting;

  /// No description provided for @settingsHostingHint.
  ///
  /// In fr, this message translates to:
  /// **'L\'hébergeur choisi ici est proposé par défaut pour chaque nouveau site ; tu peux en changer projet par projet dans Contenus → Hébergement.'**
  String get settingsHostingHint;

  /// No description provided for @settingsDemo.
  ///
  /// In fr, this message translates to:
  /// **'Mode démo'**
  String get settingsDemo;

  /// No description provided for @settingsDemoHint.
  ///
  /// In fr, this message translates to:
  /// **'Affiche un projet fictif pour découvrir l\'interface. Les données de démonstration sont toujours signalées.'**
  String get settingsDemoHint;

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyText.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot fonctionne localement. Aucun compte ni service distant n\'est nécessaire pour ouvrir l\'application.'**
  String get settingsPrivacyText;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide et lexique'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode d\'emploi, raccourcis clavier et vocabulaire technique.'**
  String get helpSubtitle;

  /// No description provided for @helpGuideTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mode d\'emploi'**
  String get helpGuideTitle;

  /// No description provided for @helpGuideStep1.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre le dossier de ton projet depuis l\'accueil.'**
  String get helpGuideStep1;

  /// No description provided for @helpGuideStep2.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie le rapport de détection et confirme les cibles.'**
  String get helpGuideStep2;

  /// No description provided for @helpGuideStep3.
  ///
  /// In fr, this message translates to:
  /// **'Suis la checklist niveau par niveau : Analyser, Préparer, Construire, Publier.'**
  String get helpGuideStep3;

  /// No description provided for @helpGuideStep4.
  ///
  /// In fr, this message translates to:
  /// **'Valide chaque action sensible après avoir lu son récapitulatif.'**
  String get helpGuideStep4;

  /// No description provided for @helpGuideStep5.
  ///
  /// In fr, this message translates to:
  /// **'Exporte le rapport final pour garder une trace.'**
  String get helpGuideStep5;

  /// No description provided for @helpGuideNote.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot 1.0.0 couvre tout le parcours : projets et sessions, détection, checklist, commandes sécurisées, contenus, web, Android, iOS via CI, chat avec l\'agent et rapports. Chaque écriture passe par un aperçu, chaque publication par une confirmation renforcée.'**
  String get helpGuideNote;

  /// No description provided for @helpShortcutsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis clavier'**
  String get helpShortcutsTitle;

  /// No description provided for @helpShortcutNav.
  ///
  /// In fr, this message translates to:
  /// **'Aller directement à un écran de la navigation'**
  String get helpShortcutNav;

  /// No description provided for @helpShortcutTab.
  ///
  /// In fr, this message translates to:
  /// **'Passer d\'un élément à l\'autre'**
  String get helpShortcutTab;

  /// No description provided for @helpShortcutActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'élément sélectionné'**
  String get helpShortcutActivate;

  /// No description provided for @helpGlossaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lexique'**
  String get helpGlossaryTitle;

  /// No description provided for @helpGlossarySearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un terme'**
  String get helpGlossarySearch;

  /// No description provided for @helpGlossaryNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun terme ne correspond à ta recherche.'**
  String get helpGlossaryNoResult;

  /// No description provided for @helpKeysTab.
  ///
  /// In fr, this message translates to:
  /// **'Tab / Maj+Tab'**
  String get helpKeysTab;

  /// No description provided for @helpKeysActivate.
  ///
  /// In fr, this message translates to:
  /// **'Entrée / Espace'**
  String get helpKeysActivate;

  /// No description provided for @homeFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get homeFilterAll;

  /// No description provided for @homeFilterFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get homeFilterFavorites;

  /// No description provided for @homeFavoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori. Clique sur l\'étoile d\'un projet pour le retrouver ici.'**
  String get homeFavoritesEmpty;

  /// No description provided for @homeAddFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get homeAddFavorite;

  /// No description provided for @homeRemoveFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get homeRemoveFavorite;

  /// No description provided for @homeOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get homeOpen;

  /// No description provided for @homeProjectMenu.
  ///
  /// In fr, this message translates to:
  /// **'Actions du projet'**
  String get homeProjectMenu;

  /// No description provided for @homeNewSession.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle session'**
  String get homeNewSession;

  /// No description provided for @homeRelocate.
  ///
  /// In fr, this message translates to:
  /// **'Relocaliser'**
  String get homeRelocate;

  /// No description provided for @homeRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de la liste'**
  String get homeRemove;

  /// No description provided for @homeFolderMissing.
  ///
  /// In fr, this message translates to:
  /// **'Dossier introuvable'**
  String get homeFolderMissing;

  /// No description provided for @homeFolderMissingHint.
  ///
  /// In fr, this message translates to:
  /// **'Le dossier a peut-être été déplacé ou supprimé. Relocalise-le ou retire le projet de la liste.'**
  String get homeFolderMissingHint;

  /// No description provided for @homeSessionActive.
  ///
  /// In fr, this message translates to:
  /// **'Session {version} en cours'**
  String homeSessionActive(String version);

  /// No description provided for @homeLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lire les données locales.'**
  String get homeLoadError;

  /// No description provided for @homeResumeSince.
  ///
  /// In fr, this message translates to:
  /// **'Dernière activité le {date}'**
  String homeResumeSince(String date);

  /// No description provided for @addProjectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un projet'**
  String get addProjectTitle;

  /// No description provided for @addProjectPathLabel.
  ///
  /// In fr, this message translates to:
  /// **'Chemin du dossier'**
  String get addProjectPathLabel;

  /// No description provided for @addProjectPathHint.
  ///
  /// In fr, this message translates to:
  /// **'~/projets/mon-app'**
  String get addProjectPathHint;

  /// No description provided for @addProjectNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom affiché (facultatif)'**
  String get addProjectNameLabel;

  /// No description provided for @addProjectPickerNote.
  ///
  /// In fr, this message translates to:
  /// **'Colle le chemin complet du dossier, ou utilise le bouton Parcourir.'**
  String get addProjectPickerNote;

  /// No description provided for @addProjectConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addProjectConfirm;

  /// No description provided for @pathErrorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Indique un chemin.'**
  String get pathErrorEmpty;

  /// No description provided for @pathErrorNotAbsolute.
  ///
  /// In fr, this message translates to:
  /// **'Indique un chemin complet, commençant par / ou ~.'**
  String get pathErrorNotAbsolute;

  /// No description provided for @pathErrorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce dossier n\'existe pas ou n\'est pas accessible.'**
  String get pathErrorNotFound;

  /// No description provided for @pathErrorAlreadyRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Ce dossier est déjà utilisé par un autre projet.'**
  String get pathErrorAlreadyRegistered;

  /// No description provided for @projectAdded.
  ///
  /// In fr, this message translates to:
  /// **'Projet « {name} » ajouté.'**
  String projectAdded(String name);

  /// No description provided for @projectAlreadyKnown.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » était déjà dans la liste : il a été rouvert.'**
  String projectAlreadyKnown(String name);

  /// No description provided for @relocateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Relocaliser « {name} »'**
  String relocateTitle(String name);

  /// No description provided for @relocateOldPath.
  ///
  /// In fr, this message translates to:
  /// **'Ancien chemin : {path}'**
  String relocateOldPath(String path);

  /// No description provided for @relocateConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Relocaliser'**
  String get relocateConfirm;

  /// No description provided for @projectRelocated.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau chemin enregistré.'**
  String get projectRelocated;

  /// No description provided for @removeProjectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer « {name} » de LaunchPilot ?'**
  String removeProjectTitle(String name);

  /// No description provided for @removeProjectMessage.
  ///
  /// In fr, this message translates to:
  /// **'Son historique local sera effacé : {sessions, plural, =0{aucune session} =1{1 session} other{{sessions} sessions}} et {steps, plural, =0{aucune étape} =1{1 étape} other{{steps} étapes}} de checklist. Les fichiers de ton projet ne sont pas touchés.'**
  String removeProjectMessage(int sessions, int steps);

  /// No description provided for @removeProjectConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get removeProjectConfirm;

  /// No description provided for @projectRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Projet retiré de la liste.'**
  String get projectRemoved;

  /// No description provided for @newSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle session pour « {name} »'**
  String newSessionTitle(String name);

  /// No description provided for @newSessionVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version préparée'**
  String get newSessionVersionLabel;

  /// No description provided for @newSessionVersionHint.
  ///
  /// In fr, this message translates to:
  /// **'1.3.0+14'**
  String get newSessionVersionHint;

  /// No description provided for @newSessionHint.
  ///
  /// In fr, this message translates to:
  /// **'Une session regroupe la préparation d\'une version : checklist, textes validés et rapports. Tu pourras la reprendre plus tard.'**
  String get newSessionHint;

  /// No description provided for @newSessionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get newSessionConfirm;

  /// No description provided for @versionErrorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Indique la version préparée.'**
  String get versionErrorEmpty;

  /// No description provided for @versionErrorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres, lettres, points, tirets, + et _ uniquement, sans espace (64 caractères maximum).'**
  String get versionErrorInvalid;

  /// No description provided for @sessionErrorActiveExists.
  ///
  /// In fr, this message translates to:
  /// **'Une session est déjà en cours pour ce projet. Reprends-la ou clos-la d\'abord.'**
  String get sessionErrorActiveExists;

  /// No description provided for @sessionStarted.
  ///
  /// In fr, this message translates to:
  /// **'Session {version} démarrée.'**
  String sessionStarted(String version);

  /// No description provided for @closeSession.
  ///
  /// In fr, this message translates to:
  /// **'Clore la session'**
  String get closeSession;

  /// No description provided for @closeSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clore la session {version} ?'**
  String closeSessionTitle(String version);

  /// No description provided for @closeSessionMessage.
  ///
  /// In fr, this message translates to:
  /// **'La session sera marquée comme terminée et ne pourra plus être reprise. Son historique est conservé.'**
  String get closeSessionMessage;

  /// No description provided for @closeSessionConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Clore'**
  String get closeSessionConfirm;

  /// No description provided for @sessionClosed.
  ///
  /// In fr, this message translates to:
  /// **'Session close.'**
  String get sessionClosed;

  /// No description provided for @publicationNoProjectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet ouvert'**
  String get publicationNoProjectTitle;

  /// No description provided for @publicationNoProjectMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre ou ajoute un projet depuis l\'accueil pour préparer sa publication.'**
  String get publicationNoProjectMessage;

  /// No description provided for @publicationGoHome.
  ///
  /// In fr, this message translates to:
  /// **'Aller à l\'accueil'**
  String get publicationGoHome;

  /// No description provided for @publicationNoSessionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session en cours pour ce projet'**
  String get publicationNoSessionTitle;

  /// No description provided for @publicationNoSessionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Démarre une session pour préparer une nouvelle version.'**
  String get publicationNoSessionMessage;

  /// No description provided for @settingsLocalData.
  ///
  /// In fr, this message translates to:
  /// **'Données locales'**
  String get settingsLocalData;

  /// No description provided for @settingsLocalDataHint.
  ///
  /// In fr, this message translates to:
  /// **'Projets, sessions et checklists sont enregistrés dans une base SQLite sur cet ordinateur. Aucune clé API n\'y figure.'**
  String get settingsLocalDataHint;

  /// No description provided for @settingsLocalDataLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement : {path}'**
  String settingsLocalDataLocation(String path);

  /// No description provided for @statProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get statProjects;

  /// No description provided for @statSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions'**
  String get statSessions;

  /// No description provided for @statSteps.
  ///
  /// In fr, this message translates to:
  /// **'Étapes de checklist'**
  String get statSteps;

  /// No description provided for @settingsClearData.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données locales'**
  String get settingsClearData;

  /// No description provided for @clearDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données locales ?'**
  String get clearDataTitle;

  /// No description provided for @clearDataMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tous les projets, sessions, checklists et rapports enregistrés par LaunchPilot seront supprimés de cet ordinateur. Les fichiers de tes projets et les clés API ne sont pas touchés. Cette action est irréversible.'**
  String get clearDataMessage;

  /// No description provided for @clearDataTypeWord.
  ///
  /// In fr, this message translates to:
  /// **'Pour confirmer, écris {word}'**
  String clearDataTypeWord(String word);

  /// No description provided for @clearDataWord.
  ///
  /// In fr, this message translates to:
  /// **'EFFACER'**
  String get clearDataWord;

  /// No description provided for @clearDataConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get clearDataConfirm;

  /// No description provided for @clearDataDone.
  ///
  /// In fr, this message translates to:
  /// **'Données locales effacées.'**
  String get clearDataDone;

  /// No description provided for @llmErrMissingKey.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clé API enregistrée pour ce fournisseur.'**
  String get llmErrMissingKey;

  /// No description provided for @llmErrInvalidKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé API refusée par le fournisseur. Vérifie-la ou remplace-la.'**
  String get llmErrInvalidKey;

  /// No description provided for @llmErrPermission.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé n\'a pas accès à cette ressource.'**
  String get llmErrPermission;

  /// No description provided for @llmErrBilling.
  ///
  /// In fr, this message translates to:
  /// **'Problème de facturation ou de quota sur le compte du fournisseur.'**
  String get llmErrBilling;

  /// No description provided for @llmErrModelNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Modèle introuvable ou non disponible pour ce compte.'**
  String get llmErrModelNotFound;

  /// No description provided for @llmErrBadRequest.
  ///
  /// In fr, this message translates to:
  /// **'Requête refusée par le fournisseur (paramètres invalides).'**
  String get llmErrBadRequest;

  /// No description provided for @llmErrTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Contenu trop volumineux pour ce fournisseur.'**
  String get llmErrTooLarge;

  /// No description provided for @llmErrRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de requêtes : réessaie dans un moment.'**
  String get llmErrRateLimited;

  /// No description provided for @llmErrOverloaded.
  ///
  /// In fr, this message translates to:
  /// **'Service du fournisseur surchargé : réessaie dans un moment.'**
  String get llmErrOverloaded;

  /// No description provided for @llmErrServer.
  ///
  /// In fr, this message translates to:
  /// **'Erreur temporaire chez le fournisseur.'**
  String get llmErrServer;

  /// No description provided for @llmErrTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réponse dans le délai imparti.'**
  String get llmErrTimeout;

  /// No description provided for @llmErrCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Requête annulée.'**
  String get llmErrCancelled;

  /// No description provided for @llmErrNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible : vérifie ton accès à Internet.'**
  String get llmErrNetwork;

  /// No description provided for @llmErrInvalidResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse inexploitable : elle ne respecte pas le format attendu.'**
  String get llmErrInvalidResponse;

  /// No description provided for @llmErrRefused.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle a refusé de répondre à cette demande.'**
  String get llmErrRefused;

  /// No description provided for @llmErrTruncated.
  ///
  /// In fr, this message translates to:
  /// **'Réponse incomplète : la limite de longueur a été atteinte.'**
  String get llmErrTruncated;

  /// No description provided for @llmErrConsent.
  ///
  /// In fr, this message translates to:
  /// **'Envoi bloqué : la confirmation ne correspond pas à ce contenu ou a déjà servi.'**
  String get llmErrConsent;

  /// No description provided for @llmErrDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail technique : {detail}'**
  String llmErrDetail(String detail);

  /// No description provided for @llmModelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get llmModelLabel;

  /// No description provided for @llmModelDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut : {model}'**
  String llmModelDefault(String model);

  /// No description provided for @llmChooseModel.
  ///
  /// In fr, this message translates to:
  /// **'Choisir parmi les modèles disponibles'**
  String get llmChooseModel;

  /// No description provided for @llmTest.
  ///
  /// In fr, this message translates to:
  /// **'Tester la connexion'**
  String get llmTest;

  /// No description provided for @llmTestCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le test'**
  String get llmTestCancel;

  /// No description provided for @llmTestOk.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie en {ms} ms · {count} modèles disponibles'**
  String llmTestOk(int ms, int count);

  /// No description provided for @llmTestModelOk.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle « {model} » est disponible.'**
  String llmTestModelOk(String model);

  /// No description provided for @llmTestModelMissing.
  ///
  /// In fr, this message translates to:
  /// **'Le modèle « {model} » n\'apparaît pas dans la liste de ce compte.'**
  String llmTestModelMissing(String model);

  /// No description provided for @settingsAiNetworkPolicy.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot ne contacte un fournisseur qu\'à ta demande. Le test de connexion liste les modèles sans consommer de jetons.'**
  String get settingsAiNetworkPolicy;

  /// No description provided for @llmTrialTitle.
  ///
  /// In fr, this message translates to:
  /// **'Essai de génération'**
  String get llmTrialTitle;

  /// No description provided for @llmTrialHint.
  ///
  /// In fr, this message translates to:
  /// **'Envoie une question fixe, sans aucune donnée de ton projet, au fournisseur préféré pour vérifier la réponse structurée. Cet essai consomme quelques jetons.'**
  String get llmTrialHint;

  /// No description provided for @llmTrialButton.
  ///
  /// In fr, this message translates to:
  /// **'Lancer un essai'**
  String get llmTrialButton;

  /// No description provided for @llmTrialNeedsKey.
  ///
  /// In fr, this message translates to:
  /// **'Enregistre d\'abord une clé pour {provider}.'**
  String llmTrialNeedsKey(String provider);

  /// No description provided for @llmTrialPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Explique en deux phrases, à une personne débutante, ce qu\'est un numéro de build dans une application mobile, puis cite trois termes techniques liés.'**
  String get llmTrialPrompt;

  /// No description provided for @llmTrialLanguage.
  ///
  /// In fr, this message translates to:
  /// **'français'**
  String get llmTrialLanguage;

  /// No description provided for @llmTrialAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Réponse'**
  String get llmTrialAnswer;

  /// No description provided for @llmTrialTerms.
  ///
  /// In fr, this message translates to:
  /// **'Termes liés'**
  String get llmTrialTerms;

  /// No description provided for @sendTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer à {provider} ?'**
  String sendTitle(String provider);

  /// No description provided for @sendModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle : {model}'**
  String sendModel(String model);

  /// No description provided for @sendSize.
  ///
  /// In fr, this message translates to:
  /// **'Environ {tokens} jetons en entrée (estimation)'**
  String sendSize(int tokens);

  /// No description provided for @sendRedactions.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun secret détecté} =1{1 secret masqué avant l\'envoi} other{{count} secrets masqués avant l\'envoi}}'**
  String sendRedactions(int count);

  /// No description provided for @sendExcluded.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers sensibles exclus : {files}'**
  String sendExcluded(String files);

  /// No description provided for @sendNoProjectData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée de ton projet n\'est incluse.'**
  String get sendNoProjectData;

  /// No description provided for @sendProjectData.
  ///
  /// In fr, this message translates to:
  /// **'Des extraits de ton projet sont inclus : relis l\'aperçu.'**
  String get sendProjectData;

  /// No description provided for @sendShowPreview.
  ///
  /// In fr, this message translates to:
  /// **'Voir exactement ce qui sera transmis'**
  String get sendShowPreview;

  /// No description provided for @sendHidePreview.
  ///
  /// In fr, this message translates to:
  /// **'Masquer l\'aperçu'**
  String get sendHidePreview;

  /// No description provided for @sendSystemLabel.
  ///
  /// In fr, this message translates to:
  /// **'Consignes'**
  String get sendSystemLabel;

  /// No description provided for @sendUserLabel.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get sendUserLabel;

  /// No description provided for @sendConsentNote.
  ///
  /// In fr, this message translates to:
  /// **'Cette confirmation ne vaut que pour cet envoi précis.'**
  String get sendConsentNote;

  /// No description provided for @sendConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get sendConfirm;

  /// No description provided for @sendInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Requête en cours…'**
  String get sendInProgress;

  /// No description provided for @sendCancelRequest.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la requête'**
  String get sendCancelRequest;

  /// No description provided for @sendDoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réponse reçue'**
  String get sendDoneTitle;

  /// No description provided for @sendUsage.
  ///
  /// In fr, this message translates to:
  /// **'{input} jetons en entrée · {output} en sortie · {seconds} s'**
  String sendUsage(int input, int output, String seconds);

  /// No description provided for @sendServedBy.
  ///
  /// In fr, this message translates to:
  /// **'Réponse produite par {model}'**
  String sendServedBy(String model);

  /// No description provided for @sendFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la requête'**
  String get sendFailedTitle;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @homeChooseFolder.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un dossier…'**
  String get homeChooseFolder;

  /// No description provided for @homeEnterPath.
  ///
  /// In fr, this message translates to:
  /// **'Saisir un chemin'**
  String get homeEnterPath;

  /// No description provided for @pickerConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Choisir ce dossier'**
  String get pickerConfirm;

  /// No description provided for @addProjectBrowse.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir…'**
  String get addProjectBrowse;

  /// No description provided for @detectionAnalyze.
  ///
  /// In fr, this message translates to:
  /// **'Analyser le projet'**
  String get detectionAnalyze;

  /// No description provided for @detectionAnalyzing.
  ///
  /// In fr, this message translates to:
  /// **'Analyse en cours…'**
  String get detectionAnalyzing;

  /// No description provided for @detectionReadOnlyNote.
  ///
  /// In fr, this message translates to:
  /// **'L\'analyse est en lecture seule : LaunchPilot lit les fichiers de configuration (pubspec.yaml, package.json, manifestes…) sans rien modifier. Les fichiers sensibles (clés, .env) ne sont jamais lus.'**
  String get detectionReadOnlyNote;

  /// No description provided for @detectionNeverScanned.
  ///
  /// In fr, this message translates to:
  /// **'Ce projet n\'a pas encore été analysé.'**
  String get detectionNeverScanned;

  /// No description provided for @detectionScannedAt.
  ///
  /// In fr, this message translates to:
  /// **'Analysé le {date} · {count} fichiers parcourus'**
  String detectionScannedAt(String date, int count);

  /// No description provided for @detectionFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'analyse a échoué : {error}'**
  String detectionFailed(String error);

  /// No description provided for @detectionPartial.
  ///
  /// In fr, this message translates to:
  /// **'Analyse partielle ({reasons}) : les résultats peuvent être incomplets.'**
  String detectionPartial(String reasons);

  /// No description provided for @partialMaxFiles.
  ///
  /// In fr, this message translates to:
  /// **'plus de 20 000 fichiers'**
  String get partialMaxFiles;

  /// No description provided for @partialMaxDepth.
  ///
  /// In fr, this message translates to:
  /// **'dossiers trop profonds'**
  String get partialMaxDepth;

  /// No description provided for @partialReadBudget.
  ///
  /// In fr, this message translates to:
  /// **'volume de lecture maximal atteint'**
  String get partialReadBudget;

  /// No description provided for @partialTimeout.
  ///
  /// In fr, this message translates to:
  /// **'durée maximale atteinte'**
  String get partialTimeout;

  /// No description provided for @partialUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'dossiers illisibles'**
  String get partialUnreadable;

  /// No description provided for @detectionNoTechnology.
  ///
  /// In fr, this message translates to:
  /// **'Aucune technologie reconnue. Vérifie que le dossier choisi est bien la racine du projet.'**
  String get detectionNoTechnology;

  /// No description provided for @detectionInformative.
  ///
  /// In fr, this message translates to:
  /// **'À titre informatif'**
  String get detectionInformative;

  /// No description provided for @detectionTargetsHint.
  ///
  /// In fr, this message translates to:
  /// **'Coche les cibles que tu veux publier. Tes choix sont conservés lors des prochaines analyses.'**
  String get detectionTargetsHint;

  /// No description provided for @detectionTargetSelected.
  ///
  /// In fr, this message translates to:
  /// **'Retenue'**
  String get detectionTargetSelected;

  /// No description provided for @detectionTargetsReviewed.
  ///
  /// In fr, this message translates to:
  /// **'Cibles validées le {date}'**
  String detectionTargetsReviewed(String date);

  /// No description provided for @detectionTargetsToReview.
  ///
  /// In fr, this message translates to:
  /// **'Cibles à valider : elles suivent la détection tant que tu ne les as pas validées.'**
  String get detectionTargetsToReview;

  /// No description provided for @detectionValidateTargets.
  ///
  /// In fr, this message translates to:
  /// **'Valider les cibles'**
  String get detectionValidateTargets;

  /// No description provided for @detectionTargetsValidated.
  ///
  /// In fr, this message translates to:
  /// **'Cibles validées.'**
  String get detectionTargetsValidated;

  /// No description provided for @detectionIosLinuxNote.
  ///
  /// In fr, this message translates to:
  /// **'Sous Linux, la construction iOS passera par une CI macOS.'**
  String get detectionIosLinuxNote;

  /// No description provided for @detectionPackages.
  ///
  /// In fr, this message translates to:
  /// **'Paquets et scripts'**
  String get detectionPackages;

  /// No description provided for @detectionNoLockFile.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier de verrouillage'**
  String get detectionNoLockFile;

  /// No description provided for @detectionNoScripts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun script déclaré'**
  String get detectionNoScripts;

  /// No description provided for @detectionGitAbsent.
  ///
  /// In fr, this message translates to:
  /// **'Pas de dépôt Git. Il est recommandé d\'en créer un avant toute modification, pour pouvoir revenir en arrière.'**
  String get detectionGitAbsent;

  /// No description provided for @detectionGitBranch.
  ///
  /// In fr, this message translates to:
  /// **'Branche : {branch}'**
  String detectionGitBranch(String branch);

  /// No description provided for @detectionGitDetached.
  ///
  /// In fr, this message translates to:
  /// **'HEAD détachée sur {commit}'**
  String detectionGitDetached(String commit);

  /// No description provided for @detectionGitTags.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun tag} =1{1 tag : {list}} other{{count} tags : {list}}}'**
  String detectionGitTags(int count, String list);

  /// No description provided for @detectionGitWorktree.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt lié (worktree ou sous-module) : détails non lus.'**
  String get detectionGitWorktree;

  /// No description provided for @detectionGitStatusLater.
  ///
  /// In fr, this message translates to:
  /// **'L\'état en direct (modifications non validées) est affiché dans le tableau de publication, section Protection du projet.'**
  String get detectionGitStatusLater;

  /// No description provided for @detectionPublishingFiles.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers de publication'**
  String get detectionPublishingFiles;

  /// No description provided for @categoryIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icônes'**
  String get categoryIcon;

  /// No description provided for @categoryScreenshot.
  ///
  /// In fr, this message translates to:
  /// **'Captures d\'écran'**
  String get categoryScreenshot;

  /// No description provided for @categoryFastlane.
  ///
  /// In fr, this message translates to:
  /// **'Fastlane'**
  String get categoryFastlane;

  /// No description provided for @categoryCi.
  ///
  /// In fr, this message translates to:
  /// **'Intégration continue'**
  String get categoryCi;

  /// No description provided for @categoryHosting.
  ///
  /// In fr, this message translates to:
  /// **'Hébergement'**
  String get categoryHosting;

  /// No description provided for @categoryPwa.
  ///
  /// In fr, this message translates to:
  /// **'PWA'**
  String get categoryPwa;

  /// No description provided for @categoryLegal.
  ///
  /// In fr, this message translates to:
  /// **'Documents juridiques'**
  String get categoryLegal;

  /// No description provided for @categorySigning.
  ///
  /// In fr, this message translates to:
  /// **'Signature'**
  String get categorySigning;

  /// No description provided for @detectionNothingFound.
  ///
  /// In fr, this message translates to:
  /// **'Rien trouvé'**
  String get detectionNothingFound;

  /// No description provided for @signingNotRead.
  ///
  /// In fr, this message translates to:
  /// **'présent, non lu'**
  String get signingNotRead;

  /// No description provided for @detectionSeo.
  ///
  /// In fr, this message translates to:
  /// **'SEO'**
  String get detectionSeo;

  /// No description provided for @seoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Balise title'**
  String get seoTitle;

  /// No description provided for @seoDescription.
  ///
  /// In fr, this message translates to:
  /// **'Meta description'**
  String get seoDescription;

  /// No description provided for @seoCanonical.
  ///
  /// In fr, this message translates to:
  /// **'URL canonique'**
  String get seoCanonical;

  /// No description provided for @seoOpenGraph.
  ///
  /// In fr, this message translates to:
  /// **'Open Graph'**
  String get seoOpenGraph;

  /// No description provided for @seoTwitterCard.
  ///
  /// In fr, this message translates to:
  /// **'Twitter Card'**
  String get seoTwitterCard;

  /// No description provided for @seoStructuredData.
  ///
  /// In fr, this message translates to:
  /// **'Données structurées (schema.org)'**
  String get seoStructuredData;

  /// No description provided for @seoRobots.
  ///
  /// In fr, this message translates to:
  /// **'robots.txt'**
  String get seoRobots;

  /// No description provided for @seoSitemap.
  ///
  /// In fr, this message translates to:
  /// **'sitemap.xml'**
  String get seoSitemap;

  /// No description provided for @detectionPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions déclarées'**
  String get detectionPermissions;

  /// No description provided for @detectionNoPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune permission détectée'**
  String get detectionNoPermissions;

  /// No description provided for @detectionServices.
  ///
  /// In fr, this message translates to:
  /// **'Services tiers'**
  String get detectionServices;

  /// No description provided for @detectionNoServices.
  ///
  /// In fr, this message translates to:
  /// **'Aucun SDK tiers détecté'**
  String get detectionNoServices;

  /// No description provided for @serviceAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get serviceAnalytics;

  /// No description provided for @serviceAds.
  ///
  /// In fr, this message translates to:
  /// **'Publicité'**
  String get serviceAds;

  /// No description provided for @serviceCrash.
  ///
  /// In fr, this message translates to:
  /// **'Rapports de plantage'**
  String get serviceCrash;

  /// No description provided for @serviceMessaging.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get serviceMessaging;

  /// No description provided for @serviceBackend.
  ///
  /// In fr, this message translates to:
  /// **'Back-end'**
  String get serviceBackend;

  /// No description provided for @servicePayments.
  ///
  /// In fr, this message translates to:
  /// **'Paiements'**
  String get servicePayments;

  /// No description provided for @detectionSensitive.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers sensibles repérés et non lus : {files}'**
  String detectionSensitive(String files);

  /// No description provided for @riskReadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Lecture seule'**
  String get riskReadOnly;

  /// No description provided for @riskLocal.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers générés'**
  String get riskLocal;

  /// No description provided for @riskSensitive.
  ///
  /// In fr, this message translates to:
  /// **'Modifie le projet'**
  String get riskSensitive;

  /// No description provided for @riskForbidden.
  ///
  /// In fr, this message translates to:
  /// **'Interdite'**
  String get riskForbidden;

  /// No description provided for @riskReadOnlyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ne modifie rien. S\'exécute même en mode simulation.'**
  String get riskReadOnlyDesc;

  /// No description provided for @riskLocalDesc.
  ///
  /// In fr, this message translates to:
  /// **'Écrit seulement des fichiers générés dans le projet (build, dépendances, cache).'**
  String get riskLocalDesc;

  /// No description provided for @riskSensitiveDesc.
  ///
  /// In fr, this message translates to:
  /// **'Modifie des fichiers du projet ou l\'état Git : relis bien avant de confirmer.'**
  String get riskSensitiveDesc;

  /// No description provided for @riskForbiddenDesc.
  ///
  /// In fr, this message translates to:
  /// **'Refusée par les garde-fous de LaunchPilot.'**
  String get riskForbiddenDesc;

  /// No description provided for @issueNotAllowlisted.
  ///
  /// In fr, this message translates to:
  /// **'Outil hors de la liste autorisée (git, flutter, dart, npm, pnpm, yarn, bun, node).'**
  String get issueNotAllowlisted;

  /// No description provided for @issueShell.
  ///
  /// In fr, this message translates to:
  /// **'Les shells sont interdits : LaunchPilot n\'exécute jamais de chaîne interprétée.'**
  String get issueShell;

  /// No description provided for @issuePrivileged.
  ///
  /// In fr, this message translates to:
  /// **'Les commandes privilégiées (sudo…) sont interdites.'**
  String get issuePrivileged;

  /// No description provided for @issueInvalidExecutable.
  ///
  /// In fr, this message translates to:
  /// **'Indique seulement le nom de l\'outil, sans chemin.'**
  String get issueInvalidExecutable;

  /// No description provided for @issueInvalidArgument.
  ///
  /// In fr, this message translates to:
  /// **'Argument invalide (retour à la ligne ou caractère nul).'**
  String get issueInvalidArgument;

  /// No description provided for @issueOutsideProject.
  ///
  /// In fr, this message translates to:
  /// **'Un argument désigne un chemin hors du projet.'**
  String get issueOutsideProject;

  /// No description provided for @issueWorkingDirectoryOutside.
  ///
  /// In fr, this message translates to:
  /// **'Le dossier de travail doit se trouver dans le projet.'**
  String get issueWorkingDirectoryOutside;

  /// No description provided for @issuePublication.
  ///
  /// In fr, this message translates to:
  /// **'La publication passe par un flux dédié, avec confirmation renforcée.'**
  String get issuePublication;

  /// No description provided for @issueGitPush.
  ///
  /// In fr, this message translates to:
  /// **'L\'envoi vers un dépôt distant (push) est interdit ici.'**
  String get issueGitPush;

  /// No description provided for @issueDestructive.
  ///
  /// In fr, this message translates to:
  /// **'Opération destructrice ou irréversible : interdite. Les restaurations passent par le mécanisme ciblé de LaunchPilot.'**
  String get issueDestructive;

  /// No description provided for @issueSystemChange.
  ///
  /// In fr, this message translates to:
  /// **'Modification de la configuration ou du système : interdite.'**
  String get issueSystemChange;

  /// No description provided for @issueGlobalInstall.
  ///
  /// In fr, this message translates to:
  /// **'Les installations globales sont interdites.'**
  String get issueGlobalInstall;

  /// No description provided for @issueRemoteCode.
  ///
  /// In fr, this message translates to:
  /// **'Exécution de code téléchargé ou arbitraire : interdite.'**
  String get issueRemoteCode;

  /// No description provided for @issueUnknownSubcommand.
  ///
  /// In fr, this message translates to:
  /// **'Sous-commande non reconnue par la politique de sécurité : refusée par prudence.'**
  String get issueUnknownSubcommand;

  /// No description provided for @issueRunsProjectScript.
  ///
  /// In fr, this message translates to:
  /// **'Exécute un script défini par le projet : vérifie son contenu (package.json).'**
  String get issueRunsProjectScript;

  /// No description provided for @issueCreatesTag.
  ///
  /// In fr, this message translates to:
  /// **'Crée un tag Git : confirmation renforcée.'**
  String get issueCreatesTag;

  /// No description provided for @cmdPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de la commande'**
  String get cmdPreviewTitle;

  /// No description provided for @cmdWorkingDir.
  ///
  /// In fr, this message translates to:
  /// **'Dossier : {path}'**
  String cmdWorkingDir(String path);

  /// No description provided for @cmdSimulationNote.
  ///
  /// In fr, this message translates to:
  /// **'Mode simulation : cette commande sera seulement prévisualisée, pas exécutée.'**
  String get cmdSimulationNote;

  /// No description provided for @cmdRun.
  ///
  /// In fr, this message translates to:
  /// **'Exécuter'**
  String get cmdRun;

  /// No description provided for @cmdSimulate.
  ///
  /// In fr, this message translates to:
  /// **'Simuler'**
  String get cmdSimulate;

  /// No description provided for @cmdConfirmReinforced.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai relu le récapitulatif et je confirme cette action.'**
  String get cmdConfirmReinforced;

  /// No description provided for @cmdNoShellNote.
  ///
  /// In fr, this message translates to:
  /// **'Les opérateurs |, &&, > … n\'ont aucun effet : aucune commande ne passe par un shell.'**
  String get cmdNoShellNote;

  /// No description provided for @cmdParseError.
  ///
  /// In fr, this message translates to:
  /// **'Guillemet non fermé.'**
  String get cmdParseError;

  /// No description provided for @terminalSimulationOn.
  ///
  /// In fr, this message translates to:
  /// **'Mode simulation actif : seules les commandes en lecture seule s\'exécutent.'**
  String get terminalSimulationOn;

  /// No description provided for @terminalSimulationOff.
  ///
  /// In fr, this message translates to:
  /// **'Mode simulation désactivé : les commandes confirmées s\'exécutent réellement.'**
  String get terminalSimulationOff;

  /// No description provided for @terminalSimulationToggle.
  ///
  /// In fr, this message translates to:
  /// **'Mode simulation'**
  String get terminalSimulationToggle;

  /// No description provided for @terminalQuick.
  ///
  /// In fr, this message translates to:
  /// **'Commandes proposées'**
  String get terminalQuick;

  /// No description provided for @terminalCustom.
  ///
  /// In fr, this message translates to:
  /// **'Commande personnalisée'**
  String get terminalCustom;

  /// No description provided for @terminalCustomHint.
  ///
  /// In fr, this message translates to:
  /// **'git log --oneline -n 20'**
  String get terminalCustomHint;

  /// No description provided for @terminalPreview.
  ///
  /// In fr, this message translates to:
  /// **'Prévisualiser'**
  String get terminalPreview;

  /// No description provided for @terminalDuration.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String terminalDuration(String seconds);

  /// No description provided for @terminalHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get terminalHistory;

  /// No description provided for @terminalHistoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande exécutée pour ce projet.'**
  String get terminalHistoryEmpty;

  /// No description provided for @terminalNoOutput.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sortie.'**
  String get terminalNoOutput;

  /// No description provided for @terminalTruncated.
  ///
  /// In fr, this message translates to:
  /// **'Début de la sortie tronqué (sortie très longue).'**
  String get terminalTruncated;

  /// No description provided for @terminalStartFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lancer « {exe} » : vérifie qu\'il est installé et dans le PATH.'**
  String terminalStartFailed(String exe);

  /// No description provided for @runSucceeded.
  ///
  /// In fr, this message translates to:
  /// **'Réussie'**
  String get runSucceeded;

  /// No description provided for @runFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get runFailed;

  /// No description provided for @runCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get runCancelled;

  /// No description provided for @runTimedOut.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé'**
  String get runTimedOut;

  /// No description provided for @runBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloquée'**
  String get runBlocked;

  /// No description provided for @runSimulated.
  ///
  /// In fr, this message translates to:
  /// **'Simulée'**
  String get runSimulated;

  /// No description provided for @runStartFailed.
  ///
  /// In fr, this message translates to:
  /// **'Lancement impossible'**
  String get runStartFailed;

  /// No description provided for @protectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Protection du projet'**
  String get protectionTitle;

  /// No description provided for @protectionNoGit.
  ///
  /// In fr, this message translates to:
  /// **'Pas de dépôt Git : LaunchPilot sauvegarde quand même chaque fichier avant de le modifier, mais un dépôt Git est vivement recommandé.'**
  String get protectionNoGit;

  /// No description provided for @protectionClean.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt propre : aucune modification non validée.'**
  String get protectionClean;

  /// No description provided for @protectionDirty.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 modification non validée} other{{count} modifications non validées}}'**
  String protectionDirty(int count);

  /// No description provided for @protectionDirtyHint.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot ne touchera jamais à tes modifications. Pense à les valider (commit) ou à travailler sur une branche dédiée.'**
  String get protectionDirtyHint;

  /// No description provided for @protectionDetached.
  ///
  /// In fr, this message translates to:
  /// **'HEAD détachée'**
  String get protectionDetached;

  /// No description provided for @protectionRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get protectionRefresh;

  /// No description provided for @protectionCreateBranch.
  ///
  /// In fr, this message translates to:
  /// **'Créer la branche {name}'**
  String protectionCreateBranch(String name);

  /// No description provided for @protectionOnBranch.
  ///
  /// In fr, this message translates to:
  /// **'Tu travailles sur la branche {name}.'**
  String protectionOnBranch(String name);

  /// No description provided for @protectionGitignoreTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers sensibles non ignorés par Git'**
  String get protectionGitignoreTitle;

  /// No description provided for @protectionGitignoreHint.
  ///
  /// In fr, this message translates to:
  /// **'Ils pourraient être versionnés par erreur : {files}'**
  String protectionGitignoreHint(String files);

  /// No description provided for @protectionGitignoreAction.
  ///
  /// In fr, this message translates to:
  /// **'Préparer l\'ajout au .gitignore'**
  String get protectionGitignoreAction;

  /// No description provided for @protectionGitignoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Protection des fichiers sensibles'**
  String get protectionGitignoreLabel;

  /// No description provided for @protectionChanges.
  ///
  /// In fr, this message translates to:
  /// **'Modifications faites par LaunchPilot'**
  String get protectionChanges;

  /// No description provided for @protectionChangesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot n\'a encore modifié aucun fichier de ce projet.'**
  String get protectionChangesEmpty;

  /// No description provided for @protectionRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get protectionRestore;

  /// No description provided for @protectionRestored.
  ///
  /// In fr, this message translates to:
  /// **'Restauré le {date}'**
  String protectionRestored(String date);

  /// No description provided for @changeCreated.
  ///
  /// In fr, this message translates to:
  /// **'créé'**
  String get changeCreated;

  /// No description provided for @changeModified.
  ///
  /// In fr, this message translates to:
  /// **'modifié'**
  String get changeModified;

  /// No description provided for @restoreDone.
  ///
  /// In fr, this message translates to:
  /// **'Fichier restauré.'**
  String get restoreDone;

  /// No description provided for @restoreConflict.
  ///
  /// In fr, this message translates to:
  /// **'Restauration refusée : le fichier a été modifié depuis. Tes changements sont conservés.'**
  String get restoreConflict;

  /// No description provided for @restoreBackupMissing.
  ///
  /// In fr, this message translates to:
  /// **'Copie de sauvegarde introuvable : restauration impossible.'**
  String get restoreBackupMissing;

  /// No description provided for @writePreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu des modifications'**
  String get writePreviewTitle;

  /// No description provided for @writeFileNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau fichier'**
  String get writeFileNew;

  /// No description provided for @writeDirtyWarning.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Le dépôt contient 1 modification non validée.} other{Le dépôt contient {count} modifications non validées.}} LaunchPilot n\'y touchera pas ; ses propres changements pourront être annulés fichier par fichier.'**
  String writeDirtyWarning(int count);

  /// No description provided for @writeBackupNote.
  ///
  /// In fr, this message translates to:
  /// **'Une copie de chaque fichier est sauvegardée avant l\'écriture, pour pouvoir le restaurer.'**
  String get writeBackupNote;

  /// No description provided for @writeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Écrire les fichiers'**
  String get writeConfirm;

  /// No description provided for @writeDone.
  ///
  /// In fr, this message translates to:
  /// **'Modifications écrites.'**
  String get writeDone;

  /// No description provided for @writeChangedSincePreview.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier a changé depuis l\'aperçu : rien n\'a été écrit. Relance l\'aperçu.'**
  String get writeChangedSincePreview;

  /// No description provided for @writeRefused.
  ///
  /// In fr, this message translates to:
  /// **'Écriture refusée : {path}'**
  String writeRefused(String path);

  /// No description provided for @writeTooBig.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop grand pour l\'aperçu ligne à ligne.'**
  String get writeTooBig;

  /// No description provided for @settingsExecution.
  ///
  /// In fr, this message translates to:
  /// **'Exécution des commandes'**
  String get settingsExecution;

  /// No description provided for @settingsSimulationHint.
  ///
  /// In fr, this message translates to:
  /// **'Activé : seules les commandes en lecture seule (git status, flutter analyze…) s\'exécutent ; les autres sont seulement prévisualisées. Les commandes interdites (push, publication, suppression…) restent refusées dans tous les cas.'**
  String get settingsSimulationHint;

  /// No description provided for @checklistBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloquée'**
  String get checklistBlocked;

  /// No description provided for @checklistBlockedBy.
  ///
  /// In fr, this message translates to:
  /// **'Termine d\'abord : {steps}'**
  String checklistBlockedBy(String steps);

  /// No description provided for @checklistLaterPhase.
  ///
  /// In fr, this message translates to:
  /// **'Automatisation prévue en phase {phase} : d\'ici là, suis les explications et marque l\'étape comme faite.'**
  String checklistLaterPhase(int phase);

  /// No description provided for @checklistGlossary.
  ///
  /// In fr, this message translates to:
  /// **'Termes'**
  String get checklistGlossary;

  /// No description provided for @kindCommand.
  ///
  /// In fr, this message translates to:
  /// **'Commande'**
  String get kindCommand;

  /// No description provided for @kindManual.
  ///
  /// In fr, this message translates to:
  /// **'Vérification'**
  String get kindManual;

  /// No description provided for @kindPedagogical.
  ///
  /// In fr, this message translates to:
  /// **'À comprendre'**
  String get kindPedagogical;

  /// No description provided for @checklistDone.
  ///
  /// In fr, this message translates to:
  /// **'C\'est vérifié'**
  String get checklistDone;

  /// No description provided for @checklistUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris'**
  String get checklistUnderstood;

  /// No description provided for @checklistReset.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer'**
  String get checklistReset;

  /// No description provided for @checklistNeedsDetectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Projet pas encore analysé'**
  String get checklistNeedsDetectionTitle;

  /// No description provided for @checklistNeedsDetectionMessage.
  ///
  /// In fr, this message translates to:
  /// **'La checklist est construite à partir du rapport de détection et des cibles retenues.'**
  String get checklistNeedsDetectionMessage;

  /// No description provided for @checklistGoDetection.
  ///
  /// In fr, this message translates to:
  /// **'Aller à la détection'**
  String get checklistGoDetection;

  /// No description provided for @checklistTargetsNotReviewed.
  ///
  /// In fr, this message translates to:
  /// **'Cibles pas encore validées : la checklist suit la détection.'**
  String get checklistTargetsNotReviewed;

  /// No description provided for @checklistActiveTargets.
  ///
  /// In fr, this message translates to:
  /// **'Cibles : {list}'**
  String checklistActiveTargets(String list);

  /// No description provided for @checklistNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine étape : {title}'**
  String checklistNext(String title);

  /// No description provided for @checklistAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les étapes sont terminées.'**
  String get checklistAllDone;

  /// No description provided for @checklistRunOk.
  ///
  /// In fr, this message translates to:
  /// **'Étape réussie.'**
  String get checklistRunOk;

  /// No description provided for @checklistRunFailed.
  ///
  /// In fr, this message translates to:
  /// **'La commande a échoué : la sortie est dans le terminal.'**
  String get checklistRunFailed;

  /// No description provided for @checklistSimulated.
  ///
  /// In fr, this message translates to:
  /// **'Commande simulée : l\'étape reste à faire. Désactive le mode simulation pour l\'exécuter vraiment.'**
  String get checklistSimulated;

  /// No description provided for @checklistOpenTerminal.
  ///
  /// In fr, this message translates to:
  /// **'Voir la sortie'**
  String get checklistOpenTerminal;

  /// No description provided for @contentTabVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get contentTabVersion;

  /// No description provided for @contentTabChangelog.
  ///
  /// In fr, this message translates to:
  /// **'Changelog'**
  String get contentTabChangelog;

  /// No description provided for @contentTabTexts.
  ///
  /// In fr, this message translates to:
  /// **'Textes'**
  String get contentTabTexts;

  /// No description provided for @contentTabLegal.
  ///
  /// In fr, this message translates to:
  /// **'Juridique'**
  String get contentTabLegal;

  /// No description provided for @contentNeedsProject.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre un projet pour préparer sa version, ses icônes, ses captures, ses textes et ses documents juridiques.'**
  String get contentNeedsProject;

  /// No description provided for @contentNeedsSession.
  ///
  /// In fr, this message translates to:
  /// **'Démarre une session (tableau de publication) pour enregistrer ces contenus.'**
  String get contentNeedsSession;

  /// No description provided for @contentPreviewWrite.
  ///
  /// In fr, this message translates to:
  /// **'Prévisualiser et écrire'**
  String get contentPreviewWrite;

  /// No description provided for @versionNoManifest.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier de version trouvé (pubspec.yaml ou package.json).'**
  String get versionNoManifest;

  /// No description provided for @versionNoLine.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier ne contient pas de ligne « version ».'**
  String get versionNoLine;

  /// No description provided for @versionCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Version actuelle : {version}'**
  String versionCurrent(String version);

  /// No description provided for @versionUnparsable.
  ///
  /// In fr, this message translates to:
  /// **'Format « {version} » non reconnu : saisis la nouvelle version à la main.'**
  String versionUnparsable(String version);

  /// No description provided for @versionBumpMajor.
  ///
  /// In fr, this message translates to:
  /// **'Majeure'**
  String get versionBumpMajor;

  /// No description provided for @versionBumpMinor.
  ///
  /// In fr, this message translates to:
  /// **'Mineure'**
  String get versionBumpMinor;

  /// No description provided for @versionBumpPatch.
  ///
  /// In fr, this message translates to:
  /// **'Correctif'**
  String get versionBumpPatch;

  /// No description provided for @versionBumpNone.
  ///
  /// In fr, this message translates to:
  /// **'Build seul'**
  String get versionBumpNone;

  /// No description provided for @versionBumpHelp.
  ///
  /// In fr, this message translates to:
  /// **'Majeure : changement incompatible · Mineure : nouveauté · Correctif : correction.'**
  String get versionBumpHelp;

  /// No description provided for @versionIncrementBuild.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter le numéro de build'**
  String get versionIncrementBuild;

  /// No description provided for @versionCustom.
  ///
  /// In fr, this message translates to:
  /// **'Ou saisir la version'**
  String get versionCustom;

  /// No description provided for @versionProposed.
  ///
  /// In fr, this message translates to:
  /// **'{from} → {to}'**
  String versionProposed(String from, String to);

  /// No description provided for @versionUseSession.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la version de la session ({version})'**
  String versionUseSession(String version);

  /// No description provided for @versionInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Version invalide : utilise le format 1.2.3 ou 1.2.3+4.'**
  String get versionInvalid;

  /// No description provided for @versionNotHigher.
  ///
  /// In fr, this message translates to:
  /// **'Attention : cette version n\'est pas supérieure à l\'actuelle.'**
  String get versionNotHigher;

  /// No description provided for @versionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @changelogRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire les commits'**
  String get changelogRead;

  /// No description provided for @changelogSinceTag.
  ///
  /// In fr, this message translates to:
  /// **'{count} commits depuis {tag}'**
  String changelogSinceTag(int count, String tag);

  /// No description provided for @changelogLimited.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tag trouvé : les {count} derniers commits'**
  String changelogLimited(int count);

  /// No description provided for @changelogNoGit.
  ///
  /// In fr, this message translates to:
  /// **'Pas de dépôt Git : écris le changelog à la main.'**
  String get changelogNoGit;

  /// No description provided for @changelogTechnical.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get changelogTechnical;

  /// No description provided for @changelogPublic.
  ///
  /// In fr, this message translates to:
  /// **'Grand public'**
  String get changelogPublic;

  /// No description provided for @changelogPublicFallback.
  ///
  /// In fr, this message translates to:
  /// **'Améliorations et corrections diverses.'**
  String get changelogPublicFallback;

  /// No description provided for @changelogGroupBreaking.
  ///
  /// In fr, this message translates to:
  /// **'Changements importants'**
  String get changelogGroupBreaking;

  /// No description provided for @changelogGroupFeatures.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get changelogGroupFeatures;

  /// No description provided for @changelogGroupFixes.
  ///
  /// In fr, this message translates to:
  /// **'Corrections'**
  String get changelogGroupFixes;

  /// No description provided for @changelogGroupPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performances'**
  String get changelogGroupPerformance;

  /// No description provided for @changelogGroupDocs.
  ///
  /// In fr, this message translates to:
  /// **'Documentation'**
  String get changelogGroupDocs;

  /// No description provided for @changelogGroupOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres changements'**
  String get changelogGroupOther;

  /// No description provided for @changelogAi.
  ///
  /// In fr, this message translates to:
  /// **'Reformuler avec l\'IA'**
  String get changelogAi;

  /// No description provided for @changelogAiInstruction.
  ///
  /// In fr, this message translates to:
  /// **'Reformule ces messages de commit en deux changelogs Markdown pour la version {version} : « technical » pour les développeurs, « public » simple et sans jargon pour le grand public. Commence chacun par « ## {version} ». N\'invente aucun changement.'**
  String changelogAiInstruction(String version);

  /// No description provided for @changelogWrite.
  ///
  /// In fr, this message translates to:
  /// **'Écrire dans CHANGELOG.md'**
  String get changelogWrite;

  /// No description provided for @changelogTag.
  ///
  /// In fr, this message translates to:
  /// **'Créer le tag {tag}'**
  String changelogTag(String tag);

  /// No description provided for @changelogTagNote.
  ///
  /// In fr, this message translates to:
  /// **'Le tag reste local : LaunchPilot ne pousse jamais vers un dépôt distant.'**
  String get changelogTagNote;

  /// No description provided for @changelogEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commit à résumer.'**
  String get changelogEmpty;

  /// No description provided for @iconsChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'image source'**
  String get iconsChoose;

  /// No description provided for @iconsSourceInfo.
  ///
  /// In fr, this message translates to:
  /// **'{name} · {width} × {height} px'**
  String iconsSourceInfo(String name, int width, int height);

  /// No description provided for @iconsIssueTooSmall.
  ///
  /// In fr, this message translates to:
  /// **'Image trop petite : 512 px minimum, 1024 px recommandés.'**
  String get iconsIssueTooSmall;

  /// No description provided for @iconsIssueBelowRecommended.
  ///
  /// In fr, this message translates to:
  /// **'Moins de 1024 px : les grandes icônes pourraient être floues.'**
  String get iconsIssueBelowRecommended;

  /// No description provided for @iconsIssueNotSquare.
  ///
  /// In fr, this message translates to:
  /// **'Image non carrée : elle sera centrée sur un fond transparent, jamais étirée.'**
  String get iconsIssueNotSquare;

  /// No description provided for @iconsIssueTransparent.
  ///
  /// In fr, this message translates to:
  /// **'Zones transparentes : remplies par la couleur de fond pour les icônes opaques (App Store).'**
  String get iconsIssueTransparent;

  /// No description provided for @iconsIssueUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Image illisible.'**
  String get iconsIssueUnreadable;

  /// No description provided for @iconsBackground.
  ///
  /// In fr, this message translates to:
  /// **'Couleur de fond (icônes opaques et maskables)'**
  String get iconsBackground;

  /// No description provided for @iconsTargets.
  ///
  /// In fr, this message translates to:
  /// **'{count} fichiers à produire'**
  String iconsTargets(int count);

  /// No description provided for @iconsNoTarget.
  ///
  /// In fr, this message translates to:
  /// **'Aucune cible avec icônes : retiens Android, iOS ou Web dans la détection.'**
  String get iconsNoTarget;

  /// No description provided for @iconsGenerate.
  ///
  /// In fr, this message translates to:
  /// **'Générer les icônes'**
  String get iconsGenerate;

  /// No description provided for @iconsGenerating.
  ///
  /// In fr, this message translates to:
  /// **'Génération…'**
  String get iconsGenerating;

  /// No description provided for @iconsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Icônes de l\'application'**
  String get iconsLabel;

  /// No description provided for @shotsImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer des captures'**
  String get shotsImport;

  /// No description provided for @slotPlay.
  ///
  /// In fr, this message translates to:
  /// **'Play Store'**
  String get slotPlay;

  /// No description provided for @slotIphone69.
  ///
  /// In fr, this message translates to:
  /// **'iPhone 6,9\"'**
  String get slotIphone69;

  /// No description provided for @slotIphone65.
  ///
  /// In fr, this message translates to:
  /// **'iPhone 6,5\"'**
  String get slotIphone65;

  /// No description provided for @slotIpad13.
  ///
  /// In fr, this message translates to:
  /// **'iPad 13\"'**
  String get slotIpad13;

  /// No description provided for @shotsMask.
  ///
  /// In fr, this message translates to:
  /// **'Masquer des zones'**
  String get shotsMask;

  /// No description provided for @shotsMaskCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune zone masquée} =1{1 zone masquée} other{{count} zones masquées}}'**
  String shotsMaskCount(int count);

  /// No description provided for @shotsMaskHelp.
  ///
  /// In fr, this message translates to:
  /// **'Fais glisser sur l\'image pour recouvrir une donnée personnelle (nom, e-mail, numéro…). Le recouvrement est définitif dans l\'export.'**
  String get shotsMaskHelp;

  /// No description provided for @shotsMaskClear.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get shotsMaskClear;

  /// No description provided for @shotsMaskApply.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get shotsMaskApply;

  /// No description provided for @shotsRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get shotsRemove;

  /// No description provided for @shotsCaption.
  ///
  /// In fr, this message translates to:
  /// **'Légende'**
  String get shotsCaption;

  /// No description provided for @shotsFrame.
  ///
  /// In fr, this message translates to:
  /// **'Cadre'**
  String get shotsFrame;

  /// No description provided for @frameNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get frameNone;

  /// No description provided for @frameIndigo.
  ///
  /// In fr, this message translates to:
  /// **'Indigo'**
  String get frameIndigo;

  /// No description provided for @frameLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get frameLight;

  /// No description provided for @frameSunset.
  ///
  /// In fr, this message translates to:
  /// **'Coucher de soleil'**
  String get frameSunset;

  /// No description provided for @shotsFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format d\'export'**
  String get shotsFormat;

  /// No description provided for @formatPlay.
  ///
  /// In fr, this message translates to:
  /// **'Play Store 1080 × 1920'**
  String get formatPlay;

  /// No description provided for @formatIphone.
  ///
  /// In fr, this message translates to:
  /// **'iPhone 1290 × 2796'**
  String get formatIphone;

  /// No description provided for @formatIpad.
  ///
  /// In fr, this message translates to:
  /// **'iPad 2048 × 2732'**
  String get formatIpad;

  /// No description provided for @shotsExport.
  ///
  /// In fr, this message translates to:
  /// **'Préparer l\'export'**
  String get shotsExport;

  /// No description provided for @shotsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Captures pour les stores'**
  String get shotsLabel;

  /// No description provided for @textsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue de la fiche'**
  String get textsLanguage;

  /// No description provided for @textsPitch.
  ///
  /// In fr, this message translates to:
  /// **'Décris l\'application en une phrase'**
  String get textsPitch;

  /// No description provided for @textsPitchHint.
  ///
  /// In fr, this message translates to:
  /// **'Une app météo locale, simple et sans publicité.'**
  String get textsPitchHint;

  /// No description provided for @textsAi.
  ///
  /// In fr, this message translates to:
  /// **'Générer avec l\'IA'**
  String get textsAi;

  /// No description provided for @textsAiInstruction.
  ///
  /// In fr, this message translates to:
  /// **'Rédige la fiche de store de l\'application « {app} » en {language}. Description : {pitch}. Respecte strictement les limites : titre et sous-titre 30 caractères, description courte 80, mots-clés 100 (séparés par des virgules), texte promotionnel 170, description longue 4000. N\'invente aucune fonctionnalité absente de la description.'**
  String textsAiInstruction(String app, String language, String pitch);

  /// No description provided for @fieldLongDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description longue'**
  String get fieldLongDescription;

  /// No description provided for @fieldPromoText.
  ///
  /// In fr, this message translates to:
  /// **'Texte promotionnel'**
  String get fieldPromoText;

  /// No description provided for @textsCounter.
  ///
  /// In fr, this message translates to:
  /// **'{count} / {limit}'**
  String textsCounter(int count, int limit);

  /// No description provided for @textsSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les textes'**
  String get textsSave;

  /// No description provided for @textsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Textes enregistrés dans la session.'**
  String get textsSaved;

  /// No description provided for @textsOverLimit.
  ///
  /// In fr, this message translates to:
  /// **'Certains champs dépassent la limite des stores.'**
  String get textsOverLimit;

  /// No description provided for @textsPreviewStore.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de la fiche'**
  String get textsPreviewStore;

  /// No description provided for @textsPreviewSocial.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de partage'**
  String get textsPreviewSocial;

  /// No description provided for @textsNote.
  ///
  /// In fr, this message translates to:
  /// **'Les textes sont gardés dans la session ; leur envoi aux stores viendra avec Fastlane (phase 9).'**
  String get textsNote;

  /// No description provided for @legalDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Ces documents sont des modèles générés à partir de tes réponses. Ils ne garantissent pas la conformité juridique : relis-les, complète-les et fais-les valider par un professionnel si nécessaire.'**
  String get legalDisclaimer;

  /// No description provided for @legalPublisherType.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur'**
  String get legalPublisherType;

  /// No description provided for @publisherIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Particulier'**
  String get publisherIndividual;

  /// No description provided for @publisherCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get publisherCompany;

  /// No description provided for @legalAppName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'application'**
  String get legalAppName;

  /// No description provided for @legalPublisherName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'éditeur'**
  String get legalPublisherName;

  /// No description provided for @legalAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get legalAddress;

  /// No description provided for @legalEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail de contact'**
  String get legalEmail;

  /// No description provided for @legalCompanyId.
  ///
  /// In fr, this message translates to:
  /// **'SIREN / SIRET'**
  String get legalCompanyId;

  /// No description provided for @legalHostName.
  ///
  /// In fr, this message translates to:
  /// **'Hébergeur'**
  String get legalHostName;

  /// No description provided for @legalHostAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de l\'hébergeur'**
  String get legalHostAddress;

  /// No description provided for @legalData.
  ///
  /// In fr, this message translates to:
  /// **'Données collectées'**
  String get legalData;

  /// No description provided for @dataContact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get dataContact;

  /// No description provided for @dataLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get dataLocation;

  /// No description provided for @dataPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos / caméra'**
  String get dataPhotos;

  /// No description provided for @dataAudio.
  ///
  /// In fr, this message translates to:
  /// **'Audio'**
  String get dataAudio;

  /// No description provided for @dataContacts.
  ///
  /// In fr, this message translates to:
  /// **'Carnet de contacts'**
  String get dataContacts;

  /// No description provided for @dataUsage.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques d\'usage'**
  String get dataUsage;

  /// No description provided for @dataCrash.
  ///
  /// In fr, this message translates to:
  /// **'Rapports de plantage'**
  String get dataCrash;

  /// No description provided for @dataAdId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant publicitaire'**
  String get dataAdId;

  /// No description provided for @dataPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement'**
  String get dataPayment;

  /// No description provided for @legalPrefilled.
  ///
  /// In fr, this message translates to:
  /// **'Préremplies d\'après la détection : vérifie-les.'**
  String get legalPrefilled;

  /// No description provided for @legalThirdParties.
  ///
  /// In fr, this message translates to:
  /// **'Services tiers'**
  String get legalThirdParties;

  /// No description provided for @legalAddThirdParty.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un service'**
  String get legalAddThirdParty;

  /// No description provided for @legalRetention.
  ///
  /// In fr, this message translates to:
  /// **'Conservation : {months} mois'**
  String legalRetention(int months);

  /// No description provided for @legalCookies.
  ///
  /// In fr, this message translates to:
  /// **'Le site utilise des cookies de mesure ou de publicité'**
  String get legalCookies;

  /// No description provided for @legalMinors.
  ///
  /// In fr, this message translates to:
  /// **'L\'application s\'adresse aussi aux moins de 15 ans'**
  String get legalMinors;

  /// No description provided for @legalMissing.
  ///
  /// In fr, this message translates to:
  /// **'À compléter : {fields}'**
  String legalMissing(String fields);

  /// No description provided for @legalSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les réponses'**
  String get legalSave;

  /// No description provided for @legalSaved.
  ///
  /// In fr, this message translates to:
  /// **'Réponses enregistrées.'**
  String get legalSaved;

  /// No description provided for @legalDocLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue des documents'**
  String get legalDocLanguage;

  /// No description provided for @legalGenerate.
  ///
  /// In fr, this message translates to:
  /// **'Générer les modèles'**
  String get legalGenerate;

  /// No description provided for @legalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Documents juridiques (modèles)'**
  String get legalLabel;

  /// No description provided for @checklistOpenTool.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir l\'outil'**
  String get checklistOpenTool;

  /// No description provided for @writeBinary.
  ///
  /// In fr, this message translates to:
  /// **'Fichier binaire · {size} octets'**
  String writeBinary(int size);

  /// No description provided for @writeImageBefore.
  ///
  /// In fr, this message translates to:
  /// **'Avant'**
  String get writeImageBefore;

  /// No description provided for @writeImageAfter.
  ///
  /// In fr, this message translates to:
  /// **'Après'**
  String get writeImageAfter;

  /// No description provided for @issueProductionDeploy.
  ///
  /// In fr, this message translates to:
  /// **'Mise en ligne publique : confirmation renforcée.'**
  String get issueProductionDeploy;

  /// No description provided for @issuePreviewDeploy.
  ///
  /// In fr, this message translates to:
  /// **'Mise en ligne sur une adresse de prévisualisation : confirmation renforcée.'**
  String get issuePreviewDeploy;

  /// No description provided for @issueNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Interroge le site en ligne et écrit un rapport dans le projet.'**
  String get issueNetwork;

  /// No description provided for @commonCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié dans le presse-papiers.'**
  String get commonCopied;

  /// No description provided for @auditAreaResponsive.
  ///
  /// In fr, this message translates to:
  /// **'Affichage mobile'**
  String get auditAreaResponsive;

  /// No description provided for @auditAreaAccessibility.
  ///
  /// In fr, this message translates to:
  /// **'Accessibilité'**
  String get auditAreaAccessibility;

  /// No description provided for @auditAreaLinks.
  ///
  /// In fr, this message translates to:
  /// **'Liens'**
  String get auditAreaLinks;

  /// No description provided for @auditAreaForms.
  ///
  /// In fr, this message translates to:
  /// **'Formulaires'**
  String get auditAreaForms;

  /// No description provided for @auditAreaErrors.
  ///
  /// In fr, this message translates to:
  /// **'Pages d\'erreur'**
  String get auditAreaErrors;

  /// No description provided for @webGapNoScript.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande de build déclarée par le projet (script « build » absent) : LaunchPilot n\'en invente pas. Ajoute-en une dans package.json, ou indique le dossier déjà prêt à mettre en ligne.'**
  String get webGapNoScript;

  /// No description provided for @webGapServer.
  ///
  /// In fr, this message translates to:
  /// **'Ce framework rend les pages côté serveur : il n\'y a pas de dossier statique à déposer. Utilise l\'intégration Git de Vercel ou Netlify, ou configure un export statique.'**
  String get webGapServer;

  /// No description provided for @webNoPlan.
  ///
  /// In fr, this message translates to:
  /// **'Aucun site web reconnu dans ce projet. Lance l\'analyse ou vérifie la cible Web dans le rapport de détection.'**
  String get webNoPlan;

  /// No description provided for @webBuildTitle.
  ///
  /// In fr, this message translates to:
  /// **'Construction'**
  String get webBuildTitle;

  /// No description provided for @webFramework.
  ///
  /// In fr, this message translates to:
  /// **'Technologie : {name}'**
  String webFramework(String name);

  /// No description provided for @webOutputDir.
  ///
  /// In fr, this message translates to:
  /// **'Dossier de sortie (relatif au projet)'**
  String get webOutputDir;

  /// No description provided for @webOutputGuessed.
  ///
  /// In fr, this message translates to:
  /// **'Convention du framework, non confirmée : vérifie-la puis valide avec Entrée.'**
  String get webOutputGuessed;

  /// No description provided for @webOutputReady.
  ///
  /// In fr, this message translates to:
  /// **'Le dossier de sortie contient index.html.'**
  String get webOutputReady;

  /// No description provided for @webOutputMissing.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de index.html dans le dossier de sortie : construis le site.'**
  String get webOutputMissing;

  /// No description provided for @webBuild.
  ///
  /// In fr, this message translates to:
  /// **'Construire (aperçu de la commande)'**
  String get webBuild;

  /// No description provided for @webAuditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audit du site'**
  String get webAuditTitle;

  /// No description provided for @webAuditHelp.
  ///
  /// In fr, this message translates to:
  /// **'Contrôles statiques, sans réseau : SEO, affichage mobile, PWA, accessibilité, liens internes, contenu mixte, formulaires et page 404.'**
  String get webAuditHelp;

  /// No description provided for @webAuditOutput.
  ///
  /// In fr, this message translates to:
  /// **'Site construit'**
  String get webAuditOutput;

  /// No description provided for @webAuditSources.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get webAuditSources;

  /// No description provided for @webAuditRun.
  ///
  /// In fr, this message translates to:
  /// **'Lancer l\'audit'**
  String get webAuditRun;

  /// No description provided for @webAuditNoFolder.
  ///
  /// In fr, this message translates to:
  /// **'Ce dossier n\'existe pas encore.'**
  String get webAuditNoFolder;

  /// No description provided for @webAuditSummary.
  ///
  /// In fr, this message translates to:
  /// **'{failures} problème(s), {warnings} avertissement(s), {ok} contrôle(s) réussi(s)'**
  String webAuditSummary(int failures, int warnings, int ok);

  /// No description provided for @webAuditTruncated.
  ///
  /// In fr, this message translates to:
  /// **'Site volumineux : seule une partie a été examinée.'**
  String get webAuditTruncated;

  /// No description provided for @webAuditLimits.
  ///
  /// In fr, this message translates to:
  /// **'L\'audit lit les fichiers : il ne remplace ni un test sur de vrais appareils, ni Lighthouse, ni la vérification des liens externes.'**
  String get webAuditLimits;

  /// No description provided for @webPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu local'**
  String get webPreviewTitle;

  /// No description provided for @webPreviewHelp.
  ///
  /// In fr, this message translates to:
  /// **'Sert le dossier de sortie sur ta machine uniquement (127.0.0.1), pour le tester dans un navigateur ou avec Lighthouse.'**
  String get webPreviewHelp;

  /// No description provided for @webServeStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer l\'aperçu'**
  String get webServeStart;

  /// No description provided for @webServeStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter l\'aperçu'**
  String get webServeStop;

  /// No description provided for @webPreviewChecks.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier à la main : affichage sur mobile (mode responsive du navigateur), navigation, formulaires, page 404 et mode hors ligne.'**
  String get webPreviewChecks;

  /// No description provided for @webLighthouseMissing.
  ///
  /// In fr, this message translates to:
  /// **'Lighthouse n\'est pas installé : c\'est facultatif. Pour l\'ajouter (Node.js et Chrome ou Chromium requis), lance dans ton propre terminal :'**
  String get webLighthouseMissing;

  /// No description provided for @webLighthouseHelp.
  ///
  /// In fr, this message translates to:
  /// **'Mesure performance, accessibilité, bonnes pratiques et SEO d\'une adresse (aperçu local ou site en ligne). Le rapport est écrit dans lighthouse-report.json, à la racine du projet.'**
  String get webLighthouseHelp;

  /// No description provided for @webLighthouseUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse à auditer'**
  String get webLighthouseUrl;

  /// No description provided for @webLighthouseRun.
  ///
  /// In fr, this message translates to:
  /// **'Lancer Lighthouse'**
  String get webLighthouseRun;

  /// No description provided for @webLighthouseRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire le dernier rapport'**
  String get webLighthouseRead;

  /// No description provided for @webLighthouseUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'Le rapport Lighthouse est illisible.'**
  String get webLighthouseUnreadable;

  /// No description provided for @seoLabel.
  ///
  /// In fr, this message translates to:
  /// **'SEO'**
  String get seoLabel;

  /// No description provided for @seoAnalyticsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get seoAnalyticsLabel;

  /// No description provided for @seoHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations décrivent le site aux moteurs de recherche et aux réseaux sociaux. LaunchPilot prépare les balises, robots.txt, sitemap.xml et les données schema.org ; tu vois chaque modification avant écriture.'**
  String get seoHelp;

  /// No description provided for @seoSiteUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse publique du site'**
  String get seoSiteUrl;

  /// No description provided for @seoSiteUrlInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide : elle doit commencer par https:// et contenir un domaine.'**
  String get seoSiteUrlInvalid;

  /// No description provided for @seoSiteName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du site'**
  String get seoSiteName;

  /// No description provided for @seoImage.
  ///
  /// In fr, this message translates to:
  /// **'Image de partage (adresse complète)'**
  String get seoImage;

  /// No description provided for @seoImageHint.
  ///
  /// In fr, this message translates to:
  /// **'Conseillé : 1200 × 630 px, publiée sur le site (par exemple dans le dossier public).'**
  String get seoImageHint;

  /// No description provided for @seoTwitter.
  ///
  /// In fr, this message translates to:
  /// **'Compte X / Twitter (facultatif)'**
  String get seoTwitter;

  /// No description provided for @seoLocale.
  ///
  /// In fr, this message translates to:
  /// **'Langue et pays (Open Graph)'**
  String get seoLocale;

  /// No description provided for @seoSchema.
  ///
  /// In fr, this message translates to:
  /// **'Type schema.org'**
  String get seoSchema;

  /// No description provided for @seoSchemaWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get seoSchemaWebsite;

  /// No description provided for @seoSchemaApp.
  ///
  /// In fr, this message translates to:
  /// **'Application web'**
  String get seoSchemaApp;

  /// No description provided for @seoSchemaOrg.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get seoSchemaOrg;

  /// No description provided for @seoExtraPaths.
  ///
  /// In fr, this message translates to:
  /// **'Autres pages du sitemap (une par ligne)'**
  String get seoExtraPaths;

  /// No description provided for @seoSpaNote.
  ///
  /// In fr, this message translates to:
  /// **'Application monopage : le sitemap contient l\'accueil. Ajoute les autres routes publiques ensuite si besoin.'**
  String get seoSpaNote;

  /// No description provided for @seoFiles.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers concernés : {files}'**
  String seoFiles(String files);

  /// No description provided for @seoManagedHead.
  ///
  /// In fr, this message translates to:
  /// **'Ce framework génère lui-même <head> : LaunchPilot ne modifie pas ses fichiers. Recopie ces balises dans la configuration de tête de page (metadata, useHead…).'**
  String get seoManagedHead;

  /// No description provided for @seoNeedsUrl.
  ///
  /// In fr, this message translates to:
  /// **'Indique d\'abord l\'adresse publique du site.'**
  String get seoNeedsUrl;

  /// No description provided for @seoPreviewSearch.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu dans un moteur de recherche'**
  String get seoPreviewSearch;

  /// No description provided for @seoPreviewSocial.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de partage'**
  String get seoPreviewSocial;

  /// No description provided for @seoPreviewNoImage.
  ///
  /// In fr, this message translates to:
  /// **'Aucune image de partage'**
  String get seoPreviewNoImage;

  /// No description provided for @seoAnalyticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques respectueuses de la vie privée'**
  String get seoAnalyticsTitle;

  /// No description provided for @seoAnalyticsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Plausible et Umami mesurent la fréquentation sans cookie ni donnée personnelle revendue. Il te faut un compte (ou ta propre instance) ; LaunchPilot ajoute seulement le script à la page.'**
  String get seoAnalyticsHelp;

  /// No description provided for @seoAnalyticsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get seoAnalyticsNone;

  /// No description provided for @seoAnalyticsScript.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du script (facultatif, instance auto-hébergée)'**
  String get seoAnalyticsScript;

  /// No description provided for @seoAnalyticsUmamiId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant du site Umami (website ID)'**
  String get seoAnalyticsUmamiId;

  /// No description provided for @seoAnalyticsLegal.
  ///
  /// In fr, this message translates to:
  /// **'Pense à le mentionner dans la politique de confidentialité (outil Juridique).'**
  String get seoAnalyticsLegal;

  /// No description provided for @seoAnalyticsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à la page (aperçu)'**
  String get seoAnalyticsAdd;

  /// No description provided for @seoAnalyticsRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer les statistiques (aperçu)'**
  String get seoAnalyticsRemove;

  /// No description provided for @pwaLabel.
  ///
  /// In fr, this message translates to:
  /// **'PWA'**
  String get pwaLabel;

  /// No description provided for @pwaHelp.
  ///
  /// In fr, this message translates to:
  /// **'Une PWA s\'installe comme une application depuis le navigateur. Le manifeste décrit son nom, ses couleurs et ses icônes ; le service worker (facultatif) permet le mode hors ligne.'**
  String get pwaHelp;

  /// No description provided for @pwaName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get pwaName;

  /// No description provided for @pwaShortName.
  ///
  /// In fr, this message translates to:
  /// **'Nom court'**
  String get pwaShortName;

  /// No description provided for @pwaShortNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Affiché sous l\'icône : 12 caractères au plus conseillés.'**
  String get pwaShortNameHint;

  /// No description provided for @pwaDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get pwaDescription;

  /// No description provided for @pwaThemeColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur de thème'**
  String get pwaThemeColor;

  /// No description provided for @pwaBackgroundColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur de fond (écran de lancement)'**
  String get pwaBackgroundColor;

  /// No description provided for @pwaColorInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Format attendu : #RRGGBB'**
  String get pwaColorInvalid;

  /// No description provided for @pwaDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Mode d\'affichage'**
  String get pwaDisplay;

  /// No description provided for @pwaIconsOk.
  ///
  /// In fr, this message translates to:
  /// **'Icônes 192 et 512 px présentes.'**
  String get pwaIconsOk;

  /// No description provided for @pwaIconsMissing.
  ///
  /// In fr, this message translates to:
  /// **'Icônes 192 et 512 px absentes : génère-les avec l\'outil Icônes.'**
  String get pwaIconsMissing;

  /// No description provided for @pwaWorker.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un service worker hors ligne'**
  String get pwaWorker;

  /// No description provided for @pwaWorkerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Crée sw.js (pages en réseau d\'abord avec repli hors ligne, fichiers en cache) et l\'enregistre dans la page.'**
  String get pwaWorkerHelp;

  /// No description provided for @pwaWorkerFlutter.
  ///
  /// In fr, this message translates to:
  /// **'Le service worker automatique de Flutter est déprécié. Celui-ci le remplace : construis ensuite avec « --pwa-strategy=none » si ta version de Flutter le propose encore, pour éviter deux workers.'**
  String get pwaWorkerFlutter;

  /// No description provided for @pwaOfflineTest.
  ///
  /// In fr, this message translates to:
  /// **'Pour tester : construis, démarre l\'aperçu local, ouvre les outils de développement → Application → cocher « Offline », puis recharge la page.'**
  String get pwaOfflineTest;

  /// No description provided for @pwaProblems.
  ///
  /// In fr, this message translates to:
  /// **'À corriger : {fields}'**
  String pwaProblems(String fields);

  /// No description provided for @hostingGapFirebase.
  ///
  /// In fr, this message translates to:
  /// **'Indique l\'identifiant du projet Firebase (visible dans la console Firebase).'**
  String get hostingGapFirebase;

  /// No description provided for @hostingGapGithub.
  ///
  /// In fr, this message translates to:
  /// **'Indique le dépôt GitHub sous la forme utilisateur/depot.'**
  String get hostingGapGithub;

  /// No description provided for @hostingGapBuild.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande de build connue : le workflow GitHub ne saurait pas construire le site.'**
  String get hostingGapBuild;

  /// No description provided for @hostingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Hébergement {host}'**
  String hostingLabel(String host);

  /// No description provided for @hostingChoose.
  ///
  /// In fr, this message translates to:
  /// **'Hébergeur'**
  String get hostingChoose;

  /// No description provided for @hostingChooseHelp.
  ///
  /// In fr, this message translates to:
  /// **'Choisis où publier le site. Ton choix par défaut se règle dans les Paramètres.'**
  String get hostingChooseHelp;

  /// No description provided for @hostingFirebaseProject.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant du projet Firebase'**
  String get hostingFirebaseProject;

  /// No description provided for @hostingNetlifySite.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou identifiant du site Netlify (facultatif si le dossier est lié)'**
  String get hostingNetlifySite;

  /// No description provided for @hostingGithubRepo.
  ///
  /// In fr, this message translates to:
  /// **'Dépôt GitHub (utilisateur/depot)'**
  String get hostingGithubRepo;

  /// No description provided for @hostingDomain.
  ///
  /// In fr, this message translates to:
  /// **'Domaine personnalisé (facultatif)'**
  String get hostingDomain;

  /// No description provided for @hostingInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Format invalide.'**
  String get hostingInvalid;

  /// No description provided for @hostingFiles.
  ///
  /// In fr, this message translates to:
  /// **'Fichiers préparés : {files}'**
  String hostingFiles(String files);

  /// No description provided for @hostingPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer la configuration (aperçu)'**
  String get hostingPrepare;

  /// No description provided for @hostingDeployTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise en ligne'**
  String get hostingDeployTitle;

  /// No description provided for @hostingGithubDeploy.
  ///
  /// In fr, this message translates to:
  /// **'GitHub Pages publie le site à chaque push sur main, grâce au workflow préparé ci-dessus. LaunchPilot ne pousse jamais : valide (commit) puis pousse toi-même, puis dans GitHub → Settings → Pages, choisis « GitHub Actions » comme source.'**
  String get hostingGithubDeploy;

  /// No description provided for @hostingCliMissing.
  ///
  /// In fr, this message translates to:
  /// **'L\'outil « {cli} » n\'est pas installé. Installe-le dans ton propre terminal (installation globale, jamais lancée par LaunchPilot) :'**
  String hostingCliMissing(String cli);

  /// No description provided for @hostingLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à ton compte : lance « {command} » dans ton propre terminal. LaunchPilot ne voit ni ne stocke tes identifiants.'**
  String hostingLogin(String command);

  /// No description provided for @hostingVercelLink.
  ///
  /// In fr, this message translates to:
  /// **'Au premier déploiement, Vercel peut demander de lier le dossier à un projet : lance « vercel link » dans ton terminal si la commande échoue.'**
  String get hostingVercelLink;

  /// No description provided for @hostingNetlifyLink.
  ///
  /// In fr, this message translates to:
  /// **'Sans nom de site, Netlify utilise le site lié au dossier (« netlify link » dans ton terminal).'**
  String get hostingNetlifyLink;

  /// No description provided for @hostingBuildFirst.
  ///
  /// In fr, this message translates to:
  /// **'Construis d\'abord le site (onglet Site web) : le dossier de sortie ne contient pas index.html.'**
  String get hostingBuildFirst;

  /// No description provided for @hostingDeployNote.
  ///
  /// In fr, this message translates to:
  /// **'Chaque mise en ligne passe par un récapitulatif à cocher, puis par l\'aperçu de la commande avec confirmation renforcée. En mode simulation, rien n\'est publié.'**
  String get hostingDeployNote;

  /// No description provided for @hostingDeployPreview.
  ///
  /// In fr, this message translates to:
  /// **'Déployer en prévisualisation'**
  String get hostingDeployPreview;

  /// No description provided for @hostingDeployProduction.
  ///
  /// In fr, this message translates to:
  /// **'Déployer en production'**
  String get hostingDeployProduction;

  /// No description provided for @hostingDnsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Domaine et DNS'**
  String get hostingDnsTitle;

  /// No description provided for @hostingDnsNever.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot ne modifie jamais le DNS : saisis toi-même ces enregistrements chez le gestionnaire de ton domaine.'**
  String get hostingDnsNever;

  /// No description provided for @hostingDnsNeedsDomain.
  ///
  /// In fr, this message translates to:
  /// **'Indique un domaine personnalisé pour voir les enregistrements recommandés.'**
  String get hostingDnsNeedsDomain;

  /// No description provided for @hostingDnsFirebase.
  ///
  /// In fr, this message translates to:
  /// **'Firebase fournit des valeurs propres à ton projet : console Firebase → Hosting → Ajouter un domaine personnalisé, puis recopie les enregistrements indiqués.'**
  String get hostingDnsFirebase;

  /// No description provided for @hostingDnsVercel.
  ///
  /// In fr, this message translates to:
  /// **'Valeurs générales de Vercel. Vercel peut recommander des valeurs propres à ton projet : vérifie dans le tableau de bord (Domains) ou avec « vercel domains inspect ».'**
  String get hostingDnsVercel;

  /// No description provided for @hostingDnsNetlify.
  ///
  /// In fr, this message translates to:
  /// **'Netlify ne gère pas l\'IPv6 sur cette adresse : supprime tout enregistrement AAAA du domaine racine. Si ton gestionnaire le permet, préfère un ALIAS vers apex-loadbalancer.netlify.com.'**
  String get hostingDnsNetlify;

  /// No description provided for @hostingDnsGithub.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute aussi le domaine dans GitHub → Settings → Pages (le fichier CNAME est préparé avec la configuration), puis active « Enforce HTTPS ».'**
  String get hostingDnsGithub;

  /// No description provided for @hostingDnsPropagation.
  ///
  /// In fr, this message translates to:
  /// **'La propagation peut prendre jusqu\'à 24 heures.'**
  String get hostingDnsPropagation;

  /// No description provided for @hostingDnsCheck.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier la résolution'**
  String get hostingDnsCheck;

  /// No description provided for @hostingDnsNone.
  ///
  /// In fr, this message translates to:
  /// **'Le domaine ne se résout pas encore.'**
  String get hostingDnsNone;

  /// No description provided for @hostingDnsResolved.
  ///
  /// In fr, this message translates to:
  /// **'Le domaine pointe vers : {addresses}'**
  String hostingDnsResolved(String addresses);

  /// No description provided for @hostingOnlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en ligne'**
  String get hostingOnlineTitle;

  /// No description provided for @hostingOnlineHelp.
  ///
  /// In fr, this message translates to:
  /// **'Interroge l\'adresse publique du site : réponse en HTTPS, redirection depuis HTTP et en-tête HSTS.'**
  String get hostingOnlineHelp;

  /// No description provided for @hostingOnlineCheck.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le site en ligne'**
  String get hostingOnlineCheck;

  /// No description provided for @hostingHttpsFailed.
  ///
  /// In fr, this message translates to:
  /// **'HTTPS inaccessible ({error}).'**
  String hostingHttpsFailed(String error);

  /// No description provided for @hostingHttpsStatus.
  ///
  /// In fr, this message translates to:
  /// **'HTTPS répond (code {code}).'**
  String hostingHttpsStatus(int code);

  /// No description provided for @hostingRedirectUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Redirection HTTP → HTTPS non vérifiable.'**
  String get hostingRedirectUnknown;

  /// No description provided for @hostingRedirectOk.
  ///
  /// In fr, this message translates to:
  /// **'HTTP redirige vers HTTPS.'**
  String get hostingRedirectOk;

  /// No description provided for @hostingRedirectMissing.
  ///
  /// In fr, this message translates to:
  /// **'HTTP ne redirige pas vers HTTPS.'**
  String get hostingRedirectMissing;

  /// No description provided for @hostingHstsOk.
  ///
  /// In fr, this message translates to:
  /// **'En-tête HSTS présent.'**
  String get hostingHstsOk;

  /// No description provided for @hostingHstsMissing.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'en-tête HSTS (facultatif, renforce HTTPS).'**
  String get hostingHstsMissing;

  /// No description provided for @deployRecapProd.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif : mise en production'**
  String get deployRecapProd;

  /// No description provided for @deployRecapPreview.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif : prévisualisation'**
  String get deployRecapPreview;

  /// No description provided for @deployRecapHost.
  ///
  /// In fr, this message translates to:
  /// **'Hébergeur : {host}'**
  String deployRecapHost(String host);

  /// No description provided for @deployRecapProject.
  ///
  /// In fr, this message translates to:
  /// **'Projet : {name}'**
  String deployRecapProject(String name);

  /// No description provided for @deployRecapFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier publié : {folder}'**
  String deployRecapFolder(String folder);

  /// No description provided for @deployRecapProdEffect.
  ///
  /// In fr, this message translates to:
  /// **'Le site public sera remplacé par ce contenu, visible par tous.'**
  String get deployRecapProdEffect;

  /// No description provided for @deployRecapPreviewEffect.
  ///
  /// In fr, this message translates to:
  /// **'Une adresse temporaire, accessible à quiconque la connaît, sera créée.'**
  String get deployRecapPreviewEffect;

  /// No description provided for @deployRecapDirty.
  ///
  /// In fr, this message translates to:
  /// **'Le dépôt contient des modifications non validées : le site publié ne correspondra à aucun commit.'**
  String get deployRecapDirty;

  /// No description provided for @deployRecapSimulation.
  ///
  /// In fr, this message translates to:
  /// **'Mode simulation actif : la commande sera seulement prévisualisée, rien ne sera publié.'**
  String get deployRecapSimulation;

  /// No description provided for @deployRecapAck.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai relu ce récapitulatif et je veux publier.'**
  String get deployRecapAck;

  /// No description provided for @deployRecapContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers l\'aperçu de la commande'**
  String get deployRecapContinue;

  /// No description provided for @contentTabWeb.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get contentTabWeb;

  /// No description provided for @contentTabHosting.
  ///
  /// In fr, this message translates to:
  /// **'Hébergement'**
  String get contentTabHosting;

  /// No description provided for @contentWebNotSelected.
  ///
  /// In fr, this message translates to:
  /// **'La cible Web n\'est pas retenue pour ce projet : coche-la dans le rapport de détection pour utiliser cet outil.'**
  String get contentWebNotSelected;

  /// No description provided for @settingsPreferredHost.
  ///
  /// In fr, this message translates to:
  /// **'Hébergeur proposé par défaut'**
  String get settingsPreferredHost;

  /// No description provided for @settingsHostNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get settingsHostNone;

  /// No description provided for @settingsAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques proposées pour les sites'**
  String get settingsAnalytics;

  /// No description provided for @webSeoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre (balise <title>)'**
  String get webSeoTitle;

  /// No description provided for @webSeoDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get webSeoDescription;

  /// No description provided for @issueStorePublication.
  ///
  /// In fr, this message translates to:
  /// **'Envoi vers Google Play : confirmation renforcée.'**
  String get issueStorePublication;

  /// No description provided for @androidAreaIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get androidAreaIdentity;

  /// No description provided for @androidAreaVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get androidAreaVersion;

  /// No description provided for @androidAreaSdk.
  ///
  /// In fr, this message translates to:
  /// **'Versions d\'Android'**
  String get androidAreaSdk;

  /// No description provided for @androidAreaSigning.
  ///
  /// In fr, this message translates to:
  /// **'Signature'**
  String get androidAreaSigning;

  /// No description provided for @androidAreaSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get androidAreaSecurity;

  /// No description provided for @androidAreaPermissions.
  ///
  /// In fr, this message translates to:
  /// **'Permissions'**
  String get androidAreaPermissions;

  /// No description provided for @androidAreaIcons.
  ///
  /// In fr, this message translates to:
  /// **'Icônes'**
  String get androidAreaIcons;

  /// No description provided for @androidNoModule.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier android dans ce projet Flutter : génère-le avec « flutter create --platforms=android . » dans ton terminal.'**
  String get androidNoModule;

  /// No description provided for @androidEnvTitle.
  ///
  /// In fr, this message translates to:
  /// **'Environnement Android'**
  String get androidEnvTitle;

  /// No description provided for @androidEnvHelp.
  ///
  /// In fr, this message translates to:
  /// **'Vérifie le SDK Android, Java et les licences avec « flutter doctor -v » (lecture seule). Les versions de Gradle, du plugin Android et de Kotlin sont lues dans le projet.'**
  String get androidEnvHelp;

  /// No description provided for @androidToolVersions.
  ///
  /// In fr, this message translates to:
  /// **'Gradle {gradle} · plugin Android {agp} · Kotlin {kotlin}'**
  String androidToolVersions(String gradle, String agp, String kotlin);

  /// No description provided for @androidDoctor.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'environnement (flutter doctor -v)'**
  String get androidDoctor;

  /// No description provided for @androidDoctorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune section Android dans la sortie : le SDK Android n\'est peut-être pas installé.'**
  String get androidDoctorEmpty;

  /// No description provided for @androidJava.
  ///
  /// In fr, this message translates to:
  /// **'Java : {version}'**
  String androidJava(String version);

  /// No description provided for @androidLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Pour accepter les licences, lance « flutter doctor --android-licenses » dans ton propre terminal (questions interactives).'**
  String get androidLicenses;

  /// No description provided for @androidAuditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audit Android'**
  String get androidAuditTitle;

  /// No description provided for @androidAuditHelp.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant, version, API cible, signature, sécurité, permissions (confrontées aux plugins du projet) et icônes. Les fichiers de signature ne sont jamais lus.'**
  String get androidAuditHelp;

  /// No description provided for @androidAuditRun.
  ///
  /// In fr, this message translates to:
  /// **'Lancer l\'audit Android'**
  String get androidAuditRun;

  /// No description provided for @androidDataSafety.
  ///
  /// In fr, this message translates to:
  /// **'Les permissions et SDK détectés alimentent la section « Sécurité des données » de la Play Console et le questionnaire juridique (outil Juridique).'**
  String get androidDataSafety;

  /// No description provided for @androidSigningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Clé de signature'**
  String get androidSigningTitle;

  /// No description provided for @androidSigningHelp.
  ///
  /// In fr, this message translates to:
  /// **'Chaque version publiée est signée avec ta clé d\'envoi (keystore). Tu la crées une seule fois dans ton terminal : les mots de passe ne passent jamais par LaunchPilot, qui ne lit ni key.properties ni le keystore.'**
  String get androidSigningHelp;

  /// No description provided for @androidKeyPropertiesPresent.
  ///
  /// In fr, this message translates to:
  /// **'android/key.properties est présent (non lu).'**
  String get androidKeyPropertiesPresent;

  /// No description provided for @androidKeyPropertiesMissing.
  ///
  /// In fr, this message translates to:
  /// **'android/key.properties est absent.'**
  String get androidKeyPropertiesMissing;

  /// No description provided for @androidKeytoolStep.
  ///
  /// In fr, this message translates to:
  /// **'1. Créer le keystore (dans ton terminal, hors du projet)'**
  String get androidKeytoolStep;

  /// No description provided for @androidKeyPropertiesStep.
  ///
  /// In fr, this message translates to:
  /// **'2. Créer android/key.properties (à remplir toi-même)'**
  String get androidKeyPropertiesStep;

  /// No description provided for @androidPlayAppSigning.
  ///
  /// In fr, this message translates to:
  /// **'Avec la signature d\'application Play (activée par défaut), Google garde la clé finale ; ta clé ne sert qu\'à l\'envoi et peut être réinitialisée si tu la perds. Sauvegarde-la quand même hors du projet.'**
  String get androidPlayAppSigning;

  /// No description provided for @androidSigningConfigure.
  ///
  /// In fr, this message translates to:
  /// **'3. Configurer la signature release (aperçu)'**
  String get androidSigningConfigure;

  /// No description provided for @androidGitignore.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer les secrets de signature (aperçu)'**
  String get androidGitignore;

  /// No description provided for @androidGitignoreDone.
  ///
  /// In fr, this message translates to:
  /// **'Le .gitignore contient déjà ces entrées.'**
  String get androidGitignoreDone;

  /// No description provided for @androidGitignoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Secrets de signature Android'**
  String get androidGitignoreLabel;

  /// No description provided for @androidSigningLabel.
  ///
  /// In fr, this message translates to:
  /// **'Signature release Android'**
  String get androidSigningLabel;

  /// No description provided for @androidSigningAlready.
  ///
  /// In fr, this message translates to:
  /// **'La signature release est déjà configurée.'**
  String get androidSigningAlready;

  /// No description provided for @androidSigningUnrecognized.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier ne ressemble pas au modèle Flutter : LaunchPilot ne le modifie pas. Recopie cet extrait à la main.'**
  String get androidSigningUnrecognized;

  /// No description provided for @androidBuildTitle.
  ///
  /// In fr, this message translates to:
  /// **'Construction'**
  String get androidBuildTitle;

  /// No description provided for @androidBuildHelp.
  ///
  /// In fr, this message translates to:
  /// **'L\'App Bundle (.aab) est le format exigé par Google Play. L\'APK sert aux tests ou à une distribution hors store ; « par architecture » produit des fichiers plus légers.'**
  String get androidBuildHelp;

  /// No description provided for @androidBuildAab.
  ///
  /// In fr, this message translates to:
  /// **'Construire l\'App Bundle'**
  String get androidBuildAab;

  /// No description provided for @androidBuildApk.
  ///
  /// In fr, this message translates to:
  /// **'Construire l\'APK'**
  String get androidBuildApk;

  /// No description provided for @androidSplitPerAbi.
  ///
  /// In fr, this message translates to:
  /// **'Un APK par architecture'**
  String get androidSplitPerAbi;

  /// No description provided for @androidDeliverablesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livrables'**
  String get androidDeliverablesTitle;

  /// No description provided for @androidDeliverablesHelp.
  ///
  /// In fr, this message translates to:
  /// **'Chemin, taille, empreinte SHA-256 et signature des fichiers produits.'**
  String get androidDeliverablesHelp;

  /// No description provided for @androidDeliverablesCheck.
  ///
  /// In fr, this message translates to:
  /// **'Contrôler les livrables'**
  String get androidDeliverablesCheck;

  /// No description provided for @androidDeliverablesNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livrable trouvé : construis d\'abord l\'App Bundle ou l\'APK.'**
  String get androidDeliverablesNone;

  /// No description provided for @androidSignedDebug.
  ///
  /// In fr, this message translates to:
  /// **'Signé avec la clé de débogage : Google Play le refusera.'**
  String get androidSignedDebug;

  /// No description provided for @androidSignedRelease.
  ///
  /// In fr, this message translates to:
  /// **'Signé avec ta clé.'**
  String get androidSignedRelease;

  /// No description provided for @androidUnsigned.
  ///
  /// In fr, this message translates to:
  /// **'Aucune signature trouvée.'**
  String get androidUnsigned;

  /// No description provided for @playFieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'application'**
  String get playFieldTitle;

  /// No description provided for @playFieldShort.
  ///
  /// In fr, this message translates to:
  /// **'Description courte'**
  String get playFieldShort;

  /// No description provided for @playFieldFull.
  ///
  /// In fr, this message translates to:
  /// **'Description complète'**
  String get playFieldFull;

  /// No description provided for @playFieldChangelog.
  ///
  /// In fr, this message translates to:
  /// **'Notes de version (cette version)'**
  String get playFieldChangelog;

  /// No description provided for @playSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Play Store enregistrée dans la session.'**
  String get playSaved;

  /// No description provided for @playListingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Play Store'**
  String get playListingTitle;

  /// No description provided for @playListingHelp.
  ///
  /// In fr, this message translates to:
  /// **'Préremplie avec les textes de store et le changelog public de la session ; les limites de Google Play s\'affichent sous chaque champ.'**
  String get playListingHelp;

  /// No description provided for @playVisualsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Visuels'**
  String get playVisualsTitle;

  /// No description provided for @playVisualsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Google Play demande une icône 512 × 512, un visuel de présentation 1024 × 500 et au moins 2 captures. LaunchPilot prépare l\'icône et le visuel à partir d\'une image d\'au moins 512 px, sans la déformer ; les captures viennent de l\'outil Captures (format Play).'**
  String get playVisualsHelp;

  /// No description provided for @playIconPick.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'image de l\'icône'**
  String get playIconPick;

  /// No description provided for @playIconTooSmall.
  ///
  /// In fr, this message translates to:
  /// **'Image trop petite : il faut au moins 512 × 512 px.'**
  String get playIconTooSmall;

  /// No description provided for @playScreenshots.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune capture au format Play (outil Captures)} =1{1 capture : il en faut au moins 2} other{{count} captures prêtes}}'**
  String playScreenshots(int count);

  /// No description provided for @playFastlaneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fastlane Google Play'**
  String get playFastlaneLabel;

  /// No description provided for @playFastlaneHelp.
  ///
  /// In fr, this message translates to:
  /// **'Prépare android/fastlane : Appfile (identifiant), Fastfile (envoi sur la piste interne en brouillon, mise à jour de la fiche) et métadonnées de « supply » (textes, icône, visuel, captures). Aucune clé n\'y est écrite.'**
  String get playFastlaneHelp;

  /// No description provided for @playNoPackage.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant d\'application introuvable dans build.gradle : lance l\'audit Android.'**
  String get playNoPackage;

  /// No description provided for @playPackage.
  ///
  /// In fr, this message translates to:
  /// **'Application {package} · versionCode {code}'**
  String playPackage(String package, int code);

  /// No description provided for @playExamplePackage.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant « com.example » : Google Play le refusera. Change-le avant le premier envoi.'**
  String get playExamplePackage;

  /// No description provided for @playFastlanePrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer Fastlane (aperçu)'**
  String get playFastlanePrepare;

  /// No description provided for @playListingIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Remplis au moins le nom et les deux descriptions d\'une langue.'**
  String get playListingIncomplete;

  /// No description provided for @playUploadTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoi sur la piste de test interne'**
  String get playUploadTitle;

  /// No description provided for @playFirstUpload.
  ///
  /// In fr, this message translates to:
  /// **'Le tout premier App Bundle doit être envoyé à la main dans la Play Console (création de l\'application) : Fastlane ne peut prendre le relais qu\'ensuite.'**
  String get playFirstUpload;

  /// No description provided for @playFastlaneMissing.
  ///
  /// In fr, this message translates to:
  /// **'Fastlane n\'est pas installé. Installe-le dans ton propre terminal (installation système, jamais lancée par LaunchPilot) :'**
  String get playFastlaneMissing;

  /// No description provided for @playFastfileFirst.
  ///
  /// In fr, this message translates to:
  /// **'Prépare d\'abord les fichiers Fastlane ci-dessus.'**
  String get playFastfileFirst;

  /// No description provided for @playCheckAab.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier l\'App Bundle'**
  String get playCheckAab;

  /// No description provided for @playAabReady.
  ///
  /// In fr, this message translates to:
  /// **'App Bundle signé avec ta clé ({size}).'**
  String playAabReady(String size);

  /// No description provided for @playJsonKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé du compte de service (chemin du fichier .json)'**
  String get playJsonKey;

  /// No description provided for @playJsonKeyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Créée dans Google Cloud et autorisée dans la Play Console. LaunchPilot ne lit ni ne copie ce fichier : seul son chemin est passé à Fastlane. Garde-le hors du projet.'**
  String get playJsonKeyHelp;

  /// No description provided for @playJsonKeyInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Chemin absolu d\'un fichier .json existant attendu.'**
  String get playJsonKeyInvalid;

  /// No description provided for @playJsonKeyInProject.
  ///
  /// In fr, this message translates to:
  /// **'Cette clé est dans le projet : déplace-la ailleurs ou vérifie qu\'elle est ignorée par Git.'**
  String get playJsonKeyInProject;

  /// No description provided for @playValidateKey.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier la clé'**
  String get playValidateKey;

  /// No description provided for @playUploadInternal.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer sur la piste interne (brouillon)'**
  String get playUploadInternal;

  /// No description provided for @playUploadMetadata.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour la fiche'**
  String get playUploadMetadata;

  /// No description provided for @playUploadNote.
  ///
  /// In fr, this message translates to:
  /// **'La version est créée en brouillon : tu la déploies toi-même auprès des testeurs dans la Play Console. LaunchPilot ne publie jamais en production.'**
  String get playUploadNote;

  /// No description provided for @playRecapInternal.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif : envoi sur la piste interne'**
  String get playRecapInternal;

  /// No description provided for @playRecapMetadata.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif : mise à jour de la fiche'**
  String get playRecapMetadata;

  /// No description provided for @playRecapPackage.
  ///
  /// In fr, this message translates to:
  /// **'Application : {package}'**
  String playRecapPackage(String package);

  /// No description provided for @playRecapVersionCode.
  ///
  /// In fr, this message translates to:
  /// **'versionCode : {code} (ne pourra plus être réutilisé)'**
  String playRecapVersionCode(int code);

  /// No description provided for @playRecapInternalEffect.
  ///
  /// In fr, this message translates to:
  /// **'L\'App Bundle est envoyé à Google Play et une version brouillon est créée sur la piste de test interne.'**
  String get playRecapInternalEffect;

  /// No description provided for @playRecapMetadataEffect.
  ///
  /// In fr, this message translates to:
  /// **'Les textes, l\'icône, le visuel et les captures de la fiche publique sont remplacés.'**
  String get playRecapMetadataEffect;

  /// No description provided for @contentTabAndroid.
  ///
  /// In fr, this message translates to:
  /// **'Android'**
  String get contentTabAndroid;

  /// No description provided for @contentTabPlay.
  ///
  /// In fr, this message translates to:
  /// **'Play Store'**
  String get contentTabPlay;

  /// No description provided for @contentAndroidNotSelected.
  ///
  /// In fr, this message translates to:
  /// **'La cible Android n\'est pas retenue pour ce projet Flutter : coche-la dans le rapport de détection pour utiliser cet outil.'**
  String get contentAndroidNotSelected;

  /// No description provided for @iosAreaLinux.
  ///
  /// In fr, this message translates to:
  /// **'Machine utilisée'**
  String get iosAreaLinux;

  /// No description provided for @iosAreaPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get iosAreaPrivacy;

  /// No description provided for @iosNoModule.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier ios dans ce projet Flutter : génère-le avec « flutter create --platforms=ios . » dans ton terminal (possible sous Linux).'**
  String get iosNoModule;

  /// No description provided for @iosLimitsTitle.
  ///
  /// In fr, this message translates to:
  /// **'iOS depuis Linux : ce qui est possible, et ce qui ne l\'est pas'**
  String get iosLimitsTitle;

  /// No description provided for @iosMacTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mac détecté : LaunchPilot prépare quand même tout pour une CI'**
  String get iosMacTitle;

  /// No description provided for @iosLimitsCannot.
  ///
  /// In fr, this message translates to:
  /// **'Impossible sous Linux :'**
  String get iosLimitsCannot;

  /// No description provided for @iosLimit1.
  ///
  /// In fr, this message translates to:
  /// **'construire l\'application (flutter build ios / ipa) : il faut Xcode, qui n\'existe que sur macOS ;'**
  String get iosLimit1;

  /// No description provided for @iosLimit2.
  ///
  /// In fr, this message translates to:
  /// **'signer avec un certificat Apple et un profil de provisioning, ou ouvrir le projet dans Xcode ;'**
  String get iosLimit2;

  /// No description provided for @iosLimit3.
  ///
  /// In fr, this message translates to:
  /// **'lancer le simulateur iOS ou prendre des captures dessus ;'**
  String get iosLimit3;

  /// No description provided for @iosLimit4.
  ///
  /// In fr, this message translates to:
  /// **'envoyer un build sur App Store Connect (l\'envoi se fait depuis la CI macOS).'**
  String get iosLimit4;

  /// No description provided for @iosLimitsCan.
  ///
  /// In fr, this message translates to:
  /// **'Possible ici, avec aperçu avant écriture :'**
  String get iosLimitsCan;

  /// No description provided for @iosCan1.
  ///
  /// In fr, this message translates to:
  /// **'auditer le projet, compléter Info.plist et le manifeste de confidentialité ;'**
  String get iosCan1;

  /// No description provided for @iosCan2.
  ///
  /// In fr, this message translates to:
  /// **'préparer la fiche App Store, les captures (outil Captures) et Fastlane ;'**
  String get iosCan2;

  /// No description provided for @iosCan3.
  ///
  /// In fr, this message translates to:
  /// **'générer la configuration GitHub Actions (runner macOS) ou Codemagic.'**
  String get iosCan3;

  /// No description provided for @iosNeverFake.
  ///
  /// In fr, this message translates to:
  /// **'LaunchPilot n\'affiche jamais un build iOS réussi qu\'il n\'a pas vu : seul le tableau de bord de la CI fait foi.'**
  String get iosNeverFake;

  /// No description provided for @iosAuditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Audit iOS'**
  String get iosAuditTitle;

  /// No description provided for @iosAuditHelp.
  ///
  /// In fr, this message translates to:
  /// **'Lit Info.plist, project.pbxproj et l\'icône App Store : identifiant, textes d\'accès exigés par les plugins, manifeste de confidentialité, chiffrement, équipe et signature.'**
  String get iosAuditHelp;

  /// No description provided for @iosAuditRun.
  ///
  /// In fr, this message translates to:
  /// **'Lancer l\'audit iOS'**
  String get iosAuditRun;

  /// No description provided for @iosPlistTitle.
  ///
  /// In fr, this message translates to:
  /// **'Textes d\'accès et chiffrement (Info.plist)'**
  String get iosPlistTitle;

  /// No description provided for @iosPlistRunAudit.
  ///
  /// In fr, this message translates to:
  /// **'Lance d\'abord l\'audit : les textes manquants ou trop vagues apparaîtront ici, avec une proposition à adapter.'**
  String get iosPlistRunAudit;

  /// No description provided for @iosPlistHelp.
  ///
  /// In fr, this message translates to:
  /// **'Chaque texte est montré à l\'utilisateur au moment de la demande d\'accès : explique concrètement à quoi il sert.'**
  String get iosPlistHelp;

  /// No description provided for @iosEncryption.
  ///
  /// In fr, this message translates to:
  /// **'L\'application n\'utilise que le chiffrement standard (HTTPS)'**
  String get iosEncryption;

  /// No description provided for @iosEncryptionHelp.
  ///
  /// In fr, this message translates to:
  /// **'Déclare ITSAppUsesNonExemptEncryption = false pour ne plus répondre à la question à chaque envoi. Désactive si l\'application chiffre elle-même des données.'**
  String get iosEncryptionHelp;

  /// No description provided for @iosPlistLabel.
  ///
  /// In fr, this message translates to:
  /// **'Info.plist iOS'**
  String get iosPlistLabel;

  /// No description provided for @iosPlistUnrecognized.
  ///
  /// In fr, this message translates to:
  /// **'Info.plist n\'a pas la forme attendue : modifie-le à la main.'**
  String get iosPlistUnrecognized;

  /// No description provided for @iosPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Manifeste de confidentialité (PrivacyInfo.xcprivacy)'**
  String get iosPrivacyTitle;

  /// No description provided for @iosPrivacyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Préparé à partir du questionnaire juridique (ou de la détection) puis ajouté à la cible Runner du projet Xcode, comme le ferait Xcode. Les plugins déclarent eux-mêmes leurs API sensibles.'**
  String get iosPrivacyHelp;

  /// No description provided for @iosTracking.
  ///
  /// In fr, this message translates to:
  /// **'L\'application suit les utilisateurs entre applications (pistage publicitaire)'**
  String get iosTracking;

  /// No description provided for @iosTrackingHelp.
  ///
  /// In fr, this message translates to:
  /// **'Si oui, il faut aussi lister les domaines de pistage et demander l\'autorisation ATT : complète le fichier ensuite.'**
  String get iosTrackingHelp;

  /// No description provided for @iosPrivacyPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer le manifeste (aperçu)'**
  String get iosPrivacyPrepare;

  /// No description provided for @iosPrivacyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Manifeste de confidentialité iOS'**
  String get iosPrivacyLabel;

  /// No description provided for @iosPbxUnrecognized.
  ///
  /// In fr, this message translates to:
  /// **'Le projet Xcode ne ressemble pas au modèle Flutter : seul le fichier est préparé. Ajoute-le à la cible Runner dans Xcode, sur un Mac.'**
  String get iosPbxUnrecognized;

  /// No description provided for @iosPrivacyNote.
  ///
  /// In fr, this message translates to:
  /// **'Ce manifeste est un point de départ à relire : il ne garantit pas la conformité aux règles d\'Apple.'**
  String get iosPrivacyNote;

  /// No description provided for @iosAppleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui reste à faire chez Apple'**
  String get iosAppleTitle;

  /// No description provided for @iosAppleHelp.
  ///
  /// In fr, this message translates to:
  /// **'Ces étapes se font dans un navigateur, sous Linux comme ailleurs. LaunchPilot ne s\'y connecte jamais.'**
  String get iosAppleHelp;

  /// No description provided for @iosApple1.
  ///
  /// In fr, this message translates to:
  /// **'Adhérer à l\'Apple Developer Program (abonnement annuel) et noter ton Team ID (Membership).'**
  String get iosApple1;

  /// No description provided for @iosApple2.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer l\'identifiant de l\'application (Identifiers → App IDs) avec le même bundle ID que le projet.'**
  String get iosApple2;

  /// No description provided for @iosApple3.
  ///
  /// In fr, this message translates to:
  /// **'Créer la fiche de l\'application dans App Store Connect (Mes apps → +) : nom, langue, bundle ID.'**
  String get iosApple3;

  /// No description provided for @iosApple4.
  ///
  /// In fr, this message translates to:
  /// **'Créer une clé API App Store Connect (Utilisateurs et accès → Intégrations) pour la CI ; le fichier .p8 ne se télécharge qu\'une fois.'**
  String get iosApple4;

  /// No description provided for @iosApple5.
  ///
  /// In fr, this message translates to:
  /// **'Remplir « Confidentialité de l\'app » et la classification par âge dans App Store Connect.'**
  String get iosApple5;

  /// No description provided for @iosApple6.
  ///
  /// In fr, this message translates to:
  /// **'Après le premier build reçu, ajouter des testeurs TestFlight.'**
  String get iosApple6;

  /// No description provided for @iosCertificates.
  ///
  /// In fr, this message translates to:
  /// **'Certificat de distribution : prouve que l\'application vient de ton équipe. Profil de provisioning : relie ce certificat, l\'identifiant de l\'application et ses droits. Avec la signature automatique, la CI les crée et les renouvelle grâce à la clé API (rôle Admin recommandé pour qu\'elle puisse créer les certificats).'**
  String get iosCertificates;

  /// No description provided for @iosCiTitle.
  ///
  /// In fr, this message translates to:
  /// **'Build et envoi par une CI macOS'**
  String get iosCiTitle;

  /// No description provided for @iosCiHelp.
  ///
  /// In fr, this message translates to:
  /// **'GitHub Actions : runner macOS 26 avec Xcode 26, signature automatique par la clé API, envoi sur TestFlight. Codemagic : signature et publication gérées par son intégration App Store Connect.'**
  String get iosCiHelp;

  /// No description provided for @iosTeamId.
  ///
  /// In fr, this message translates to:
  /// **'Team ID Apple'**
  String get iosTeamId;

  /// No description provided for @iosTeamIdHelp.
  ///
  /// In fr, this message translates to:
  /// **'10 caractères, visible dans « Membership » du compte développeur. Ce n\'est pas un secret.'**
  String get iosTeamIdHelp;

  /// No description provided for @iosAppleAppId.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant Apple de l\'application (Apple ID)'**
  String get iosAppleAppId;

  /// No description provided for @iosAppleAppIdHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nombre visible dans App Store Connect → Informations sur l\'app. Sert à calculer le numéro de build suivant.'**
  String get iosAppleAppIdHelp;

  /// No description provided for @iosCiGithubSecrets.
  ///
  /// In fr, this message translates to:
  /// **'Secrets à créer dans GitHub (Settings → Secrets and variables → Actions) : {names}. Les valeurs ne passent jamais par LaunchPilot.'**
  String iosCiGithubSecrets(String names);

  /// No description provided for @iosCiCodemagicSetup.
  ///
  /// In fr, this message translates to:
  /// **'Dans Codemagic : ajoute la clé API App Store Connect (Teams → Integrations) sous le nom « launchpilot », puis relie le dépôt.'**
  String get iosCiCodemagicSetup;

  /// No description provided for @iosCiPrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer la configuration CI (aperçu)'**
  String get iosCiPrepare;

  /// No description provided for @iosCiLabel.
  ///
  /// In fr, this message translates to:
  /// **'CI iOS {provider}'**
  String iosCiLabel(String provider);

  /// No description provided for @iosCiNote.
  ///
  /// In fr, this message translates to:
  /// **'Le build ne démarre que lorsque tu le lances toi-même sur la CI, après avoir validé et poussé ces fichiers : LaunchPilot ne pousse jamais et ne déclenche aucun build.'**
  String get iosCiNote;

  /// No description provided for @iosKeyBase64.
  ///
  /// In fr, this message translates to:
  /// **'Pour ASC_KEY_P8_BASE64, encode le fichier .p8 dans ton terminal : « base64 -w0 AuthKey_XXXXXXXXXX.p8 », puis colle le résultat dans GitHub.'**
  String get iosKeyBase64;

  /// No description provided for @asFieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'application'**
  String get asFieldName;

  /// No description provided for @asFieldSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titre'**
  String get asFieldSubtitle;

  /// No description provided for @asFieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get asFieldDescription;

  /// No description provided for @asFieldKeywords.
  ///
  /// In fr, this message translates to:
  /// **'Mots-clés'**
  String get asFieldKeywords;

  /// No description provided for @asFieldPromo.
  ///
  /// In fr, this message translates to:
  /// **'Texte promotionnel'**
  String get asFieldPromo;

  /// No description provided for @asFieldReleaseNotes.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés de cette version'**
  String get asFieldReleaseNotes;

  /// No description provided for @asKeywordsHint.
  ///
  /// In fr, this message translates to:
  /// **'Séparés par des virgules, sans espace ; inutile de répéter le nom.'**
  String get asKeywordsHint;

  /// No description provided for @asSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fiche App Store enregistrée dans la session.'**
  String get asSaved;

  /// No description provided for @asListingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche App Store'**
  String get asListingTitle;

  /// No description provided for @asListingHelp.
  ///
  /// In fr, this message translates to:
  /// **'Préremplie avec les textes de store et le changelog de la session ; les limites d\'Apple s\'affichent sous chaque champ.'**
  String get asListingHelp;

  /// No description provided for @asSupportUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse d\'assistance (obligatoire)'**
  String get asSupportUrl;

  /// No description provided for @asPrivacyUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de la politique de confidentialité (obligatoire)'**
  String get asPrivacyUrl;

  /// No description provided for @asPrivacyUrlHelp.
  ///
  /// In fr, this message translates to:
  /// **'La politique préparée par l\'outil Juridique, une fois publiée sur ton site.'**
  String get asPrivacyUrlHelp;

  /// No description provided for @asMarketingUrl.
  ///
  /// In fr, this message translates to:
  /// **'Site de l\'application (facultatif)'**
  String get asMarketingUrl;

  /// No description provided for @asCopyright.
  ///
  /// In fr, this message translates to:
  /// **'Copyright'**
  String get asCopyright;

  /// No description provided for @asScreenshotsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Captures'**
  String get asScreenshotsTitle;

  /// No description provided for @asScreenshotsHelp.
  ///
  /// In fr, this message translates to:
  /// **'Elles viennent de l\'outil Captures (formats iPhone 1290 × 2796 et iPad 2048 × 2732), puisque le simulateur iOS n\'existe pas sous Linux. Il en faut de 1 à 10 par appareil.'**
  String get asScreenshotsHelp;

  /// No description provided for @asIphoneShots.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune capture iPhone : il en faut au moins une} =1{1 capture iPhone prête} other{{count} captures iPhone prêtes}}'**
  String asIphoneShots(int count);

  /// No description provided for @asIpadShots.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune capture iPad : nécessaire car l\'application accepte l\'iPad} =1{1 capture iPad prête} other{{count} captures iPad prêtes}}'**
  String asIpadShots(int count);

  /// No description provided for @asPrivacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité de l\'app (étiquettes App Store)'**
  String get asPrivacyTitle;

  /// No description provided for @asPrivacyHelp.
  ///
  /// In fr, this message translates to:
  /// **'D\'après le questionnaire juridique, voici les données à déclarer :'**
  String get asPrivacyHelp;

  /// No description provided for @asPrivacyNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée déclarée dans le questionnaire : vérifie-le avant de répondre « Aucune donnée collectée ».'**
  String get asPrivacyNone;

  /// No description provided for @asPrivacyManual.
  ///
  /// In fr, this message translates to:
  /// **'Ces réponses se saisissent à la main dans App Store Connect (Confidentialité de l\'app). Elles doivent correspondre au manifeste de confidentialité et à la politique publiée.'**
  String get asPrivacyManual;

  /// No description provided for @asFastlaneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fastlane App Store'**
  String get asFastlaneLabel;

  /// No description provided for @asFastlaneHelp.
  ///
  /// In fr, this message translates to:
  /// **'Prépare ios/fastlane : Appfile (identifiants publics), Fastfile (lanes metadata et beta) et métadonnées « deliver » (textes, adresses, captures). La clé App Store Connect vient des variables d\'environnement de la CI : aucune clé n\'est écrite.'**
  String get asFastlaneHelp;

  /// No description provided for @asFastlanePrepare.
  ///
  /// In fr, this message translates to:
  /// **'Préparer Fastlane (aperçu)'**
  String get asFastlanePrepare;

  /// No description provided for @asFastlaneMissing.
  ///
  /// In fr, this message translates to:
  /// **'Il faut le nom, la description et les mots-clés d\'une langue, et des adresses d\'assistance et de confidentialité en https.'**
  String get asFastlaneMissing;

  /// No description provided for @asFastlaneWhere.
  ///
  /// In fr, this message translates to:
  /// **'Ces lanes se lancent sur un Mac ou dans la CI macOS (« fastlane ios metadata ») : LaunchPilot ne les exécute pas sous Linux.'**
  String get asFastlaneWhere;

  /// No description provided for @contentTabIos.
  ///
  /// In fr, this message translates to:
  /// **'iOS'**
  String get contentTabIos;

  /// No description provided for @contentTabAppStore.
  ///
  /// In fr, this message translates to:
  /// **'App Store'**
  String get contentTabAppStore;

  /// No description provided for @contentIosNotSelected.
  ///
  /// In fr, this message translates to:
  /// **'La cible iOS n\'est pas retenue pour ce projet Flutter : coche-la dans le rapport de détection pour utiliser cet outil.'**
  String get contentIosNotSelected;

  /// No description provided for @chatTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'Le message et le contexte choisi sont trop longs : décoche un élément de contexte ou raccourcis la question.'**
  String get chatTooLarge;

  /// No description provided for @chatClearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la conversation ?'**
  String get chatClearTitle;

  /// No description provided for @chatClearMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les messages de cette session seront supprimés de LaunchPilot. Les fournisseurs d\'IA gardent leurs propres journaux selon leurs conditions.'**
  String get chatClearMessage;

  /// No description provided for @chatQuickNext.
  ///
  /// In fr, this message translates to:
  /// **'Explique-moi simplement la prochaine étape de ma checklist.'**
  String get chatQuickNext;

  /// No description provided for @chatQuickSimpler.
  ///
  /// In fr, this message translates to:
  /// **'Reformule ta dernière réponse plus simplement, avec un exemple.'**
  String get chatQuickSimpler;

  /// No description provided for @chatQuickError.
  ///
  /// In fr, this message translates to:
  /// **'Que signifie l\'erreur de ma dernière commande, et que puis-je essayer ?'**
  String get chatQuickError;

  /// No description provided for @chatQuickRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Que me reste-t-il à faire avant de publier ?'**
  String get chatQuickRemaining;

  /// No description provided for @chatNoKeyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clé API pour le fournisseur choisi'**
  String get chatNoKeyTitle;

  /// No description provided for @chatNoKeyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le chat utilise {provider}. Enregistre une clé dans les Paramètres (elle reste dans le trousseau du système) ou choisis un autre fournisseur.'**
  String chatNoKeyMessage(String provider);

  /// No description provided for @chatOpenSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les paramètres'**
  String get chatOpenSettings;

  /// No description provided for @chatSafety.
  ///
  /// In fr, this message translates to:
  /// **'Chaque question passe par un aperçu de ce qui sera envoyé, secrets masqués, puis par ta confirmation. L\'agent conseille seulement : il ne peut exécuter aucune commande ni modifier aucun fichier.'**
  String get chatSafety;

  /// No description provided for @chatEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pose une question sur ton projet, une étape, une erreur ou un terme technique.'**
  String get chatEmpty;

  /// No description provided for @chatClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la conversation'**
  String get chatClear;

  /// No description provided for @chatContextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contexte joint à la question'**
  String get chatContextTitle;

  /// No description provided for @chatCtxProject.
  ///
  /// In fr, this message translates to:
  /// **'Résumé du projet'**
  String get chatCtxProject;

  /// No description provided for @chatCtxChecklist.
  ///
  /// In fr, this message translates to:
  /// **'État de la checklist'**
  String get chatCtxChecklist;

  /// No description provided for @chatCtxCommand.
  ///
  /// In fr, this message translates to:
  /// **'Dernière commande'**
  String get chatCtxCommand;

  /// No description provided for @chatContextHelp.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les éléments cochés sont envoyés, avec les derniers échanges. Aucun fichier du projet n\'est transmis.'**
  String get chatContextHelp;

  /// No description provided for @chatModel.
  ///
  /// In fr, this message translates to:
  /// **'Réponse de {model}'**
  String chatModel(String model);

  /// No description provided for @reportStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Session close'**
  String get reportStatusCompleted;

  /// No description provided for @reportStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Session en cours'**
  String get reportStatusActive;

  /// No description provided for @reportWriteFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'écrire le rapport à cet emplacement.'**
  String get reportWriteFailed;

  /// No description provided for @reportSaved.
  ///
  /// In fr, this message translates to:
  /// **'Rapport enregistré.'**
  String get reportSaved;

  /// No description provided for @reportsHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des sessions'**
  String get reportsHistoryTitle;

  /// No description provided for @reportsProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} étapes'**
  String reportsProgress(int done, int total);

  /// No description provided for @reportsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 rapport exporté} other{{count} rapports exportés}}'**
  String reportsCount(int count);

  /// No description provided for @reportsOpen.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du rapport'**
  String get reportsOpen;

  /// No description provided for @reportsDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rapport : {project} {version}'**
  String reportsDetailTitle(String project, String version);

  /// No description provided for @reportsStepsLine.
  ///
  /// In fr, this message translates to:
  /// **'Checklist : {done} étapes terminées sur {total}'**
  String reportsStepsLine(int done, int total);

  /// No description provided for @reportsFilesLine.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun fichier modifié} =1{1 fichier créé ou modifié} other{{count} fichiers créés ou modifiés}}'**
  String reportsFilesLine(int count);

  /// No description provided for @reportsCommandsLine.
  ///
  /// In fr, this message translates to:
  /// **'{count} commande(s) exécutée(s), dont {checks} test(s) ou analyse(s)'**
  String reportsCommandsLine(int count, int checks);

  /// No description provided for @reportsDeliverablesLine.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun livrable trouvé} =1{1 livrable} other{{count} livrables}}'**
  String reportsDeliverablesLine(int count);

  /// No description provided for @reportsAuditLine.
  ///
  /// In fr, this message translates to:
  /// **'Audit {title} : {failures} problème(s), {warnings} avertissement(s)'**
  String reportsAuditLine(String title, int failures, int warnings);

  /// No description provided for @reportsContents.
  ///
  /// In fr, this message translates to:
  /// **'Le rapport contient aussi les technologies et cibles, les commandes (secrets masqués), les actions restantes, la procédure manuelle de publication et le lexique.'**
  String get reportsContents;

  /// No description provided for @reportsPdfHint.
  ///
  /// In fr, this message translates to:
  /// **'Fichier HTML autonome : ouvre-le dans un navigateur, puis Imprimer → Enregistrer au format PDF pour obtenir un PDF.'**
  String get reportsPdfHint;

  /// No description provided for @reportsPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Rapports déjà exportés pour cette session'**
  String get reportsPrevious;

  /// No description provided for @helpManualTitle.
  ///
  /// In fr, this message translates to:
  /// **'Manuel complet'**
  String get helpManualTitle;

  /// No description provided for @helpManualSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans le manuel'**
  String get helpManualSearch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

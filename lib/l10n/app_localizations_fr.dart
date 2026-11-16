// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'LaunchPilot';

  @override
  String get appTagline => 'Préparer, contrôler, construire, publier.';

  @override
  String get navGroupProject => 'Projet';

  @override
  String get navGroupTools => 'Outils';

  @override
  String get navGroupApp => 'Application';

  @override
  String get navHome => 'Accueil';

  @override
  String get navDetection => 'Détection';

  @override
  String get navPublication => 'Publication';

  @override
  String get navChecklist => 'Checklist';

  @override
  String get navTerminal => 'Terminal';

  @override
  String get navAgent => 'Agent';

  @override
  String get navContent => 'Contenus';

  @override
  String get navReports => 'Rapports';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navHelp => 'Aide';

  @override
  String get navOpenMenu => 'Ouvrir le menu de navigation';

  @override
  String navShortcutTooltip(String label, String key) {
    return '$label (Ctrl+$key)';
  }

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get demoTag => 'DÉMO';

  @override
  String get demoBannerTitle => 'Mode démo';

  @override
  String get demoBannerMessage =>
      'Données fictives, clairement identifiées. Aucun projet réel n\'est lu ni modifié.';

  @override
  String get demoBannerExit => 'Quitter le mode démo';

  @override
  String laterPhaseTooltip(int phase) {
    return 'Disponible dans une phase ultérieure (phase $phase)';
  }

  @override
  String phaseBadge(int phase) {
    return 'Phase $phase';
  }

  @override
  String percentValue(int percent) {
    return '$percent %';
  }

  @override
  String get levelAnalyze => 'Analyser';

  @override
  String get levelAnalyzeDesc => 'Lecture seule. Aucun fichier n\'est modifié.';

  @override
  String get levelPrepare => 'Préparer';

  @override
  String get levelPrepareDesc =>
      'Génère textes et configurations, avec un aperçu avant toute écriture.';

  @override
  String get levelBuild => 'Construire';

  @override
  String get levelBuildDesc => 'Compile le projet et crée les livrables.';

  @override
  String get levelPublish => 'Publier';

  @override
  String get levelPublishDesc =>
      'Envoie vers un store ou un hébergeur, uniquement après une confirmation explicite.';

  @override
  String get statusTodo => 'À faire';

  @override
  String get statusRunning => 'En cours';

  @override
  String get statusSucceeded => 'Réussi';

  @override
  String get statusFailed => 'Échec';

  @override
  String get statusNeedsValidation => 'Validation requise';

  @override
  String get statusPedagogical => 'Étape pédagogique';

  @override
  String get homeTitle => 'Bienvenue dans LaunchPilot';

  @override
  String get homeSubtitle =>
      'Ouvre un projet pour l\'analyser, préparer sa publication et comprendre chaque étape.';

  @override
  String get homeOpenProject => 'Ouvrir un dossier de projet';

  @override
  String get homeOpenProjectHint =>
      'Choisis le dossier de ton projet. L\'analyse se fait ensuite sur ta demande, en lecture seule.';

  @override
  String get homeRecentTitle => 'Projets récents';

  @override
  String get homeRecentEmptyTitle => 'Aucun projet pour l\'instant';

  @override
  String get homeRecentEmptyMessage =>
      'Les projets ouverts apparaîtront ici avec leur progression, leurs favoris et leur date de dernière ouverture.';

  @override
  String get homeResumeTitle => 'Reprendre une session';

  @override
  String get homeResumeEmptyTitle => 'Aucune session en cours';

  @override
  String get homeResumeEmptyMessage =>
      'Chaque préparation de version crée une session que tu pourras reprendre plus tard.';

  @override
  String get homeResumeAction => 'Reprendre';

  @override
  String get homeFavorite => 'Favori';

  @override
  String homeLastOpened(String date) {
    return 'Ouvert le $date';
  }

  @override
  String homeSessionStarted(String date) {
    return 'Session commencée le $date';
  }

  @override
  String homeCurrentLevel(String level) {
    return 'Niveau actuel : $level';
  }

  @override
  String get homeHowTitle => 'Comment LaunchPilot travaille';

  @override
  String get homeTryDemo => 'Découvrir le mode démo';

  @override
  String get homeDemoHint =>
      'Explore l\'interface avec un projet fictif, sans rien lire ni modifier sur ton disque.';

  @override
  String get detectionTitle => 'Rapport de détection';

  @override
  String get detectionSubtitle =>
      'Technologies, cibles, preuves et niveau de confiance.';

  @override
  String get detectionEmptyMessage =>
      'Après l\'ouverture d\'un dossier, LaunchPilot listera ici ce qu\'il a reconnu et pourquoi. Tu pourras confirmer ou corriger les cibles.';

  @override
  String get detectionTechnologies => 'Technologies détectées';

  @override
  String detectionConfidence(int percent) {
    return 'Confiance : $percent %';
  }

  @override
  String get detectionEvidence => 'Preuves';

  @override
  String get detectionTargets => 'Cibles de publication';

  @override
  String get detectionTargetDetected => 'Détectée';

  @override
  String get detectionTargetNotDetected => 'Non détectée';

  @override
  String get detectionRescan => 'Relancer l\'analyse';

  @override
  String get publicationTitle => 'Tableau de publication';

  @override
  String get publicationSubtitle =>
      'Quatre niveaux distincts. Tu peux t\'arrêter après chacun d\'eux.';

  @override
  String get publicationGlobalProgress => 'Progression globale';

  @override
  String get publicationNeverAuto =>
      'La publication n\'est jamais déclenchée automatiquement après un build.';

  @override
  String publicationStepsDone(int done, int total) {
    return '$done / $total étapes';
  }

  @override
  String get checklistTitle => 'Checklist pédagogique';

  @override
  String get checklistSubtitle =>
      'Chaque étape explique son objectif, ses risques et comment la vérifier.';

  @override
  String get checklistEmptyMessage =>
      'La checklist sera construite à partir des cibles confirmées de ton projet.';

  @override
  String get checklistLevelLabel => 'Niveau d\'explication';

  @override
  String get checklistExplanation => 'Explication';

  @override
  String get checklistWhy => 'Pourquoi c\'est nécessaire';

  @override
  String get checklistFiles => 'Fichiers concernés';

  @override
  String get checklistCommands => 'Commandes';

  @override
  String get checklistExpected => 'Résultat attendu';

  @override
  String get checklistRisks => 'Risques';

  @override
  String get checklistVerification => 'Comment vérifier';

  @override
  String get checklistRollback => 'Comment revenir en arrière';

  @override
  String get checklistNoRollback =>
      'Aucun retour arrière automatique possible.';

  @override
  String get checklistShowVerify => 'Montre-moi comment vérifier';

  @override
  String get checklistHideVerify => 'Masquer la vérification';

  @override
  String get checklistRequiresConfirmation => 'Confirmation requise';

  @override
  String get checklistIrreversible => 'Irréversible';

  @override
  String get checklistRun => 'Exécuter l\'étape';

  @override
  String get checklistShowDetails => 'Afficher les détails';

  @override
  String get checklistHideDetails => 'Masquer les détails';

  @override
  String get terminalTitle => 'Terminal intégré';

  @override
  String get terminalSubtitle =>
      'Sortie des commandes en direct, avec les secrets masqués.';

  @override
  String get terminalEmptyMessage =>
      'Les commandes validées s\'afficheront ici en direct. Chaque commande est prévisualisée avant son exécution.';

  @override
  String get terminalFilterAll => 'Tout';

  @override
  String get terminalFilterStdout => 'stdout';

  @override
  String get terminalFilterStderr => 'stderr';

  @override
  String get terminalCopy => 'Copier la sortie';

  @override
  String get terminalCopied => 'Sortie copiée dans le presse-papiers.';

  @override
  String get terminalStop => 'Arrêter';

  @override
  String get terminalSimulated => 'Sortie simulée';

  @override
  String terminalExitCode(int code) {
    return 'Code de sortie : $code';
  }

  @override
  String get agentTitle => 'Agent LaunchPilot';

  @override
  String get agentSubtitle =>
      'Pose tes questions, fais reformuler une étape ou demande une aide contextualisée.';

  @override
  String get agentComposerHint => 'Écris ta question…';

  @override
  String get agentSend => 'Envoyer';

  @override
  String get agentYou => 'Toi';

  @override
  String get agentAssistant => 'Agent';

  @override
  String get contentTitle => 'Contenus et aperçus';

  @override
  String get contentSubtitle =>
      'Textes de store, icônes, captures et aperçus SEO.';

  @override
  String get contentTexts => 'Textes de la fiche';

  @override
  String get contentIcons => 'Icônes';

  @override
  String get contentScreenshots => 'Captures d\'écran';

  @override
  String get contentPreview => 'Aperçu de la fiche';

  @override
  String get contentIconsEmpty =>
      'Importe une icône source (1024 × 1024 minimum) pour générer les tailles Android, iOS, favicon et PWA sans déformation.';

  @override
  String get contentScreenshotsEmpty =>
      'Importe tes captures pour vérifier leurs dimensions et choisir un cadre de présentation.';

  @override
  String get fieldTitle => 'Titre';

  @override
  String get fieldSubtitle => 'Sous-titre';

  @override
  String get fieldShortDescription => 'Description courte';

  @override
  String get fieldKeywords => 'Mots-clés';

  @override
  String get reportsTitle => 'Rapports et historique';

  @override
  String get reportsSubtitle => 'Sessions passées et exports HTML/PDF.';

  @override
  String get reportsEmptyTitle => 'Aucun rapport';

  @override
  String get reportsEmptyMessage =>
      'Démarre une session de version sur un projet : son rapport (livrables, commandes, audits, actions restantes) pourra ensuite être exporté ici.';

  @override
  String get reportsExport => 'Exporter en HTML';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle =>
      'Apparence, langue, accompagnement et fournisseurs d\'IA.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get settingsTextSize => 'Taille du texte';

  @override
  String get textSizeNormal => 'Normale';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeExtraLarge => 'Très grande';

  @override
  String get settingsAnimations => 'Animations';

  @override
  String get settingsAnimationsHint =>
      'Transitions courtes et sobres. Désactive-les si elles te gênent.';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsGuidance => 'Mode d\'accompagnement';

  @override
  String get modeBeginner => 'Débutant';

  @override
  String get modeBeginnerDesc =>
      'Explications détaillées, vocabulaire défini, commandes commentées et validations fréquentes.';

  @override
  String get modeGuided => 'Accompagné';

  @override
  String get modeGuidedDesc =>
      'Explications condensées, actions regroupées et confirmation des modifications importantes.';

  @override
  String get modeExpert => 'Expert';

  @override
  String get modeExpertDesc =>
      'Interface plus dense et actions groupées. Les confirmations de sécurité restent obligatoires.';

  @override
  String get settingsAi => 'Intelligence artificielle';

  @override
  String get settingsAiProvider => 'Fournisseur préféré';

  @override
  String get settingsApiKeys => 'Clés API';

  @override
  String get settingsApiKeysHint =>
      'Les clés sont stockées dans le trousseau du système (libsecret), jamais en clair dans un fichier. Elles ne sont jamais réaffichées.';

  @override
  String get apiKeyStored => 'Clé enregistrée';

  @override
  String get apiKeyMissing => 'Aucune clé';

  @override
  String apiKeyFieldLabel(String provider) {
    return 'Clé API $provider';
  }

  @override
  String apiKeyFieldReplaceLabel(String provider) {
    return 'Nouvelle clé API $provider';
  }

  @override
  String get apiKeySave => 'Enregistrer';

  @override
  String get apiKeyReplace => 'Remplacer';

  @override
  String apiKeySaved(String provider) {
    return 'Clé $provider enregistrée dans le trousseau.';
  }

  @override
  String apiKeyDeleted(String provider) {
    return 'Clé $provider supprimée.';
  }

  @override
  String apiKeyDeleteTitle(String provider) {
    return 'Supprimer la clé $provider ?';
  }

  @override
  String get apiKeyDeleteMessage =>
      'La clé sera effacée du trousseau du système. Tu devras la saisir à nouveau pour utiliser ce fournisseur.';

  @override
  String get apiKeyErrorEmpty => 'Saisis une clé avant d\'enregistrer.';

  @override
  String get apiKeyErrorTooShort => 'Cette clé semble trop courte.';

  @override
  String get apiKeyErrorTooLong => 'Cette clé est trop longue.';

  @override
  String get apiKeyErrorInvalidChars =>
      'Une clé ne contient ni espace ni caractère invisible.';

  @override
  String get apiKeyStorageError =>
      'Le trousseau du système est verrouillé ou indisponible : LaunchPilot ne peut pas lire les clés. Déverrouille-le (application « Mots de passe et clés », ou en te reconnectant), ou vérifie que gnome-keyring est lancé, puis réessaie.';

  @override
  String apiKeyWhereToGet(String url) {
    return 'Obtenir une clé : $url';
  }

  @override
  String get settingsHosting => 'Hébergeurs préférés';

  @override
  String get settingsHostingHint =>
      'L\'hébergeur choisi ici est proposé par défaut pour chaque nouveau site ; tu peux en changer projet par projet dans Contenus → Hébergement.';

  @override
  String get settingsDemo => 'Mode démo';

  @override
  String get settingsDemoHint =>
      'Affiche un projet fictif pour découvrir l\'interface. Les données de démonstration sont toujours signalées.';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsPrivacyText =>
      'LaunchPilot fonctionne localement. Aucun compte ni service distant n\'est nécessaire pour ouvrir l\'application.';

  @override
  String get helpTitle => 'Aide et lexique';

  @override
  String get helpSubtitle =>
      'Mode d\'emploi, raccourcis clavier et vocabulaire technique.';

  @override
  String get helpGuideTitle => 'Mode d\'emploi';

  @override
  String get helpGuideStep1 =>
      'Ouvre le dossier de ton projet depuis l\'accueil.';

  @override
  String get helpGuideStep2 =>
      'Vérifie le rapport de détection et confirme les cibles.';

  @override
  String get helpGuideStep3 =>
      'Suis la checklist niveau par niveau : Analyser, Préparer, Construire, Publier.';

  @override
  String get helpGuideStep4 =>
      'Valide chaque action sensible après avoir lu son récapitulatif.';

  @override
  String get helpGuideStep5 =>
      'Exporte le rapport final pour garder une trace.';

  @override
  String get helpGuideNote =>
      'LaunchPilot 1.0.0 couvre tout le parcours : projets et sessions, détection, checklist, commandes sécurisées, contenus, web, Android, iOS via CI, chat avec l\'agent et rapports. Chaque écriture passe par un aperçu, chaque publication par une confirmation renforcée.';

  @override
  String get helpShortcutsTitle => 'Raccourcis clavier';

  @override
  String get helpShortcutNav => 'Aller directement à un écran de la navigation';

  @override
  String get helpShortcutTab => 'Passer d\'un élément à l\'autre';

  @override
  String get helpShortcutActivate => 'Activer l\'élément sélectionné';

  @override
  String get helpGlossaryTitle => 'Lexique';

  @override
  String get helpGlossarySearch => 'Rechercher un terme';

  @override
  String get helpGlossaryNoResult =>
      'Aucun terme ne correspond à ta recherche.';

  @override
  String get helpKeysTab => 'Tab / Maj+Tab';

  @override
  String get helpKeysActivate => 'Entrée / Espace';

  @override
  String get homeFilterAll => 'Tous';

  @override
  String get homeFilterFavorites => 'Favoris';

  @override
  String get homeFavoritesEmpty =>
      'Aucun favori. Clique sur l\'étoile d\'un projet pour le retrouver ici.';

  @override
  String get homeAddFavorite => 'Ajouter aux favoris';

  @override
  String get homeRemoveFavorite => 'Retirer des favoris';

  @override
  String get homeOpen => 'Ouvrir';

  @override
  String get homeProjectMenu => 'Actions du projet';

  @override
  String get homeNewSession => 'Nouvelle session';

  @override
  String get homeRelocate => 'Relocaliser';

  @override
  String get homeRemove => 'Retirer de la liste';

  @override
  String get homeFolderMissing => 'Dossier introuvable';

  @override
  String get homeFolderMissingHint =>
      'Le dossier a peut-être été déplacé ou supprimé. Relocalise-le ou retire le projet de la liste.';

  @override
  String homeSessionActive(String version) {
    return 'Session $version en cours';
  }

  @override
  String get homeLoadError => 'Impossible de lire les données locales.';

  @override
  String homeResumeSince(String date) {
    return 'Dernière activité le $date';
  }

  @override
  String get addProjectTitle => 'Ajouter un projet';

  @override
  String get addProjectPathLabel => 'Chemin du dossier';

  @override
  String get addProjectPathHint => '~/projets/mon-app';

  @override
  String get addProjectNameLabel => 'Nom affiché (facultatif)';

  @override
  String get addProjectPickerNote =>
      'Colle le chemin complet du dossier, ou utilise le bouton Parcourir.';

  @override
  String get addProjectConfirm => 'Ajouter';

  @override
  String get pathErrorEmpty => 'Indique un chemin.';

  @override
  String get pathErrorNotAbsolute =>
      'Indique un chemin complet, commençant par / ou ~.';

  @override
  String get pathErrorNotFound =>
      'Ce dossier n\'existe pas ou n\'est pas accessible.';

  @override
  String get pathErrorAlreadyRegistered =>
      'Ce dossier est déjà utilisé par un autre projet.';

  @override
  String projectAdded(String name) {
    return 'Projet « $name » ajouté.';
  }

  @override
  String projectAlreadyKnown(String name) {
    return '« $name » était déjà dans la liste : il a été rouvert.';
  }

  @override
  String relocateTitle(String name) {
    return 'Relocaliser « $name »';
  }

  @override
  String relocateOldPath(String path) {
    return 'Ancien chemin : $path';
  }

  @override
  String get relocateConfirm => 'Relocaliser';

  @override
  String get projectRelocated => 'Nouveau chemin enregistré.';

  @override
  String removeProjectTitle(String name) {
    return 'Retirer « $name » de LaunchPilot ?';
  }

  @override
  String removeProjectMessage(int sessions, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessions',
      one: '1 session',
      zero: 'aucune session',
    );
    String _temp1 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps étapes',
      one: '1 étape',
      zero: 'aucune étape',
    );
    return 'Son historique local sera effacé : $_temp0 et $_temp1 de checklist. Les fichiers de ton projet ne sont pas touchés.';
  }

  @override
  String get removeProjectConfirm => 'Retirer';

  @override
  String get projectRemoved => 'Projet retiré de la liste.';

  @override
  String newSessionTitle(String name) {
    return 'Nouvelle session pour « $name »';
  }

  @override
  String get newSessionVersionLabel => 'Version préparée';

  @override
  String get newSessionVersionHint => '1.3.0+14';

  @override
  String get newSessionHint =>
      'Une session regroupe la préparation d\'une version : checklist, textes validés et rapports. Tu pourras la reprendre plus tard.';

  @override
  String get newSessionConfirm => 'Démarrer';

  @override
  String get versionErrorEmpty => 'Indique la version préparée.';

  @override
  String get versionErrorInvalid =>
      'Chiffres, lettres, points, tirets, + et _ uniquement, sans espace (64 caractères maximum).';

  @override
  String get sessionErrorActiveExists =>
      'Une session est déjà en cours pour ce projet. Reprends-la ou clos-la d\'abord.';

  @override
  String sessionStarted(String version) {
    return 'Session $version démarrée.';
  }

  @override
  String get closeSession => 'Clore la session';

  @override
  String closeSessionTitle(String version) {
    return 'Clore la session $version ?';
  }

  @override
  String get closeSessionMessage =>
      'La session sera marquée comme terminée et ne pourra plus être reprise. Son historique est conservé.';

  @override
  String get closeSessionConfirm => 'Clore';

  @override
  String get sessionClosed => 'Session close.';

  @override
  String get publicationNoProjectTitle => 'Aucun projet ouvert';

  @override
  String get publicationNoProjectMessage =>
      'Ouvre ou ajoute un projet depuis l\'accueil pour préparer sa publication.';

  @override
  String get publicationGoHome => 'Aller à l\'accueil';

  @override
  String get publicationNoSessionTitle =>
      'Aucune session en cours pour ce projet';

  @override
  String get publicationNoSessionMessage =>
      'Démarre une session pour préparer une nouvelle version.';

  @override
  String get settingsLocalData => 'Données locales';

  @override
  String get settingsLocalDataHint =>
      'Projets, sessions et checklists sont enregistrés dans une base SQLite sur cet ordinateur. Aucune clé API n\'y figure.';

  @override
  String settingsLocalDataLocation(String path) {
    return 'Emplacement : $path';
  }

  @override
  String get statProjects => 'Projets';

  @override
  String get statSessions => 'Sessions';

  @override
  String get statSteps => 'Étapes de checklist';

  @override
  String get settingsClearData => 'Effacer toutes les données locales';

  @override
  String get clearDataTitle => 'Effacer toutes les données locales ?';

  @override
  String get clearDataMessage =>
      'Tous les projets, sessions, checklists et rapports enregistrés par LaunchPilot seront supprimés de cet ordinateur. Les fichiers de tes projets et les clés API ne sont pas touchés. Cette action est irréversible.';

  @override
  String clearDataTypeWord(String word) {
    return 'Pour confirmer, écris $word';
  }

  @override
  String get clearDataWord => 'EFFACER';

  @override
  String get clearDataConfirm => 'Tout effacer';

  @override
  String get clearDataDone => 'Données locales effacées.';

  @override
  String get llmErrMissingKey =>
      'Aucune clé API enregistrée pour ce fournisseur.';

  @override
  String get llmErrInvalidKey =>
      'Clé API refusée par le fournisseur. Vérifie-la ou remplace-la.';

  @override
  String get llmErrPermission => 'Cette clé n\'a pas accès à cette ressource.';

  @override
  String get llmErrBilling =>
      'Problème de facturation ou de quota sur le compte du fournisseur.';

  @override
  String get llmErrModelNotFound =>
      'Modèle introuvable ou non disponible pour ce compte.';

  @override
  String get llmErrBadRequest =>
      'Requête refusée par le fournisseur (paramètres invalides).';

  @override
  String get llmErrTooLarge => 'Contenu trop volumineux pour ce fournisseur.';

  @override
  String get llmErrRateLimited => 'Trop de requêtes : réessaie dans un moment.';

  @override
  String get llmErrOverloaded =>
      'Service du fournisseur surchargé : réessaie dans un moment.';

  @override
  String get llmErrServer => 'Erreur temporaire chez le fournisseur.';

  @override
  String get llmErrTimeout => 'Pas de réponse dans le délai imparti.';

  @override
  String get llmErrCancelled => 'Requête annulée.';

  @override
  String get llmErrNetwork =>
      'Connexion impossible : vérifie ton accès à Internet.';

  @override
  String get llmErrInvalidResponse =>
      'Réponse inexploitable : elle ne respecte pas le format attendu.';

  @override
  String get llmErrRefused => 'Le modèle a refusé de répondre à cette demande.';

  @override
  String get llmErrTruncated =>
      'Réponse incomplète : la limite de longueur a été atteinte.';

  @override
  String get llmErrConsent =>
      'Envoi bloqué : la confirmation ne correspond pas à ce contenu ou a déjà servi.';

  @override
  String llmErrDetail(String detail) {
    return 'Détail technique : $detail';
  }

  @override
  String get llmModelLabel => 'Modèle';

  @override
  String llmModelDefault(String model) {
    return 'Par défaut : $model';
  }

  @override
  String get llmChooseModel => 'Choisir parmi les modèles disponibles';

  @override
  String get llmTest => 'Tester la connexion';

  @override
  String get llmTestCancel => 'Annuler le test';

  @override
  String llmTestOk(int ms, int count) {
    return 'Connexion réussie en $ms ms · $count modèles disponibles';
  }

  @override
  String llmTestModelOk(String model) {
    return 'Le modèle « $model » est disponible.';
  }

  @override
  String llmTestModelMissing(String model) {
    return 'Le modèle « $model » n\'apparaît pas dans la liste de ce compte.';
  }

  @override
  String get settingsAiNetworkPolicy =>
      'LaunchPilot ne contacte un fournisseur qu\'à ta demande. Le test de connexion liste les modèles sans consommer de jetons.';

  @override
  String get llmTrialTitle => 'Essai de génération';

  @override
  String get llmTrialHint =>
      'Envoie une question fixe, sans aucune donnée de ton projet, au fournisseur préféré pour vérifier la réponse structurée. Cet essai consomme quelques jetons.';

  @override
  String get llmTrialButton => 'Lancer un essai';

  @override
  String llmTrialNeedsKey(String provider) {
    return 'Enregistre d\'abord une clé pour $provider.';
  }

  @override
  String get llmTrialPrompt =>
      'Explique en deux phrases, à une personne débutante, ce qu\'est un numéro de build dans une application mobile, puis cite trois termes techniques liés.';

  @override
  String get llmTrialLanguage => 'français';

  @override
  String get llmTrialAnswer => 'Réponse';

  @override
  String get llmTrialTerms => 'Termes liés';

  @override
  String sendTitle(String provider) {
    return 'Envoyer à $provider ?';
  }

  @override
  String sendModel(String model) {
    return 'Modèle : $model';
  }

  @override
  String sendSize(int tokens) {
    return 'Environ $tokens jetons en entrée (estimation)';
  }

  @override
  String sendRedactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secrets masqués avant l\'envoi',
      one: '1 secret masqué avant l\'envoi',
      zero: 'Aucun secret détecté',
    );
    return '$_temp0';
  }

  @override
  String sendExcluded(String files) {
    return 'Fichiers sensibles exclus : $files';
  }

  @override
  String get sendNoProjectData => 'Aucune donnée de ton projet n\'est incluse.';

  @override
  String get sendProjectData =>
      'Des extraits de ton projet sont inclus : relis l\'aperçu.';

  @override
  String get sendShowPreview => 'Voir exactement ce qui sera transmis';

  @override
  String get sendHidePreview => 'Masquer l\'aperçu';

  @override
  String get sendSystemLabel => 'Consignes';

  @override
  String get sendUserLabel => 'Contenu';

  @override
  String get sendConsentNote =>
      'Cette confirmation ne vaut que pour cet envoi précis.';

  @override
  String get sendConfirm => 'Envoyer';

  @override
  String get sendInProgress => 'Requête en cours…';

  @override
  String get sendCancelRequest => 'Annuler la requête';

  @override
  String get sendDoneTitle => 'Réponse reçue';

  @override
  String sendUsage(int input, int output, String seconds) {
    return '$input jetons en entrée · $output en sortie · $seconds s';
  }

  @override
  String sendServedBy(String model) {
    return 'Réponse produite par $model';
  }

  @override
  String get sendFailedTitle => 'Échec de la requête';

  @override
  String get commonClose => 'Fermer';

  @override
  String get homeChooseFolder => 'Choisir un dossier…';

  @override
  String get homeEnterPath => 'Saisir un chemin';

  @override
  String get pickerConfirm => 'Choisir ce dossier';

  @override
  String get addProjectBrowse => 'Parcourir…';

  @override
  String get detectionAnalyze => 'Analyser le projet';

  @override
  String get detectionAnalyzing => 'Analyse en cours…';

  @override
  String get detectionReadOnlyNote =>
      'L\'analyse est en lecture seule : LaunchPilot lit les fichiers de configuration (pubspec.yaml, package.json, manifestes…) sans rien modifier. Les fichiers sensibles (clés, .env) ne sont jamais lus.';

  @override
  String get detectionNeverScanned => 'Ce projet n\'a pas encore été analysé.';

  @override
  String detectionScannedAt(String date, int count) {
    return 'Analysé le $date · $count fichiers parcourus';
  }

  @override
  String detectionFailed(String error) {
    return 'L\'analyse a échoué : $error';
  }

  @override
  String detectionPartial(String reasons) {
    return 'Analyse partielle ($reasons) : les résultats peuvent être incomplets.';
  }

  @override
  String get partialMaxFiles => 'plus de 20 000 fichiers';

  @override
  String get partialMaxDepth => 'dossiers trop profonds';

  @override
  String get partialReadBudget => 'volume de lecture maximal atteint';

  @override
  String get partialTimeout => 'durée maximale atteinte';

  @override
  String get partialUnreadable => 'dossiers illisibles';

  @override
  String get detectionNoTechnology =>
      'Aucune technologie reconnue. Vérifie que le dossier choisi est bien la racine du projet.';

  @override
  String get detectionInformative => 'À titre informatif';

  @override
  String get detectionTargetsHint =>
      'Coche les cibles que tu veux publier. Tes choix sont conservés lors des prochaines analyses.';

  @override
  String get detectionTargetSelected => 'Retenue';

  @override
  String detectionTargetsReviewed(String date) {
    return 'Cibles validées le $date';
  }

  @override
  String get detectionTargetsToReview =>
      'Cibles à valider : elles suivent la détection tant que tu ne les as pas validées.';

  @override
  String get detectionValidateTargets => 'Valider les cibles';

  @override
  String get detectionTargetsValidated => 'Cibles validées.';

  @override
  String get detectionIosLinuxNote =>
      'Sous Linux, la construction iOS passera par une CI macOS.';

  @override
  String get detectionPackages => 'Paquets et scripts';

  @override
  String get detectionNoLockFile => 'Aucun fichier de verrouillage';

  @override
  String get detectionNoScripts => 'Aucun script déclaré';

  @override
  String get detectionGitAbsent =>
      'Pas de dépôt Git. Il est recommandé d\'en créer un avant toute modification, pour pouvoir revenir en arrière.';

  @override
  String detectionGitBranch(String branch) {
    return 'Branche : $branch';
  }

  @override
  String detectionGitDetached(String commit) {
    return 'HEAD détachée sur $commit';
  }

  @override
  String detectionGitTags(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags : $list',
      one: '1 tag : $list',
      zero: 'Aucun tag',
    );
    return '$_temp0';
  }

  @override
  String get detectionGitWorktree =>
      'Dépôt lié (worktree ou sous-module) : détails non lus.';

  @override
  String get detectionGitStatusLater =>
      'L\'état en direct (modifications non validées) est affiché dans le tableau de publication, section Protection du projet.';

  @override
  String get detectionPublishingFiles => 'Fichiers de publication';

  @override
  String get categoryIcon => 'Icônes';

  @override
  String get categoryScreenshot => 'Captures d\'écran';

  @override
  String get categoryFastlane => 'Fastlane';

  @override
  String get categoryCi => 'Intégration continue';

  @override
  String get categoryHosting => 'Hébergement';

  @override
  String get categoryPwa => 'PWA';

  @override
  String get categoryLegal => 'Documents juridiques';

  @override
  String get categorySigning => 'Signature';

  @override
  String get detectionNothingFound => 'Rien trouvé';

  @override
  String get signingNotRead => 'présent, non lu';

  @override
  String get detectionSeo => 'SEO';

  @override
  String get seoTitle => 'Balise title';

  @override
  String get seoDescription => 'Meta description';

  @override
  String get seoCanonical => 'URL canonique';

  @override
  String get seoOpenGraph => 'Open Graph';

  @override
  String get seoTwitterCard => 'Twitter Card';

  @override
  String get seoStructuredData => 'Données structurées (schema.org)';

  @override
  String get seoRobots => 'robots.txt';

  @override
  String get seoSitemap => 'sitemap.xml';

  @override
  String get detectionPermissions => 'Permissions déclarées';

  @override
  String get detectionNoPermissions => 'Aucune permission détectée';

  @override
  String get detectionServices => 'Services tiers';

  @override
  String get detectionNoServices => 'Aucun SDK tiers détecté';

  @override
  String get serviceAnalytics => 'Statistiques';

  @override
  String get serviceAds => 'Publicité';

  @override
  String get serviceCrash => 'Rapports de plantage';

  @override
  String get serviceMessaging => 'Notifications';

  @override
  String get serviceBackend => 'Back-end';

  @override
  String get servicePayments => 'Paiements';

  @override
  String detectionSensitive(String files) {
    return 'Fichiers sensibles repérés et non lus : $files';
  }

  @override
  String get riskReadOnly => 'Lecture seule';

  @override
  String get riskLocal => 'Fichiers générés';

  @override
  String get riskSensitive => 'Modifie le projet';

  @override
  String get riskForbidden => 'Interdite';

  @override
  String get riskReadOnlyDesc =>
      'Ne modifie rien. S\'exécute même en mode simulation.';

  @override
  String get riskLocalDesc =>
      'Écrit seulement des fichiers générés dans le projet (build, dépendances, cache).';

  @override
  String get riskSensitiveDesc =>
      'Modifie des fichiers du projet ou l\'état Git : relis bien avant de confirmer.';

  @override
  String get riskForbiddenDesc => 'Refusée par les garde-fous de LaunchPilot.';

  @override
  String get issueNotAllowlisted =>
      'Outil hors de la liste autorisée (git, flutter, dart, npm, pnpm, yarn, bun, node).';

  @override
  String get issueShell =>
      'Les shells sont interdits : LaunchPilot n\'exécute jamais de chaîne interprétée.';

  @override
  String get issuePrivileged =>
      'Les commandes privilégiées (sudo…) sont interdites.';

  @override
  String get issueInvalidExecutable =>
      'Indique seulement le nom de l\'outil, sans chemin.';

  @override
  String get issueInvalidArgument =>
      'Argument invalide (retour à la ligne ou caractère nul).';

  @override
  String get issueOutsideProject =>
      'Un argument désigne un chemin hors du projet.';

  @override
  String get issueWorkingDirectoryOutside =>
      'Le dossier de travail doit se trouver dans le projet.';

  @override
  String get issuePublication =>
      'La publication passe par un flux dédié, avec confirmation renforcée.';

  @override
  String get issueGitPush =>
      'L\'envoi vers un dépôt distant (push) est interdit ici.';

  @override
  String get issueDestructive =>
      'Opération destructrice ou irréversible : interdite. Les restaurations passent par le mécanisme ciblé de LaunchPilot.';

  @override
  String get issueSystemChange =>
      'Modification de la configuration ou du système : interdite.';

  @override
  String get issueGlobalInstall =>
      'Les installations globales sont interdites.';

  @override
  String get issueRemoteCode =>
      'Exécution de code téléchargé ou arbitraire : interdite.';

  @override
  String get issueUnknownSubcommand =>
      'Sous-commande non reconnue par la politique de sécurité : refusée par prudence.';

  @override
  String get issueRunsProjectScript =>
      'Exécute un script défini par le projet : vérifie son contenu (package.json).';

  @override
  String get issueCreatesTag => 'Crée un tag Git : confirmation renforcée.';

  @override
  String get cmdPreviewTitle => 'Aperçu de la commande';

  @override
  String cmdWorkingDir(String path) {
    return 'Dossier : $path';
  }

  @override
  String get cmdSimulationNote =>
      'Mode simulation : cette commande sera seulement prévisualisée, pas exécutée.';

  @override
  String get cmdRun => 'Exécuter';

  @override
  String get cmdSimulate => 'Simuler';

  @override
  String get cmdConfirmReinforced =>
      'J\'ai relu le récapitulatif et je confirme cette action.';

  @override
  String get cmdNoShellNote =>
      'Les opérateurs |, &&, > … n\'ont aucun effet : aucune commande ne passe par un shell.';

  @override
  String get cmdParseError => 'Guillemet non fermé.';

  @override
  String get terminalSimulationOn =>
      'Mode simulation actif : seules les commandes en lecture seule s\'exécutent.';

  @override
  String get terminalSimulationOff =>
      'Mode simulation désactivé : les commandes confirmées s\'exécutent réellement.';

  @override
  String get terminalSimulationToggle => 'Mode simulation';

  @override
  String get terminalQuick => 'Commandes proposées';

  @override
  String get terminalCustom => 'Commande personnalisée';

  @override
  String get terminalCustomHint => 'git log --oneline -n 20';

  @override
  String get terminalPreview => 'Prévisualiser';

  @override
  String terminalDuration(String seconds) {
    return '$seconds s';
  }

  @override
  String get terminalHistory => 'Historique';

  @override
  String get terminalHistoryEmpty => 'Aucune commande exécutée pour ce projet.';

  @override
  String get terminalNoOutput => 'Aucune sortie.';

  @override
  String get terminalTruncated =>
      'Début de la sortie tronqué (sortie très longue).';

  @override
  String terminalStartFailed(String exe) {
    return 'Impossible de lancer « $exe » : vérifie qu\'il est installé et dans le PATH.';
  }

  @override
  String get runSucceeded => 'Réussie';

  @override
  String get runFailed => 'Échec';

  @override
  String get runCancelled => 'Annulée';

  @override
  String get runTimedOut => 'Délai dépassé';

  @override
  String get runBlocked => 'Bloquée';

  @override
  String get runSimulated => 'Simulée';

  @override
  String get runStartFailed => 'Lancement impossible';

  @override
  String get protectionTitle => 'Protection du projet';

  @override
  String get protectionNoGit =>
      'Pas de dépôt Git : LaunchPilot sauvegarde quand même chaque fichier avant de le modifier, mais un dépôt Git est vivement recommandé.';

  @override
  String get protectionClean =>
      'Dépôt propre : aucune modification non validée.';

  @override
  String protectionDirty(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications non validées',
      one: '1 modification non validée',
    );
    return '$_temp0';
  }

  @override
  String get protectionDirtyHint =>
      'LaunchPilot ne touchera jamais à tes modifications. Pense à les valider (commit) ou à travailler sur une branche dédiée.';

  @override
  String get protectionDetached => 'HEAD détachée';

  @override
  String get protectionRefresh => 'Actualiser';

  @override
  String protectionCreateBranch(String name) {
    return 'Créer la branche $name';
  }

  @override
  String protectionOnBranch(String name) {
    return 'Tu travailles sur la branche $name.';
  }

  @override
  String get protectionGitignoreTitle =>
      'Fichiers sensibles non ignorés par Git';

  @override
  String protectionGitignoreHint(String files) {
    return 'Ils pourraient être versionnés par erreur : $files';
  }

  @override
  String get protectionGitignoreAction => 'Préparer l\'ajout au .gitignore';

  @override
  String get protectionGitignoreLabel => 'Protection des fichiers sensibles';

  @override
  String get protectionChanges => 'Modifications faites par LaunchPilot';

  @override
  String get protectionChangesEmpty =>
      'LaunchPilot n\'a encore modifié aucun fichier de ce projet.';

  @override
  String get protectionRestore => 'Restaurer';

  @override
  String protectionRestored(String date) {
    return 'Restauré le $date';
  }

  @override
  String get changeCreated => 'créé';

  @override
  String get changeModified => 'modifié';

  @override
  String get restoreDone => 'Fichier restauré.';

  @override
  String get restoreConflict =>
      'Restauration refusée : le fichier a été modifié depuis. Tes changements sont conservés.';

  @override
  String get restoreBackupMissing =>
      'Copie de sauvegarde introuvable : restauration impossible.';

  @override
  String get writePreviewTitle => 'Aperçu des modifications';

  @override
  String get writeFileNew => 'Nouveau fichier';

  @override
  String writeDirtyWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Le dépôt contient $count modifications non validées.',
      one: 'Le dépôt contient 1 modification non validée.',
    );
    return '$_temp0 LaunchPilot n\'y touchera pas ; ses propres changements pourront être annulés fichier par fichier.';
  }

  @override
  String get writeBackupNote =>
      'Une copie de chaque fichier est sauvegardée avant l\'écriture, pour pouvoir le restaurer.';

  @override
  String get writeConfirm => 'Écrire les fichiers';

  @override
  String get writeDone => 'Modifications écrites.';

  @override
  String get writeChangedSincePreview =>
      'Un fichier a changé depuis l\'aperçu : rien n\'a été écrit. Relance l\'aperçu.';

  @override
  String writeRefused(String path) {
    return 'Écriture refusée : $path';
  }

  @override
  String get writeTooBig => 'Fichier trop grand pour l\'aperçu ligne à ligne.';

  @override
  String get settingsExecution => 'Exécution des commandes';

  @override
  String get settingsSimulationHint =>
      'Activé : seules les commandes en lecture seule (git status, flutter analyze…) s\'exécutent ; les autres sont seulement prévisualisées. Les commandes interdites (push, publication, suppression…) restent refusées dans tous les cas.';

  @override
  String get checklistBlocked => 'Bloquée';

  @override
  String checklistBlockedBy(String steps) {
    return 'Termine d\'abord : $steps';
  }

  @override
  String checklistLaterPhase(int phase) {
    return 'Automatisation prévue en phase $phase : d\'ici là, suis les explications et marque l\'étape comme faite.';
  }

  @override
  String get checklistGlossary => 'Termes';

  @override
  String get kindCommand => 'Commande';

  @override
  String get kindManual => 'Vérification';

  @override
  String get kindPedagogical => 'À comprendre';

  @override
  String get checklistDone => 'C\'est vérifié';

  @override
  String get checklistUnderstood => 'J\'ai compris';

  @override
  String get checklistReset => 'Recommencer';

  @override
  String get checklistNeedsDetectionTitle => 'Projet pas encore analysé';

  @override
  String get checklistNeedsDetectionMessage =>
      'La checklist est construite à partir du rapport de détection et des cibles retenues.';

  @override
  String get checklistGoDetection => 'Aller à la détection';

  @override
  String get checklistTargetsNotReviewed =>
      'Cibles pas encore validées : la checklist suit la détection.';

  @override
  String checklistActiveTargets(String list) {
    return 'Cibles : $list';
  }

  @override
  String checklistNext(String title) {
    return 'Prochaine étape : $title';
  }

  @override
  String get checklistAllDone => 'Toutes les étapes sont terminées.';

  @override
  String get checklistRunOk => 'Étape réussie.';

  @override
  String get checklistRunFailed =>
      'La commande a échoué : la sortie est dans le terminal.';

  @override
  String get checklistSimulated =>
      'Commande simulée : l\'étape reste à faire. Désactive le mode simulation pour l\'exécuter vraiment.';

  @override
  String get checklistOpenTerminal => 'Voir la sortie';

  @override
  String get contentTabVersion => 'Version';

  @override
  String get contentTabChangelog => 'Changelog';

  @override
  String get contentTabTexts => 'Textes';

  @override
  String get contentTabLegal => 'Juridique';

  @override
  String get contentNeedsProject =>
      'Ouvre un projet pour préparer sa version, ses icônes, ses captures, ses textes et ses documents juridiques.';

  @override
  String get contentNeedsSession =>
      'Démarre une session (tableau de publication) pour enregistrer ces contenus.';

  @override
  String get contentPreviewWrite => 'Prévisualiser et écrire';

  @override
  String get versionNoManifest =>
      'Aucun fichier de version trouvé (pubspec.yaml ou package.json).';

  @override
  String get versionNoLine =>
      'Ce fichier ne contient pas de ligne « version ».';

  @override
  String versionCurrent(String version) {
    return 'Version actuelle : $version';
  }

  @override
  String versionUnparsable(String version) {
    return 'Format « $version » non reconnu : saisis la nouvelle version à la main.';
  }

  @override
  String get versionBumpMajor => 'Majeure';

  @override
  String get versionBumpMinor => 'Mineure';

  @override
  String get versionBumpPatch => 'Correctif';

  @override
  String get versionBumpNone => 'Build seul';

  @override
  String get versionBumpHelp =>
      'Majeure : changement incompatible · Mineure : nouveauté · Correctif : correction.';

  @override
  String get versionIncrementBuild => 'Augmenter le numéro de build';

  @override
  String get versionCustom => 'Ou saisir la version';

  @override
  String versionProposed(String from, String to) {
    return '$from → $to';
  }

  @override
  String versionUseSession(String version) {
    return 'Utiliser la version de la session ($version)';
  }

  @override
  String get versionInvalid =>
      'Version invalide : utilise le format 1.2.3 ou 1.2.3+4.';

  @override
  String get versionNotHigher =>
      'Attention : cette version n\'est pas supérieure à l\'actuelle.';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get changelogRead => 'Lire les commits';

  @override
  String changelogSinceTag(int count, String tag) {
    return '$count commits depuis $tag';
  }

  @override
  String changelogLimited(int count) {
    return 'Aucun tag trouvé : les $count derniers commits';
  }

  @override
  String get changelogNoGit =>
      'Pas de dépôt Git : écris le changelog à la main.';

  @override
  String get changelogTechnical => 'Technique';

  @override
  String get changelogPublic => 'Grand public';

  @override
  String get changelogPublicFallback =>
      'Améliorations et corrections diverses.';

  @override
  String get changelogGroupBreaking => 'Changements importants';

  @override
  String get changelogGroupFeatures => 'Nouveautés';

  @override
  String get changelogGroupFixes => 'Corrections';

  @override
  String get changelogGroupPerformance => 'Performances';

  @override
  String get changelogGroupDocs => 'Documentation';

  @override
  String get changelogGroupOther => 'Autres changements';

  @override
  String get changelogAi => 'Reformuler avec l\'IA';

  @override
  String changelogAiInstruction(String version) {
    return 'Reformule ces messages de commit en deux changelogs Markdown pour la version $version : « technical » pour les développeurs, « public » simple et sans jargon pour le grand public. Commence chacun par « ## $version ». N\'invente aucun changement.';
  }

  @override
  String get changelogWrite => 'Écrire dans CHANGELOG.md';

  @override
  String changelogTag(String tag) {
    return 'Créer le tag $tag';
  }

  @override
  String get changelogTagNote =>
      'Le tag reste local : LaunchPilot ne pousse jamais vers un dépôt distant.';

  @override
  String get changelogEmpty => 'Aucun commit à résumer.';

  @override
  String get iconsChoose => 'Choisir l\'image source';

  @override
  String iconsSourceInfo(String name, int width, int height) {
    return '$name · $width × $height px';
  }

  @override
  String get iconsIssueTooSmall =>
      'Image trop petite : 512 px minimum, 1024 px recommandés.';

  @override
  String get iconsIssueBelowRecommended =>
      'Moins de 1024 px : les grandes icônes pourraient être floues.';

  @override
  String get iconsIssueNotSquare =>
      'Image non carrée : elle sera centrée sur un fond transparent, jamais étirée.';

  @override
  String get iconsIssueTransparent =>
      'Zones transparentes : remplies par la couleur de fond pour les icônes opaques (App Store).';

  @override
  String get iconsIssueUnreadable => 'Image illisible.';

  @override
  String get iconsBackground => 'Couleur de fond (icônes opaques et maskables)';

  @override
  String iconsTargets(int count) {
    return '$count fichiers à produire';
  }

  @override
  String get iconsNoTarget =>
      'Aucune cible avec icônes : retiens Android, iOS ou Web dans la détection.';

  @override
  String get iconsGenerate => 'Générer les icônes';

  @override
  String get iconsGenerating => 'Génération…';

  @override
  String get iconsLabel => 'Icônes de l\'application';

  @override
  String get shotsImport => 'Importer des captures';

  @override
  String get slotPlay => 'Play Store';

  @override
  String get slotIphone69 => 'iPhone 6,9\"';

  @override
  String get slotIphone65 => 'iPhone 6,5\"';

  @override
  String get slotIpad13 => 'iPad 13\"';

  @override
  String get shotsMask => 'Masquer des zones';

  @override
  String shotsMaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zones masquées',
      one: '1 zone masquée',
      zero: 'Aucune zone masquée',
    );
    return '$_temp0';
  }

  @override
  String get shotsMaskHelp =>
      'Fais glisser sur l\'image pour recouvrir une donnée personnelle (nom, e-mail, numéro…). Le recouvrement est définitif dans l\'export.';

  @override
  String get shotsMaskClear => 'Tout effacer';

  @override
  String get shotsMaskApply => 'Valider';

  @override
  String get shotsRemove => 'Retirer';

  @override
  String get shotsCaption => 'Légende';

  @override
  String get shotsFrame => 'Cadre';

  @override
  String get frameNone => 'Aucun';

  @override
  String get frameIndigo => 'Indigo';

  @override
  String get frameLight => 'Clair';

  @override
  String get frameSunset => 'Coucher de soleil';

  @override
  String get shotsFormat => 'Format d\'export';

  @override
  String get formatPlay => 'Play Store 1080 × 1920';

  @override
  String get formatIphone => 'iPhone 1290 × 2796';

  @override
  String get formatIpad => 'iPad 2048 × 2732';

  @override
  String get shotsExport => 'Préparer l\'export';

  @override
  String get shotsLabel => 'Captures pour les stores';

  @override
  String get textsLanguage => 'Langue de la fiche';

  @override
  String get textsPitch => 'Décris l\'application en une phrase';

  @override
  String get textsPitchHint =>
      'Une app météo locale, simple et sans publicité.';

  @override
  String get textsAi => 'Générer avec l\'IA';

  @override
  String textsAiInstruction(String app, String language, String pitch) {
    return 'Rédige la fiche de store de l\'application « $app » en $language. Description : $pitch. Respecte strictement les limites : titre et sous-titre 30 caractères, description courte 80, mots-clés 100 (séparés par des virgules), texte promotionnel 170, description longue 4000. N\'invente aucune fonctionnalité absente de la description.';
  }

  @override
  String get fieldLongDescription => 'Description longue';

  @override
  String get fieldPromoText => 'Texte promotionnel';

  @override
  String textsCounter(int count, int limit) {
    return '$count / $limit';
  }

  @override
  String get textsSave => 'Enregistrer les textes';

  @override
  String get textsSaved => 'Textes enregistrés dans la session.';

  @override
  String get textsOverLimit =>
      'Certains champs dépassent la limite des stores.';

  @override
  String get textsPreviewStore => 'Aperçu de la fiche';

  @override
  String get textsPreviewSocial => 'Aperçu de partage';

  @override
  String get textsNote =>
      'Les textes sont gardés dans la session ; leur envoi aux stores viendra avec Fastlane (phase 9).';

  @override
  String get legalDisclaimer =>
      'Ces documents sont des modèles générés à partir de tes réponses. Ils ne garantissent pas la conformité juridique : relis-les, complète-les et fais-les valider par un professionnel si nécessaire.';

  @override
  String get legalPublisherType => 'Éditeur';

  @override
  String get publisherIndividual => 'Particulier';

  @override
  String get publisherCompany => 'Entreprise';

  @override
  String get legalAppName => 'Nom de l\'application';

  @override
  String get legalPublisherName => 'Nom de l\'éditeur';

  @override
  String get legalAddress => 'Adresse';

  @override
  String get legalEmail => 'E-mail de contact';

  @override
  String get legalCompanyId => 'SIREN / SIRET';

  @override
  String get legalHostName => 'Hébergeur';

  @override
  String get legalHostAddress => 'Adresse de l\'hébergeur';

  @override
  String get legalData => 'Données collectées';

  @override
  String get dataContact => 'Contact';

  @override
  String get dataLocation => 'Localisation';

  @override
  String get dataPhotos => 'Photos / caméra';

  @override
  String get dataAudio => 'Audio';

  @override
  String get dataContacts => 'Carnet de contacts';

  @override
  String get dataUsage => 'Statistiques d\'usage';

  @override
  String get dataCrash => 'Rapports de plantage';

  @override
  String get dataAdId => 'Identifiant publicitaire';

  @override
  String get dataPayment => 'Paiement';

  @override
  String get legalPrefilled =>
      'Préremplies d\'après la détection : vérifie-les.';

  @override
  String get legalThirdParties => 'Services tiers';

  @override
  String get legalAddThirdParty => 'Ajouter un service';

  @override
  String legalRetention(int months) {
    return 'Conservation : $months mois';
  }

  @override
  String get legalCookies =>
      'Le site utilise des cookies de mesure ou de publicité';

  @override
  String get legalMinors =>
      'L\'application s\'adresse aussi aux moins de 15 ans';

  @override
  String legalMissing(String fields) {
    return 'À compléter : $fields';
  }

  @override
  String get legalSave => 'Enregistrer les réponses';

  @override
  String get legalSaved => 'Réponses enregistrées.';

  @override
  String get legalDocLanguage => 'Langue des documents';

  @override
  String get legalGenerate => 'Générer les modèles';

  @override
  String get legalLabel => 'Documents juridiques (modèles)';

  @override
  String get checklistOpenTool => 'Ouvrir l\'outil';

  @override
  String writeBinary(int size) {
    return 'Fichier binaire · $size octets';
  }

  @override
  String get writeImageBefore => 'Avant';

  @override
  String get writeImageAfter => 'Après';

  @override
  String get issueProductionDeploy =>
      'Mise en ligne publique : confirmation renforcée.';

  @override
  String get issuePreviewDeploy =>
      'Mise en ligne sur une adresse de prévisualisation : confirmation renforcée.';

  @override
  String get issueNetwork =>
      'Interroge le site en ligne et écrit un rapport dans le projet.';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCopied => 'Copié dans le presse-papiers.';

  @override
  String get auditAreaResponsive => 'Affichage mobile';

  @override
  String get auditAreaAccessibility => 'Accessibilité';

  @override
  String get auditAreaLinks => 'Liens';

  @override
  String get auditAreaForms => 'Formulaires';

  @override
  String get auditAreaErrors => 'Pages d\'erreur';

  @override
  String get webGapNoScript =>
      'Aucune commande de build déclarée par le projet (script « build » absent) : LaunchPilot n\'en invente pas. Ajoute-en une dans package.json, ou indique le dossier déjà prêt à mettre en ligne.';

  @override
  String get webGapServer =>
      'Ce framework rend les pages côté serveur : il n\'y a pas de dossier statique à déposer. Utilise l\'intégration Git de Vercel ou Netlify, ou configure un export statique.';

  @override
  String get webNoPlan =>
      'Aucun site web reconnu dans ce projet. Lance l\'analyse ou vérifie la cible Web dans le rapport de détection.';

  @override
  String get webBuildTitle => 'Construction';

  @override
  String webFramework(String name) {
    return 'Technologie : $name';
  }

  @override
  String get webOutputDir => 'Dossier de sortie (relatif au projet)';

  @override
  String get webOutputGuessed =>
      'Convention du framework, non confirmée : vérifie-la puis valide avec Entrée.';

  @override
  String get webOutputReady => 'Le dossier de sortie contient index.html.';

  @override
  String get webOutputMissing =>
      'Pas encore de index.html dans le dossier de sortie : construis le site.';

  @override
  String get webBuild => 'Construire (aperçu de la commande)';

  @override
  String get webAuditTitle => 'Audit du site';

  @override
  String get webAuditHelp =>
      'Contrôles statiques, sans réseau : SEO, affichage mobile, PWA, accessibilité, liens internes, contenu mixte, formulaires et page 404.';

  @override
  String get webAuditOutput => 'Site construit';

  @override
  String get webAuditSources => 'Sources';

  @override
  String get webAuditRun => 'Lancer l\'audit';

  @override
  String get webAuditNoFolder => 'Ce dossier n\'existe pas encore.';

  @override
  String webAuditSummary(int failures, int warnings, int ok) {
    return '$failures problème(s), $warnings avertissement(s), $ok contrôle(s) réussi(s)';
  }

  @override
  String get webAuditTruncated =>
      'Site volumineux : seule une partie a été examinée.';

  @override
  String get webAuditLimits =>
      'L\'audit lit les fichiers : il ne remplace ni un test sur de vrais appareils, ni Lighthouse, ni la vérification des liens externes.';

  @override
  String get webPreviewTitle => 'Aperçu local';

  @override
  String get webPreviewHelp =>
      'Sert le dossier de sortie sur ta machine uniquement (127.0.0.1), pour le tester dans un navigateur ou avec Lighthouse.';

  @override
  String get webServeStart => 'Démarrer l\'aperçu';

  @override
  String get webServeStop => 'Arrêter l\'aperçu';

  @override
  String get webPreviewChecks =>
      'À vérifier à la main : affichage sur mobile (mode responsive du navigateur), navigation, formulaires, page 404 et mode hors ligne.';

  @override
  String get webLighthouseMissing =>
      'Lighthouse n\'est pas installé : c\'est facultatif. Pour l\'ajouter (Node.js et Chrome ou Chromium requis), lance dans ton propre terminal :';

  @override
  String get webLighthouseHelp =>
      'Mesure performance, accessibilité, bonnes pratiques et SEO d\'une adresse (aperçu local ou site en ligne). Le rapport est écrit dans lighthouse-report.json, à la racine du projet.';

  @override
  String get webLighthouseUrl => 'Adresse à auditer';

  @override
  String get webLighthouseRun => 'Lancer Lighthouse';

  @override
  String get webLighthouseRead => 'Lire le dernier rapport';

  @override
  String get webLighthouseUnreadable => 'Le rapport Lighthouse est illisible.';

  @override
  String get seoLabel => 'SEO';

  @override
  String get seoAnalyticsLabel => 'Statistiques';

  @override
  String get seoHelp =>
      'Ces informations décrivent le site aux moteurs de recherche et aux réseaux sociaux. LaunchPilot prépare les balises, robots.txt, sitemap.xml et les données schema.org ; tu vois chaque modification avant écriture.';

  @override
  String get seoSiteUrl => 'Adresse publique du site';

  @override
  String get seoSiteUrlInvalid =>
      'Adresse invalide : elle doit commencer par https:// et contenir un domaine.';

  @override
  String get seoSiteName => 'Nom du site';

  @override
  String get seoImage => 'Image de partage (adresse complète)';

  @override
  String get seoImageHint =>
      'Conseillé : 1200 × 630 px, publiée sur le site (par exemple dans le dossier public).';

  @override
  String get seoTwitter => 'Compte X / Twitter (facultatif)';

  @override
  String get seoLocale => 'Langue et pays (Open Graph)';

  @override
  String get seoSchema => 'Type schema.org';

  @override
  String get seoSchemaWebsite => 'Site web';

  @override
  String get seoSchemaApp => 'Application web';

  @override
  String get seoSchemaOrg => 'Organisation';

  @override
  String get seoExtraPaths => 'Autres pages du sitemap (une par ligne)';

  @override
  String get seoSpaNote =>
      'Application monopage : le sitemap contient l\'accueil. Ajoute les autres routes publiques ensuite si besoin.';

  @override
  String seoFiles(String files) {
    return 'Fichiers concernés : $files';
  }

  @override
  String get seoManagedHead =>
      'Ce framework génère lui-même <head> : LaunchPilot ne modifie pas ses fichiers. Recopie ces balises dans la configuration de tête de page (metadata, useHead…).';

  @override
  String get seoNeedsUrl => 'Indique d\'abord l\'adresse publique du site.';

  @override
  String get seoPreviewSearch => 'Aperçu dans un moteur de recherche';

  @override
  String get seoPreviewSocial => 'Aperçu de partage';

  @override
  String get seoPreviewNoImage => 'Aucune image de partage';

  @override
  String get seoAnalyticsTitle => 'Statistiques respectueuses de la vie privée';

  @override
  String get seoAnalyticsHelp =>
      'Plausible et Umami mesurent la fréquentation sans cookie ni donnée personnelle revendue. Il te faut un compte (ou ta propre instance) ; LaunchPilot ajoute seulement le script à la page.';

  @override
  String get seoAnalyticsNone => 'Aucune';

  @override
  String get seoAnalyticsScript =>
      'Adresse du script (facultatif, instance auto-hébergée)';

  @override
  String get seoAnalyticsUmamiId => 'Identifiant du site Umami (website ID)';

  @override
  String get seoAnalyticsLegal =>
      'Pense à le mentionner dans la politique de confidentialité (outil Juridique).';

  @override
  String get seoAnalyticsAdd => 'Ajouter à la page (aperçu)';

  @override
  String get seoAnalyticsRemove => 'Retirer les statistiques (aperçu)';

  @override
  String get pwaLabel => 'PWA';

  @override
  String get pwaHelp =>
      'Une PWA s\'installe comme une application depuis le navigateur. Le manifeste décrit son nom, ses couleurs et ses icônes ; le service worker (facultatif) permet le mode hors ligne.';

  @override
  String get pwaName => 'Nom complet';

  @override
  String get pwaShortName => 'Nom court';

  @override
  String get pwaShortNameHint =>
      'Affiché sous l\'icône : 12 caractères au plus conseillés.';

  @override
  String get pwaDescription => 'Description';

  @override
  String get pwaThemeColor => 'Couleur de thème';

  @override
  String get pwaBackgroundColor => 'Couleur de fond (écran de lancement)';

  @override
  String get pwaColorInvalid => 'Format attendu : #RRGGBB';

  @override
  String get pwaDisplay => 'Mode d\'affichage';

  @override
  String get pwaIconsOk => 'Icônes 192 et 512 px présentes.';

  @override
  String get pwaIconsMissing =>
      'Icônes 192 et 512 px absentes : génère-les avec l\'outil Icônes.';

  @override
  String get pwaWorker => 'Ajouter un service worker hors ligne';

  @override
  String get pwaWorkerHelp =>
      'Crée sw.js (pages en réseau d\'abord avec repli hors ligne, fichiers en cache) et l\'enregistre dans la page.';

  @override
  String get pwaWorkerFlutter =>
      'Le service worker automatique de Flutter est déprécié. Celui-ci le remplace : construis ensuite avec « --pwa-strategy=none » si ta version de Flutter le propose encore, pour éviter deux workers.';

  @override
  String get pwaOfflineTest =>
      'Pour tester : construis, démarre l\'aperçu local, ouvre les outils de développement → Application → cocher « Offline », puis recharge la page.';

  @override
  String pwaProblems(String fields) {
    return 'À corriger : $fields';
  }

  @override
  String get hostingGapFirebase =>
      'Indique l\'identifiant du projet Firebase (visible dans la console Firebase).';

  @override
  String get hostingGapGithub =>
      'Indique le dépôt GitHub sous la forme utilisateur/depot.';

  @override
  String get hostingGapBuild =>
      'Aucune commande de build connue : le workflow GitHub ne saurait pas construire le site.';

  @override
  String hostingLabel(String host) {
    return 'Hébergement $host';
  }

  @override
  String get hostingChoose => 'Hébergeur';

  @override
  String get hostingChooseHelp =>
      'Choisis où publier le site. Ton choix par défaut se règle dans les Paramètres.';

  @override
  String get hostingFirebaseProject => 'Identifiant du projet Firebase';

  @override
  String get hostingNetlifySite =>
      'Nom ou identifiant du site Netlify (facultatif si le dossier est lié)';

  @override
  String get hostingGithubRepo => 'Dépôt GitHub (utilisateur/depot)';

  @override
  String get hostingDomain => 'Domaine personnalisé (facultatif)';

  @override
  String get hostingInvalid => 'Format invalide.';

  @override
  String hostingFiles(String files) {
    return 'Fichiers préparés : $files';
  }

  @override
  String get hostingPrepare => 'Préparer la configuration (aperçu)';

  @override
  String get hostingDeployTitle => 'Mise en ligne';

  @override
  String get hostingGithubDeploy =>
      'GitHub Pages publie le site à chaque push sur main, grâce au workflow préparé ci-dessus. LaunchPilot ne pousse jamais : valide (commit) puis pousse toi-même, puis dans GitHub → Settings → Pages, choisis « GitHub Actions » comme source.';

  @override
  String hostingCliMissing(String cli) {
    return 'L\'outil « $cli » n\'est pas installé. Installe-le dans ton propre terminal (installation globale, jamais lancée par LaunchPilot) :';
  }

  @override
  String hostingLogin(String command) {
    return 'Connexion à ton compte : lance « $command » dans ton propre terminal. LaunchPilot ne voit ni ne stocke tes identifiants.';
  }

  @override
  String get hostingVercelLink =>
      'Au premier déploiement, Vercel peut demander de lier le dossier à un projet : lance « vercel link » dans ton terminal si la commande échoue.';

  @override
  String get hostingNetlifyLink =>
      'Sans nom de site, Netlify utilise le site lié au dossier (« netlify link » dans ton terminal).';

  @override
  String get hostingBuildFirst =>
      'Construis d\'abord le site (onglet Site web) : le dossier de sortie ne contient pas index.html.';

  @override
  String get hostingDeployNote =>
      'Chaque mise en ligne passe par un récapitulatif à cocher, puis par l\'aperçu de la commande avec confirmation renforcée. En mode simulation, rien n\'est publié.';

  @override
  String get hostingDeployPreview => 'Déployer en prévisualisation';

  @override
  String get hostingDeployProduction => 'Déployer en production';

  @override
  String get hostingDnsTitle => 'Domaine et DNS';

  @override
  String get hostingDnsNever =>
      'LaunchPilot ne modifie jamais le DNS : saisis toi-même ces enregistrements chez le gestionnaire de ton domaine.';

  @override
  String get hostingDnsNeedsDomain =>
      'Indique un domaine personnalisé pour voir les enregistrements recommandés.';

  @override
  String get hostingDnsFirebase =>
      'Firebase fournit des valeurs propres à ton projet : console Firebase → Hosting → Ajouter un domaine personnalisé, puis recopie les enregistrements indiqués.';

  @override
  String get hostingDnsVercel =>
      'Valeurs générales de Vercel. Vercel peut recommander des valeurs propres à ton projet : vérifie dans le tableau de bord (Domains) ou avec « vercel domains inspect ».';

  @override
  String get hostingDnsNetlify =>
      'Netlify ne gère pas l\'IPv6 sur cette adresse : supprime tout enregistrement AAAA du domaine racine. Si ton gestionnaire le permet, préfère un ALIAS vers apex-loadbalancer.netlify.com.';

  @override
  String get hostingDnsGithub =>
      'Ajoute aussi le domaine dans GitHub → Settings → Pages (le fichier CNAME est préparé avec la configuration), puis active « Enforce HTTPS ».';

  @override
  String get hostingDnsPropagation =>
      'La propagation peut prendre jusqu\'à 24 heures.';

  @override
  String get hostingDnsCheck => 'Vérifier la résolution';

  @override
  String get hostingDnsNone => 'Le domaine ne se résout pas encore.';

  @override
  String hostingDnsResolved(String addresses) {
    return 'Le domaine pointe vers : $addresses';
  }

  @override
  String get hostingOnlineTitle => 'Vérification en ligne';

  @override
  String get hostingOnlineHelp =>
      'Interroge l\'adresse publique du site : réponse en HTTPS, redirection depuis HTTP et en-tête HSTS.';

  @override
  String get hostingOnlineCheck => 'Vérifier le site en ligne';

  @override
  String hostingHttpsFailed(String error) {
    return 'HTTPS inaccessible ($error).';
  }

  @override
  String hostingHttpsStatus(int code) {
    return 'HTTPS répond (code $code).';
  }

  @override
  String get hostingRedirectUnknown =>
      'Redirection HTTP → HTTPS non vérifiable.';

  @override
  String get hostingRedirectOk => 'HTTP redirige vers HTTPS.';

  @override
  String get hostingRedirectMissing => 'HTTP ne redirige pas vers HTTPS.';

  @override
  String get hostingHstsOk => 'En-tête HSTS présent.';

  @override
  String get hostingHstsMissing =>
      'Pas d\'en-tête HSTS (facultatif, renforce HTTPS).';

  @override
  String get deployRecapProd => 'Récapitulatif : mise en production';

  @override
  String get deployRecapPreview => 'Récapitulatif : prévisualisation';

  @override
  String deployRecapHost(String host) {
    return 'Hébergeur : $host';
  }

  @override
  String deployRecapProject(String name) {
    return 'Projet : $name';
  }

  @override
  String deployRecapFolder(String folder) {
    return 'Dossier publié : $folder';
  }

  @override
  String get deployRecapProdEffect =>
      'Le site public sera remplacé par ce contenu, visible par tous.';

  @override
  String get deployRecapPreviewEffect =>
      'Une adresse temporaire, accessible à quiconque la connaît, sera créée.';

  @override
  String get deployRecapDirty =>
      'Le dépôt contient des modifications non validées : le site publié ne correspondra à aucun commit.';

  @override
  String get deployRecapSimulation =>
      'Mode simulation actif : la commande sera seulement prévisualisée, rien ne sera publié.';

  @override
  String get deployRecapAck =>
      'J\'ai relu ce récapitulatif et je veux publier.';

  @override
  String get deployRecapContinue => 'Continuer vers l\'aperçu de la commande';

  @override
  String get contentTabWeb => 'Site web';

  @override
  String get contentTabHosting => 'Hébergement';

  @override
  String get contentWebNotSelected =>
      'La cible Web n\'est pas retenue pour ce projet : coche-la dans le rapport de détection pour utiliser cet outil.';

  @override
  String get settingsPreferredHost => 'Hébergeur proposé par défaut';

  @override
  String get settingsHostNone => 'Aucun';

  @override
  String get settingsAnalytics => 'Statistiques proposées pour les sites';

  @override
  String get webSeoTitle => 'Titre (balise <title>)';

  @override
  String get webSeoDescription => 'Description';

  @override
  String get issueStorePublication =>
      'Envoi vers Google Play : confirmation renforcée.';

  @override
  String get androidAreaIdentity => 'Identité';

  @override
  String get androidAreaVersion => 'Version';

  @override
  String get androidAreaSdk => 'Versions d\'Android';

  @override
  String get androidAreaSigning => 'Signature';

  @override
  String get androidAreaSecurity => 'Sécurité';

  @override
  String get androidAreaPermissions => 'Permissions';

  @override
  String get androidAreaIcons => 'Icônes';

  @override
  String get androidNoModule =>
      'Aucun dossier android dans ce projet Flutter : génère-le avec « flutter create --platforms=android . » dans ton terminal.';

  @override
  String get androidEnvTitle => 'Environnement Android';

  @override
  String get androidEnvHelp =>
      'Vérifie le SDK Android, Java et les licences avec « flutter doctor -v » (lecture seule). Les versions de Gradle, du plugin Android et de Kotlin sont lues dans le projet.';

  @override
  String androidToolVersions(String gradle, String agp, String kotlin) {
    return 'Gradle $gradle · plugin Android $agp · Kotlin $kotlin';
  }

  @override
  String get androidDoctor => 'Vérifier l\'environnement (flutter doctor -v)';

  @override
  String get androidDoctorEmpty =>
      'Aucune section Android dans la sortie : le SDK Android n\'est peut-être pas installé.';

  @override
  String androidJava(String version) {
    return 'Java : $version';
  }

  @override
  String get androidLicenses =>
      'Pour accepter les licences, lance « flutter doctor --android-licenses » dans ton propre terminal (questions interactives).';

  @override
  String get androidAuditTitle => 'Audit Android';

  @override
  String get androidAuditHelp =>
      'Identifiant, version, API cible, signature, sécurité, permissions (confrontées aux plugins du projet) et icônes. Les fichiers de signature ne sont jamais lus.';

  @override
  String get androidAuditRun => 'Lancer l\'audit Android';

  @override
  String get androidDataSafety =>
      'Les permissions et SDK détectés alimentent la section « Sécurité des données » de la Play Console et le questionnaire juridique (outil Juridique).';

  @override
  String get androidSigningTitle => 'Clé de signature';

  @override
  String get androidSigningHelp =>
      'Chaque version publiée est signée avec ta clé d\'envoi (keystore). Tu la crées une seule fois dans ton terminal : les mots de passe ne passent jamais par LaunchPilot, qui ne lit ni key.properties ni le keystore.';

  @override
  String get androidKeyPropertiesPresent =>
      'android/key.properties est présent (non lu).';

  @override
  String get androidKeyPropertiesMissing =>
      'android/key.properties est absent.';

  @override
  String get androidKeytoolStep =>
      '1. Créer le keystore (dans ton terminal, hors du projet)';

  @override
  String get androidKeyPropertiesStep =>
      '2. Créer android/key.properties (à remplir toi-même)';

  @override
  String get androidPlayAppSigning =>
      'Avec la signature d\'application Play (activée par défaut), Google garde la clé finale ; ta clé ne sert qu\'à l\'envoi et peut être réinitialisée si tu la perds. Sauvegarde-la quand même hors du projet.';

  @override
  String get androidSigningConfigure =>
      '3. Configurer la signature release (aperçu)';

  @override
  String get androidGitignore => 'Ignorer les secrets de signature (aperçu)';

  @override
  String get androidGitignoreDone => 'Le .gitignore contient déjà ces entrées.';

  @override
  String get androidGitignoreLabel => 'Secrets de signature Android';

  @override
  String get androidSigningLabel => 'Signature release Android';

  @override
  String get androidSigningAlready =>
      'La signature release est déjà configurée.';

  @override
  String get androidSigningUnrecognized =>
      'Ce fichier ne ressemble pas au modèle Flutter : LaunchPilot ne le modifie pas. Recopie cet extrait à la main.';

  @override
  String get androidBuildTitle => 'Construction';

  @override
  String get androidBuildHelp =>
      'L\'App Bundle (.aab) est le format exigé par Google Play. L\'APK sert aux tests ou à une distribution hors store ; « par architecture » produit des fichiers plus légers.';

  @override
  String get androidBuildAab => 'Construire l\'App Bundle';

  @override
  String get androidBuildApk => 'Construire l\'APK';

  @override
  String get androidSplitPerAbi => 'Un APK par architecture';

  @override
  String get androidDeliverablesTitle => 'Livrables';

  @override
  String get androidDeliverablesHelp =>
      'Chemin, taille, empreinte SHA-256 et signature des fichiers produits.';

  @override
  String get androidDeliverablesCheck => 'Contrôler les livrables';

  @override
  String get androidDeliverablesNone =>
      'Aucun livrable trouvé : construis d\'abord l\'App Bundle ou l\'APK.';

  @override
  String get androidSignedDebug =>
      'Signé avec la clé de débogage : Google Play le refusera.';

  @override
  String get androidSignedRelease => 'Signé avec ta clé.';

  @override
  String get androidUnsigned => 'Aucune signature trouvée.';

  @override
  String get playFieldTitle => 'Nom de l\'application';

  @override
  String get playFieldShort => 'Description courte';

  @override
  String get playFieldFull => 'Description complète';

  @override
  String get playFieldChangelog => 'Notes de version (cette version)';

  @override
  String get playSaved => 'Fiche Play Store enregistrée dans la session.';

  @override
  String get playListingTitle => 'Fiche Play Store';

  @override
  String get playListingHelp =>
      'Préremplie avec les textes de store et le changelog public de la session ; les limites de Google Play s\'affichent sous chaque champ.';

  @override
  String get playVisualsTitle => 'Visuels';

  @override
  String get playVisualsHelp =>
      'Google Play demande une icône 512 × 512, un visuel de présentation 1024 × 500 et au moins 2 captures. LaunchPilot prépare l\'icône et le visuel à partir d\'une image d\'au moins 512 px, sans la déformer ; les captures viennent de l\'outil Captures (format Play).';

  @override
  String get playIconPick => 'Choisir l\'image de l\'icône';

  @override
  String get playIconTooSmall =>
      'Image trop petite : il faut au moins 512 × 512 px.';

  @override
  String playScreenshots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count captures prêtes',
      one: '1 capture : il en faut au moins 2',
      zero: 'Aucune capture au format Play (outil Captures)',
    );
    return '$_temp0';
  }

  @override
  String get playFastlaneLabel => 'Fastlane Google Play';

  @override
  String get playFastlaneHelp =>
      'Prépare android/fastlane : Appfile (identifiant), Fastfile (envoi sur la piste interne en brouillon, mise à jour de la fiche) et métadonnées de « supply » (textes, icône, visuel, captures). Aucune clé n\'y est écrite.';

  @override
  String get playNoPackage =>
      'Identifiant d\'application introuvable dans build.gradle : lance l\'audit Android.';

  @override
  String playPackage(String package, int code) {
    return 'Application $package · versionCode $code';
  }

  @override
  String get playExamplePackage =>
      'Identifiant « com.example » : Google Play le refusera. Change-le avant le premier envoi.';

  @override
  String get playFastlanePrepare => 'Préparer Fastlane (aperçu)';

  @override
  String get playListingIncomplete =>
      'Remplis au moins le nom et les deux descriptions d\'une langue.';

  @override
  String get playUploadTitle => 'Envoi sur la piste de test interne';

  @override
  String get playFirstUpload =>
      'Le tout premier App Bundle doit être envoyé à la main dans la Play Console (création de l\'application) : Fastlane ne peut prendre le relais qu\'ensuite.';

  @override
  String get playFastlaneMissing =>
      'Fastlane n\'est pas installé. Installe-le dans ton propre terminal (installation système, jamais lancée par LaunchPilot) :';

  @override
  String get playFastfileFirst =>
      'Prépare d\'abord les fichiers Fastlane ci-dessus.';

  @override
  String get playCheckAab => 'Vérifier l\'App Bundle';

  @override
  String playAabReady(String size) {
    return 'App Bundle signé avec ta clé ($size).';
  }

  @override
  String get playJsonKey =>
      'Clé du compte de service (chemin du fichier .json)';

  @override
  String get playJsonKeyHelp =>
      'Créée dans Google Cloud et autorisée dans la Play Console. LaunchPilot ne lit ni ne copie ce fichier : seul son chemin est passé à Fastlane. Garde-le hors du projet.';

  @override
  String get playJsonKeyInvalid =>
      'Chemin absolu d\'un fichier .json existant attendu.';

  @override
  String get playJsonKeyInProject =>
      'Cette clé est dans le projet : déplace-la ailleurs ou vérifie qu\'elle est ignorée par Git.';

  @override
  String get playValidateKey => 'Vérifier la clé';

  @override
  String get playUploadInternal => 'Envoyer sur la piste interne (brouillon)';

  @override
  String get playUploadMetadata => 'Mettre à jour la fiche';

  @override
  String get playUploadNote =>
      'La version est créée en brouillon : tu la déploies toi-même auprès des testeurs dans la Play Console. LaunchPilot ne publie jamais en production.';

  @override
  String get playRecapInternal => 'Récapitulatif : envoi sur la piste interne';

  @override
  String get playRecapMetadata => 'Récapitulatif : mise à jour de la fiche';

  @override
  String playRecapPackage(String package) {
    return 'Application : $package';
  }

  @override
  String playRecapVersionCode(int code) {
    return 'versionCode : $code (ne pourra plus être réutilisé)';
  }

  @override
  String get playRecapInternalEffect =>
      'L\'App Bundle est envoyé à Google Play et une version brouillon est créée sur la piste de test interne.';

  @override
  String get playRecapMetadataEffect =>
      'Les textes, l\'icône, le visuel et les captures de la fiche publique sont remplacés.';

  @override
  String get contentTabAndroid => 'Android';

  @override
  String get contentTabPlay => 'Play Store';

  @override
  String get contentAndroidNotSelected =>
      'La cible Android n\'est pas retenue pour ce projet Flutter : coche-la dans le rapport de détection pour utiliser cet outil.';

  @override
  String get iosAreaLinux => 'Machine utilisée';

  @override
  String get iosAreaPrivacy => 'Confidentialité';

  @override
  String get iosNoModule =>
      'Aucun dossier ios dans ce projet Flutter : génère-le avec « flutter create --platforms=ios . » dans ton terminal (possible sous Linux).';

  @override
  String get iosLimitsTitle =>
      'iOS depuis Linux : ce qui est possible, et ce qui ne l\'est pas';

  @override
  String get iosMacTitle =>
      'Mac détecté : LaunchPilot prépare quand même tout pour une CI';

  @override
  String get iosLimitsCannot => 'Impossible sous Linux :';

  @override
  String get iosLimit1 =>
      'construire l\'application (flutter build ios / ipa) : il faut Xcode, qui n\'existe que sur macOS ;';

  @override
  String get iosLimit2 =>
      'signer avec un certificat Apple et un profil de provisioning, ou ouvrir le projet dans Xcode ;';

  @override
  String get iosLimit3 =>
      'lancer le simulateur iOS ou prendre des captures dessus ;';

  @override
  String get iosLimit4 =>
      'envoyer un build sur App Store Connect (l\'envoi se fait depuis la CI macOS).';

  @override
  String get iosLimitsCan => 'Possible ici, avec aperçu avant écriture :';

  @override
  String get iosCan1 =>
      'auditer le projet, compléter Info.plist et le manifeste de confidentialité ;';

  @override
  String get iosCan2 =>
      'préparer la fiche App Store, les captures (outil Captures) et Fastlane ;';

  @override
  String get iosCan3 =>
      'générer la configuration GitHub Actions (runner macOS) ou Codemagic.';

  @override
  String get iosNeverFake =>
      'LaunchPilot n\'affiche jamais un build iOS réussi qu\'il n\'a pas vu : seul le tableau de bord de la CI fait foi.';

  @override
  String get iosAuditTitle => 'Audit iOS';

  @override
  String get iosAuditHelp =>
      'Lit Info.plist, project.pbxproj et l\'icône App Store : identifiant, textes d\'accès exigés par les plugins, manifeste de confidentialité, chiffrement, équipe et signature.';

  @override
  String get iosAuditRun => 'Lancer l\'audit iOS';

  @override
  String get iosPlistTitle => 'Textes d\'accès et chiffrement (Info.plist)';

  @override
  String get iosPlistRunAudit =>
      'Lance d\'abord l\'audit : les textes manquants ou trop vagues apparaîtront ici, avec une proposition à adapter.';

  @override
  String get iosPlistHelp =>
      'Chaque texte est montré à l\'utilisateur au moment de la demande d\'accès : explique concrètement à quoi il sert.';

  @override
  String get iosEncryption =>
      'L\'application n\'utilise que le chiffrement standard (HTTPS)';

  @override
  String get iosEncryptionHelp =>
      'Déclare ITSAppUsesNonExemptEncryption = false pour ne plus répondre à la question à chaque envoi. Désactive si l\'application chiffre elle-même des données.';

  @override
  String get iosPlistLabel => 'Info.plist iOS';

  @override
  String get iosPlistUnrecognized =>
      'Info.plist n\'a pas la forme attendue : modifie-le à la main.';

  @override
  String get iosPrivacyTitle =>
      'Manifeste de confidentialité (PrivacyInfo.xcprivacy)';

  @override
  String get iosPrivacyHelp =>
      'Préparé à partir du questionnaire juridique (ou de la détection) puis ajouté à la cible Runner du projet Xcode, comme le ferait Xcode. Les plugins déclarent eux-mêmes leurs API sensibles.';

  @override
  String get iosTracking =>
      'L\'application suit les utilisateurs entre applications (pistage publicitaire)';

  @override
  String get iosTrackingHelp =>
      'Si oui, il faut aussi lister les domaines de pistage et demander l\'autorisation ATT : complète le fichier ensuite.';

  @override
  String get iosPrivacyPrepare => 'Préparer le manifeste (aperçu)';

  @override
  String get iosPrivacyLabel => 'Manifeste de confidentialité iOS';

  @override
  String get iosPbxUnrecognized =>
      'Le projet Xcode ne ressemble pas au modèle Flutter : seul le fichier est préparé. Ajoute-le à la cible Runner dans Xcode, sur un Mac.';

  @override
  String get iosPrivacyNote =>
      'Ce manifeste est un point de départ à relire : il ne garantit pas la conformité aux règles d\'Apple.';

  @override
  String get iosAppleTitle => 'Ce qui reste à faire chez Apple';

  @override
  String get iosAppleHelp =>
      'Ces étapes se font dans un navigateur, sous Linux comme ailleurs. LaunchPilot ne s\'y connecte jamais.';

  @override
  String get iosApple1 =>
      'Adhérer à l\'Apple Developer Program (abonnement annuel) et noter ton Team ID (Membership).';

  @override
  String get iosApple2 =>
      'Enregistrer l\'identifiant de l\'application (Identifiers → App IDs) avec le même bundle ID que le projet.';

  @override
  String get iosApple3 =>
      'Créer la fiche de l\'application dans App Store Connect (Mes apps → +) : nom, langue, bundle ID.';

  @override
  String get iosApple4 =>
      'Créer une clé API App Store Connect (Utilisateurs et accès → Intégrations) pour la CI ; le fichier .p8 ne se télécharge qu\'une fois.';

  @override
  String get iosApple5 =>
      'Remplir « Confidentialité de l\'app » et la classification par âge dans App Store Connect.';

  @override
  String get iosApple6 =>
      'Après le premier build reçu, ajouter des testeurs TestFlight.';

  @override
  String get iosCertificates =>
      'Certificat de distribution : prouve que l\'application vient de ton équipe. Profil de provisioning : relie ce certificat, l\'identifiant de l\'application et ses droits. Avec la signature automatique, la CI les crée et les renouvelle grâce à la clé API (rôle Admin recommandé pour qu\'elle puisse créer les certificats).';

  @override
  String get iosCiTitle => 'Build et envoi par une CI macOS';

  @override
  String get iosCiHelp =>
      'GitHub Actions : runner macOS 26 avec Xcode 26, signature automatique par la clé API, envoi sur TestFlight. Codemagic : signature et publication gérées par son intégration App Store Connect.';

  @override
  String get iosTeamId => 'Team ID Apple';

  @override
  String get iosTeamIdHelp =>
      '10 caractères, visible dans « Membership » du compte développeur. Ce n\'est pas un secret.';

  @override
  String get iosAppleAppId => 'Identifiant Apple de l\'application (Apple ID)';

  @override
  String get iosAppleAppIdHelp =>
      'Nombre visible dans App Store Connect → Informations sur l\'app. Sert à calculer le numéro de build suivant.';

  @override
  String iosCiGithubSecrets(String names) {
    return 'Secrets à créer dans GitHub (Settings → Secrets and variables → Actions) : $names. Les valeurs ne passent jamais par LaunchPilot.';
  }

  @override
  String get iosCiCodemagicSetup =>
      'Dans Codemagic : ajoute la clé API App Store Connect (Teams → Integrations) sous le nom « launchpilot », puis relie le dépôt.';

  @override
  String get iosCiPrepare => 'Préparer la configuration CI (aperçu)';

  @override
  String iosCiLabel(String provider) {
    return 'CI iOS $provider';
  }

  @override
  String get iosCiNote =>
      'Le build ne démarre que lorsque tu le lances toi-même sur la CI, après avoir validé et poussé ces fichiers : LaunchPilot ne pousse jamais et ne déclenche aucun build.';

  @override
  String get iosKeyBase64 =>
      'Pour ASC_KEY_P8_BASE64, encode le fichier .p8 dans ton terminal : « base64 -w0 AuthKey_XXXXXXXXXX.p8 », puis colle le résultat dans GitHub.';

  @override
  String get asFieldName => 'Nom de l\'application';

  @override
  String get asFieldSubtitle => 'Sous-titre';

  @override
  String get asFieldDescription => 'Description';

  @override
  String get asFieldKeywords => 'Mots-clés';

  @override
  String get asFieldPromo => 'Texte promotionnel';

  @override
  String get asFieldReleaseNotes => 'Nouveautés de cette version';

  @override
  String get asKeywordsHint =>
      'Séparés par des virgules, sans espace ; inutile de répéter le nom.';

  @override
  String get asSaved => 'Fiche App Store enregistrée dans la session.';

  @override
  String get asListingTitle => 'Fiche App Store';

  @override
  String get asListingHelp =>
      'Préremplie avec les textes de store et le changelog de la session ; les limites d\'Apple s\'affichent sous chaque champ.';

  @override
  String get asSupportUrl => 'Adresse d\'assistance (obligatoire)';

  @override
  String get asPrivacyUrl =>
      'Adresse de la politique de confidentialité (obligatoire)';

  @override
  String get asPrivacyUrlHelp =>
      'La politique préparée par l\'outil Juridique, une fois publiée sur ton site.';

  @override
  String get asMarketingUrl => 'Site de l\'application (facultatif)';

  @override
  String get asCopyright => 'Copyright';

  @override
  String get asScreenshotsTitle => 'Captures';

  @override
  String get asScreenshotsHelp =>
      'Elles viennent de l\'outil Captures (formats iPhone 1290 × 2796 et iPad 2048 × 2732), puisque le simulateur iOS n\'existe pas sous Linux. Il en faut de 1 à 10 par appareil.';

  @override
  String asIphoneShots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count captures iPhone prêtes',
      one: '1 capture iPhone prête',
      zero: 'Aucune capture iPhone : il en faut au moins une',
    );
    return '$_temp0';
  }

  @override
  String asIpadShots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count captures iPad prêtes',
      one: '1 capture iPad prête',
      zero:
          'Aucune capture iPad : nécessaire car l\'application accepte l\'iPad',
    );
    return '$_temp0';
  }

  @override
  String get asPrivacyTitle =>
      'Confidentialité de l\'app (étiquettes App Store)';

  @override
  String get asPrivacyHelp =>
      'D\'après le questionnaire juridique, voici les données à déclarer :';

  @override
  String get asPrivacyNone =>
      'Aucune donnée déclarée dans le questionnaire : vérifie-le avant de répondre « Aucune donnée collectée ».';

  @override
  String get asPrivacyManual =>
      'Ces réponses se saisissent à la main dans App Store Connect (Confidentialité de l\'app). Elles doivent correspondre au manifeste de confidentialité et à la politique publiée.';

  @override
  String get asFastlaneLabel => 'Fastlane App Store';

  @override
  String get asFastlaneHelp =>
      'Prépare ios/fastlane : Appfile (identifiants publics), Fastfile (lanes metadata et beta) et métadonnées « deliver » (textes, adresses, captures). La clé App Store Connect vient des variables d\'environnement de la CI : aucune clé n\'est écrite.';

  @override
  String get asFastlanePrepare => 'Préparer Fastlane (aperçu)';

  @override
  String get asFastlaneMissing =>
      'Il faut le nom, la description et les mots-clés d\'une langue, et des adresses d\'assistance et de confidentialité en https.';

  @override
  String get asFastlaneWhere =>
      'Ces lanes se lancent sur un Mac ou dans la CI macOS (« fastlane ios metadata ») : LaunchPilot ne les exécute pas sous Linux.';

  @override
  String get contentTabIos => 'iOS';

  @override
  String get contentTabAppStore => 'App Store';

  @override
  String get contentIosNotSelected =>
      'La cible iOS n\'est pas retenue pour ce projet Flutter : coche-la dans le rapport de détection pour utiliser cet outil.';

  @override
  String get chatTooLarge =>
      'Le message et le contexte choisi sont trop longs : décoche un élément de contexte ou raccourcis la question.';

  @override
  String get chatClearTitle => 'Effacer la conversation ?';

  @override
  String get chatClearMessage =>
      'Les messages de cette session seront supprimés de LaunchPilot. Les fournisseurs d\'IA gardent leurs propres journaux selon leurs conditions.';

  @override
  String get chatQuickNext =>
      'Explique-moi simplement la prochaine étape de ma checklist.';

  @override
  String get chatQuickSimpler =>
      'Reformule ta dernière réponse plus simplement, avec un exemple.';

  @override
  String get chatQuickError =>
      'Que signifie l\'erreur de ma dernière commande, et que puis-je essayer ?';

  @override
  String get chatQuickRemaining =>
      'Que me reste-t-il à faire avant de publier ?';

  @override
  String get chatNoKeyTitle => 'Aucune clé API pour le fournisseur choisi';

  @override
  String chatNoKeyMessage(String provider) {
    return 'Le chat utilise $provider. Enregistre une clé dans les Paramètres (elle reste dans le trousseau du système) ou choisis un autre fournisseur.';
  }

  @override
  String get chatOpenSettings => 'Ouvrir les paramètres';

  @override
  String get chatSafety =>
      'Chaque question passe par un aperçu de ce qui sera envoyé, secrets masqués, puis par ta confirmation. L\'agent conseille seulement : il ne peut exécuter aucune commande ni modifier aucun fichier.';

  @override
  String get chatEmpty =>
      'Pose une question sur ton projet, une étape, une erreur ou un terme technique.';

  @override
  String get chatClear => 'Effacer la conversation';

  @override
  String get chatContextTitle => 'Contexte joint à la question';

  @override
  String get chatCtxProject => 'Résumé du projet';

  @override
  String get chatCtxChecklist => 'État de la checklist';

  @override
  String get chatCtxCommand => 'Dernière commande';

  @override
  String get chatContextHelp =>
      'Seuls les éléments cochés sont envoyés, avec les derniers échanges. Aucun fichier du projet n\'est transmis.';

  @override
  String chatModel(String model) {
    return 'Réponse de $model';
  }

  @override
  String get reportStatusCompleted => 'Session close';

  @override
  String get reportStatusActive => 'Session en cours';

  @override
  String get reportWriteFailed =>
      'Impossible d\'écrire le rapport à cet emplacement.';

  @override
  String get reportSaved => 'Rapport enregistré.';

  @override
  String get reportsHistoryTitle => 'Historique des sessions';

  @override
  String reportsProgress(int done, int total) {
    return '$done / $total étapes';
  }

  @override
  String reportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rapports exportés',
      one: '1 rapport exporté',
    );
    return '$_temp0';
  }

  @override
  String get reportsOpen => 'Aperçu du rapport';

  @override
  String reportsDetailTitle(String project, String version) {
    return 'Rapport : $project $version';
  }

  @override
  String reportsStepsLine(int done, int total) {
    return 'Checklist : $done étapes terminées sur $total';
  }

  @override
  String reportsFilesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers créés ou modifiés',
      one: '1 fichier créé ou modifié',
      zero: 'Aucun fichier modifié',
    );
    return '$_temp0';
  }

  @override
  String reportsCommandsLine(int count, int checks) {
    return '$count commande(s) exécutée(s), dont $checks test(s) ou analyse(s)';
  }

  @override
  String reportsDeliverablesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livrables',
      one: '1 livrable',
      zero: 'Aucun livrable trouvé',
    );
    return '$_temp0';
  }

  @override
  String reportsAuditLine(String title, int failures, int warnings) {
    return 'Audit $title : $failures problème(s), $warnings avertissement(s)';
  }

  @override
  String get reportsContents =>
      'Le rapport contient aussi les technologies et cibles, les commandes (secrets masqués), les actions restantes, la procédure manuelle de publication et le lexique.';

  @override
  String get reportsPdfHint =>
      'Fichier HTML autonome : ouvre-le dans un navigateur, puis Imprimer → Enregistrer au format PDF pour obtenir un PDF.';

  @override
  String get reportsPrevious => 'Rapports déjà exportés pour cette session';

  @override
  String get helpManualTitle => 'Manuel complet';

  @override
  String get helpManualSearch => 'Rechercher dans le manuel';
}

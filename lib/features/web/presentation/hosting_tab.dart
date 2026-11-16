import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/hosting.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../content/presentation/content_workspace.dart';
import '../../git/application/git_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../application/web_providers.dart';
import '../data/web_services.dart';
import '../domain/hosting.dart';
import '../domain/seo.dart';
import '../domain/web_build.dart';

String gapText(AppLocalizations l10n, HostingGap g) => switch (g) {
  HostingGap.firebaseProject => l10n.hostingGapFirebase,
  HostingGap.githubRepo => l10n.hostingGapGithub,
  HostingGap.buildCommand => l10n.hostingGapBuild,
};

/// Préparation de l'hébergement, mise en ligne par le flux dédié,
/// enregistrements DNS recommandés et vérification du site en ligne.
class HostingTab extends ConsumerStatefulWidget {
  const HostingTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<HostingTab> createState() => _HostingTabState();
}

enum _F { firebase, netlify, github, domain, siteUrl }

class _HostingTabState extends ConsumerState<HostingTab> {
  late final WebProjectConfig _initial = ref.read(webConfigProvider);
  late final _c = {
    _F.firebase: TextEditingController(text: _initial.firebaseProject),
    _F.netlify: TextEditingController(text: _initial.netlifySite),
    _F.github: TextEditingController(text: _initial.githubRepo),
    _F.domain: TextEditingController(text: _initial.customDomain),
    _F.siteUrl: TextEditingController(text: _initial.siteUrl),
  };
  List<String>? _resolved;
  SiteCheck? _check;
  bool _checking = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  WebProjectConfig _config(WebProjectConfig base) => base.copyWith(
    firebaseProject: _c[_F.firebase]!.text.trim(),
    netlifySite: _c[_F.netlify]!.text.trim(),
    githubRepo: _c[_F.github]!.text.trim(),
    customDomain: _c[_F.domain]!.text.trim().toLowerCase(),
    siteUrl: _c[_F.siteUrl]!.text.trim(),
  );

  Future<void> _save() async {
    final ctrl = ref.read(webConfigProvider.notifier);
    await ctrl.update(_config(ref.read(webConfigProvider)));
  }

  Future<void> _prepare(HostingProvider host, WebBuildPlan plan) async {
    final l10n = context.l10n;
    await _save();
    final config = ref.read(webConfigProvider);
    final writer = ref.read(projectWriterProvider);
    final root = widget.ctx.root;
    final files = hostingFiles(
      host,
      config,
      plan,
      existing: {
        for (final f in const ['firebase.json', '.firebaserc'])
          f: writer.readCurrent(root, f),
      },
    );
    final set = await writer.plan(root, l10n.hostingLabel(host.label), {
      for (final f in files) f.path: f.content,
    });
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  Future<void> _deploy(
    HostingProvider host,
    WebBuildPlan plan,
    DeployKind kind,
  ) async {
    await _save();
    final config = ref.read(webConfigProvider);
    final spec = deployCommand(host, config, plan, widget.ctx.root, kind);
    if (spec == null || !mounted) return;
    final git = ref.read(gitStatusProvider).value;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeployRecap(
        host: host,
        kind: kind,
        project: widget.ctx.ws.project.name,
        outputDir: config.outputDir ?? plan.outputDir,
        command: spec.display,
        dirty: git != null && git.isRepo && !git.clean,
        simulation: ref.read(settingsControllerProvider).simulationMode,
      ),
    );
    if (ok != true || !mounted) return;
    await previewAndRun(context, ref, spec);
  }

  Future<void> _resolve(String domain) async {
    final r = await ref.read(dnsResolverProvider).lookup(domain);
    if (mounted) setState(() => _resolved = r);
  }

  Future<void> _checkOnline(String host) async {
    setState(() => _checking = true);
    final r = await ref.read(siteCheckerProvider).check(host);
    if (mounted) {
      setState(() {
        _check = r;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final plan = ref.watch(webBuildPlanProvider);
    if (plan == null) return Text(l10n.webNoPlan);
    final saved = ref.watch(webConfigProvider);
    final host = saved.host;
    final config = _config(saved);
    final tools = ref.watch(installedToolsProvider).value ?? const <String>{};
    final writer = ref.read(projectWriterProvider);
    final outputReady =
        writer.readCurrent(
          widget.ctx.root,
          widget.ctx.join(config.outputDir ?? plan.outputDir, 'index.html'),
        ) !=
        null;
    final domain = config.customDomain;
    final domainOk = domain.isNotEmpty && validDomain(domain);
    final siteHost = isValidSiteUrl(config.siteUrl)
        ? Uri.parse(config.siteUrl).host
        : null;

    Widget field(_F f, String label, {String? hint, String? error}) =>
        TextField(
          key: ValueKey('hosting-${f.name}'),
          controller: _c[f],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: error,
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _save(),
        );

    final gaps = host == null
        ? const <HostingGap>[]
        : hostingGaps(host, config, plan);
    final cli = host == null ? null : hostingCli(host);
    final cliInstalled = cli != null && tools.contains(cli);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.hostingChoose, style: theme.textTheme.titleMedium),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in HostingProvider.values)
                    ChoiceChip(
                      key: ValueKey('host-${h.name}'),
                      label: Text(h.label),
                      selected: host == h,
                      onSelected: (_) => ref
                          .read(webConfigProvider.notifier)
                          .update(_config(saved).copyWith(host: h)),
                    ),
                ],
              ),
              if (host == null) Text(l10n.hostingChooseHelp),
              if (plan.gap case WebBuildGap.serverRendered)
                Text(
                  l10n.webGapServer,
                  style: TextStyle(color: palette.statusWarning),
                ),
              if (host == HostingProvider.firebase)
                field(
                  _F.firebase,
                  l10n.hostingFirebaseProject,
                  hint: 'meteo-1234',
                  error:
                      config.firebaseProject.isNotEmpty &&
                          !validFirebaseProject(config.firebaseProject)
                      ? l10n.hostingInvalid
                      : null,
                ),
              if (host == HostingProvider.netlify)
                field(
                  _F.netlify,
                  l10n.hostingNetlifySite,
                  error:
                      config.netlifySite.isNotEmpty &&
                          !validNetlifySite(config.netlifySite)
                      ? l10n.hostingInvalid
                      : null,
                ),
              if (host == HostingProvider.githubPages)
                field(
                  _F.github,
                  l10n.hostingGithubRepo,
                  hint: 'utilisateur/depot',
                  error:
                      config.githubRepo.isNotEmpty &&
                          !validGithubRepo(config.githubRepo)
                      ? l10n.hostingInvalid
                      : null,
                ),
              if (host != null) ...[
                field(
                  _F.domain,
                  l10n.hostingDomain,
                  hint: 'www.exemple.fr',
                  error: domain.isNotEmpty && !domainOk
                      ? l10n.hostingInvalid
                      : null,
                ),
                field(_F.siteUrl, l10n.seoSiteUrl, hint: 'https://exemple.fr'),
                for (final g in gaps)
                  Text(
                    gapText(l10n, g),
                    style: TextStyle(color: palette.statusWarning),
                  ),
                Text(
                  l10n.hostingFiles(
                    hostingFiles(
                      host,
                      config,
                      plan,
                    ).map((f) => f.path).join(', '),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                FilledButton.tonalIcon(
                  key: const ValueKey('hosting-prepare'),
                  onPressed: gaps.isEmpty ? () => _prepare(host, plan) : null,
                  icon: const Icon(Icons.difference_outlined),
                  label: Text(l10n.hostingPrepare),
                ),
              ],
            ],
          ),
        ),
        if (host != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  l10n.hostingDeployTitle,
                  style: theme.textTheme.titleMedium,
                ),
                if (host == HostingProvider.githubPages)
                  Text(
                    l10n.hostingGithubDeploy,
                    key: const ValueKey('hosting-github-steps'),
                  )
                else ...[
                  if (!cliInstalled) ...[
                    Text(
                      l10n.hostingCliMissing(cli!),
                      key: const ValueKey('hosting-cli-missing'),
                    ),
                    SelectableText(
                      hostingInstall(host)!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                  Text(l10n.hostingLogin(hostingLogin(host)!)),
                  if (host == HostingProvider.vercel)
                    Text(l10n.hostingVercelLink),
                  if (host == HostingProvider.netlify &&
                      config.netlifySite.isEmpty)
                    Text(l10n.hostingNetlifyLink),
                  if (!outputReady)
                    Text(
                      l10n.hostingBuildFirst,
                      style: TextStyle(color: palette.statusWarning),
                    ),
                  Text(
                    l10n.hostingDeployNote,
                    style: theme.textTheme.bodySmall,
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const ValueKey('deploy-preview'),
                        onPressed: outputReady && gaps.isEmpty && cliInstalled
                            ? () => _deploy(host, plan, DeployKind.preview)
                            : null,
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(l10n.hostingDeployPreview),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('deploy-production'),
                        onPressed: outputReady && gaps.isEmpty && cliInstalled
                            ? () => _deploy(host, plan, DeployKind.production)
                            : null,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: Text(l10n.hostingDeployProduction),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        if (host != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(l10n.hostingDnsTitle, style: theme.textTheme.titleMedium),
                Text(
                  l10n.hostingDnsNever,
                  style: TextStyle(color: palette.statusPedagogy),
                ),
                if (!domainOk)
                  Text(l10n.hostingDnsNeedsDomain)
                else ...[
                  _DnsTable(
                    records: dnsRecords(
                      host,
                      domain,
                      githubUser: config.githubRepo.split('/').first,
                      netlifySite: config.netlifySite,
                    ),
                  ),
                  Text(switch (host) {
                    HostingProvider.firebase => l10n.hostingDnsFirebase,
                    HostingProvider.vercel => l10n.hostingDnsVercel,
                    HostingProvider.netlify => l10n.hostingDnsNetlify,
                    HostingProvider.githubPages => l10n.hostingDnsGithub,
                  }, style: theme.textTheme.bodySmall),
                  Text(
                    l10n.hostingDnsPropagation,
                    style: theme.textTheme.bodySmall,
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('dns-check'),
                    onPressed: () => _resolve(domain),
                    icon: const Icon(Icons.dns_outlined),
                    label: Text(l10n.hostingDnsCheck),
                  ),
                  if (_resolved case final r?)
                    Text(
                      r.isEmpty
                          ? l10n.hostingDnsNone
                          : l10n.hostingDnsResolved(r.join(', ')),
                      key: const ValueKey('dns-result'),
                    ),
                ],
              ],
            ),
          ),
        if (host != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  l10n.hostingOnlineTitle,
                  style: theme.textTheme.titleMedium,
                ),
                Text(l10n.hostingOnlineHelp),
                OutlinedButton.icon(
                  key: const ValueKey('online-check'),
                  onPressed: siteHost == null || _checking
                      ? null
                      : () => _checkOnline(siteHost),
                  icon: const Icon(Icons.https_outlined),
                  label: Text(l10n.hostingOnlineCheck),
                ),
                if (siteHost == null) Text(l10n.seoNeedsUrl),
                if (_check case final c?) ...[
                  _CheckRow(
                    ok: c.httpsOk,
                    text: c.httpsStatus == null
                        ? l10n.hostingHttpsFailed(c.error ?? '?')
                        : l10n.hostingHttpsStatus(c.httpsStatus!),
                  ),
                  _CheckRow(
                    ok: c.redirectsToHttps ?? false,
                    text: c.redirectsToHttps == null
                        ? l10n.hostingRedirectUnknown
                        : c.redirectsToHttps!
                        ? l10n.hostingRedirectOk
                        : l10n.hostingRedirectMissing,
                  ),
                  _CheckRow(
                    ok: c.hsts,
                    text: c.hsts ? l10n.hostingHstsOk : l10n.hostingHstsMissing,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.ok, required this.text});

  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = LaunchPalette.of(context);
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.warning_amber,
          size: 20,
          color: ok ? palette.statusSucceeded : palette.statusWarning,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _DnsTable extends StatelessWidget {
  const _DnsTable({required this.records});

  final List<DnsRecord> records;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (records.isEmpty) return const SizedBox.shrink();
    const mono = TextStyle(fontFamily: 'monospace');
    return Column(
      key: const ValueKey('dns-records'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in records)
          Row(
            children: [
              SizedBox(width: 64, child: Text(r.type, style: mono)),
              SizedBox(width: 64, child: Text(r.name, style: mono)),
              Expanded(child: SelectableText(r.value, style: mono)),
              IconButton(
                tooltip: l10n.commonCopy,
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: r.value));
                  showInfo(ScaffoldMessenger.of(context), l10n.commonCopied);
                },
              ),
            ],
          ),
      ],
    );
  }
}

/// Récapitulatif avant toute mise en ligne : à cocher explicitement.
class _DeployRecap extends StatefulWidget {
  const _DeployRecap({
    required this.host,
    required this.kind,
    required this.project,
    required this.outputDir,
    required this.command,
    required this.dirty,
    required this.simulation,
  });

  final HostingProvider host;
  final DeployKind kind;
  final String project;
  final String outputDir;
  final String command;
  final bool dirty;
  final bool simulation;

  @override
  State<_DeployRecap> createState() => _DeployRecapState();
}

class _DeployRecapState extends State<_DeployRecap> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final prod = widget.kind == DeployKind.production;
    return AlertDialog(
      title: Text(prod ? l10n.deployRecapProd : l10n.deployRecapPreview),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(l10n.deployRecapHost(widget.host.label)),
            Text(l10n.deployRecapProject(widget.project)),
            Text(
              l10n.deployRecapFolder(
                widget.outputDir.isEmpty ? '.' : widget.outputDir,
              ),
            ),
            SelectableText(
              widget.command,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            Text(
              prod ? l10n.deployRecapProdEffect : l10n.deployRecapPreviewEffect,
            ),
            if (widget.dirty)
              Text(
                l10n.deployRecapDirty,
                style: TextStyle(color: palette.statusWarning),
              ),
            if (widget.simulation)
              Text(
                l10n.deployRecapSimulation,
                style: TextStyle(color: palette.statusPedagogy),
              ),
            CheckboxListTile(
              key: const ValueKey('deploy-ack'),
              contentPadding: EdgeInsets.zero,
              value: _ack,
              onChanged: (v) => setState(() => _ack = v ?? false),
              title: Text(l10n.deployRecapAck),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('deploy-continue'),
          onPressed: _ack ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.deployRecapContinue),
        ),
      ],
    );
  }
}

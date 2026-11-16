import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Recherche d'un exécutable dans le PATH, sans le lancer.
abstract interface class ToolLocator {
  Future<bool> isInstalled(String executable);
}

class PathToolLocator implements ToolLocator {
  const PathToolLocator();

  @override
  Future<bool> isInstalled(String executable) async {
    final path = Platform.environment['PATH'] ?? '';
    for (final dir in path.split(':')) {
      if (dir.isEmpty) continue;
      final f = File(p.join(dir, executable));
      if (f.existsSync()) return true;
    }
    return false;
  }
}

/// Serveur HTTP local, limité à 127.0.0.1, qui sert le dossier de sortie
/// pour l'aperçu et l'audit Lighthouse. Lecture seule, sans sortie du
/// dossier.
class LocalPreviewServer {
  HttpServer? _server;
  String? _dir;

  Uri? get url =>
      _server == null ? null : Uri.parse('http://127.0.0.1:${_server!.port}/');

  String? get directory => _dir;

  static const _types = {
    '.html': 'text/html; charset=utf-8',
    '.htm': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.mjs': 'text/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json',
    '.webmanifest': 'application/manifest+json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.wasm': 'application/wasm',
    '.woff2': 'font/woff2',
    '.txt': 'text/plain; charset=utf-8',
    '.xml': 'application/xml',
  };

  Future<Uri> start(String directory, {bool spa = false}) async {
    await stop();
    final root = p.canonicalize(directory);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    _dir = root;
    server.listen((request) async {
      final res = request.response;
      try {
        if (request.method != 'GET' && request.method != 'HEAD') {
          res.statusCode = HttpStatus.methodNotAllowed;
          return;
        }
        final file = resolve(root, request.uri.path, spa: spa);
        if (file == null) {
          res.statusCode = HttpStatus.notFound;
          final notFound = File(p.join(root, '404.html'));
          if (notFound.existsSync()) {
            res.headers.contentType = ContentType.html;
            await res.addStream(notFound.openRead());
          }
          return;
        }
        res.headers.set(
          HttpHeaders.contentTypeHeader,
          _types[p.extension(file.path).toLowerCase()] ??
              'application/octet-stream',
        );
        if (request.method == 'GET') await res.addStream(file.openRead());
      } finally {
        await res.close();
      }
    });
    return url!;
  }

  /// Fichier servi pour [urlPath] ; null s'il n'existe pas ou sort du
  /// dossier (liens symboliques compris).
  static File? resolve(String root, String urlPath, {bool spa = false}) {
    final decoded = Uri.decodeComponent(urlPath);
    final candidate = p.normalize(
      p.join(root, '.${p.posix.normalize('/$decoded')}'),
    );
    if (candidate != root && !p.isWithin(root, candidate)) return null;
    File? found;
    if (FileSystemEntity.isDirectorySync(candidate)) {
      final index = File(p.join(candidate, 'index.html'));
      if (index.existsSync()) found = index;
    } else if (File(candidate).existsSync()) {
      found = File(candidate);
    } else if (File('$candidate.html').existsSync()) {
      found = File('$candidate.html');
    }
    if (found == null &&
        spa &&
        p.extension(candidate).isEmpty &&
        File(p.join(root, 'index.html')).existsSync()) {
      found = File(p.join(root, 'index.html'));
    }
    if (found == null) return null;
    final real = found.resolveSymbolicLinksSync();
    if (real != root && !p.isWithin(root, real)) return null;
    return found;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _dir = null;
  }
}

/// Vérification d'un site en ligne (HTTPS, redirection, HSTS).
class SiteCheck {
  const SiteCheck({
    this.httpsStatus,
    this.redirectsToHttps,
    this.hsts = false,
    this.error,
  });

  final int? httpsStatus;

  /// null : non vérifiable (HTTP inaccessible).
  final bool? redirectsToHttps;
  final bool hsts;
  final String? error;

  bool get httpsOk => httpsStatus != null && httpsStatus! < 400;
}

class SiteChecker {
  SiteChecker(this._client);

  final http.Client _client;

  Future<SiteCheck> check(String host) async {
    Future<http.StreamedResponse> get(Uri uri) {
      final req = http.Request('GET', uri)..followRedirects = false;
      return _client.send(req).timeout(const Duration(seconds: 15));
    }

    int? status;
    var hsts = false;
    String? error;
    try {
      final r = await get(Uri.https(host, '/'));
      status = r.statusCode;
      hsts = r.headers.containsKey('strict-transport-security');
      await r.stream.drain<void>();
    } on Object catch (e) {
      error = e is TimeoutException ? 'timeout' : e.runtimeType.toString();
    }
    bool? redirects;
    try {
      final r = await get(Uri.http(host, '/'));
      final location = r.headers['location'] ?? '';
      redirects =
          r.statusCode >= 300 &&
          r.statusCode < 400 &&
          location.startsWith('https://');
      await r.stream.drain<void>();
    } on Object {
      redirects = null;
    }
    return SiteCheck(
      httpsStatus: status,
      redirectsToHttps: redirects,
      hsts: hsts,
      error: error,
    );
  }
}

/// Résolution DNS en lecture seule (adresses IPv4/IPv6).
abstract interface class DnsResolver {
  Future<List<String>> lookup(String domain);
}

class SystemDnsResolver implements DnsResolver {
  const SystemDnsResolver();

  @override
  Future<List<String>> lookup(String domain) async {
    try {
      final r = await InternetAddress.lookup(domain)
          .timeout(const Duration(seconds: 10));
      return [for (final a in r) a.address];
    } on Object {
      return const [];
    }
  }
}

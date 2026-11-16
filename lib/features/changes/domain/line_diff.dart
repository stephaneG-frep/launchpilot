import 'dart:math';

import 'package:flutter/foundation.dart';

enum DiffOp { same, added, removed }

@immutable
class DiffLine {
  const DiffLine(this.op, this.text);
  final DiffOp op;
  final String text;
}

@immutable
class DiffHunk {
  const DiffHunk({
    required this.oldStart,
    required this.newStart,
    required this.lines,
  });

  /// Numéros de ligne (à partir de 1) au début du bloc.
  final int oldStart;
  final int newStart;
  final List<DiffLine> lines;

  int get oldCount => lines.where((l) => l.op != DiffOp.added).length;
  int get newCount => lines.where((l) => l.op != DiffOp.removed).length;

  String get header => '@@ -$oldStart,$oldCount +$newStart,$newCount @@';
}

/// Fichiers au-delà de cette taille : pas d'aperçu ligne à ligne.
const maxDiffLines = 4000;

List<String> _lines(String? text) {
  if (text == null || text.isEmpty) return const [];
  final l = text.split('\n');
  if (l.last.isEmpty) l.removeLast();
  return l;
}

/// Diff ligne à ligne (plus longue sous-séquence commune) regroupé en blocs
/// avec [context] lignes de contexte. Renvoie null si les fichiers sont trop
/// grands pour un aperçu.
List<DiffHunk>? lineDiff(String? before, String after, {int context = 3}) {
  final a = _lines(before);
  final b = _lines(after);
  if (a.length > maxDiffLines || b.length > maxDiffLines) return null;

  // Table LCS sur les suffixes.
  final n = a.length;
  final m = b.length;
  final lcs = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
  for (var i = n - 1; i >= 0; i--) {
    for (var j = m - 1; j >= 0; j--) {
      lcs[i][j] = a[i] == b[j]
          ? lcs[i + 1][j + 1] + 1
          : max(lcs[i + 1][j], lcs[i][j + 1]);
    }
  }
  final ops =
      <(DiffOp, String, int, int)>[]; // op, texte, n° ancien, n° nouveau
  var i = 0;
  var j = 0;
  while (i < n || j < m) {
    if (i < n && j < m && a[i] == b[j]) {
      ops.add((DiffOp.same, a[i], i + 1, j + 1));
      i++;
      j++;
    } else if (i < n && (j == m || lcs[i + 1][j] >= lcs[i][j + 1])) {
      // À égalité, la suppression passe avant l'ajout (comme git diff).
      ops.add((DiffOp.removed, a[i], i + 1, j + 1));
      i++;
    } else {
      ops.add((DiffOp.added, b[j], i + 1, j + 1));
      j++;
    }
  }

  // Regroupement des changements proches, avec leur contexte.
  final hunks = <DiffHunk>[];
  var k = 0;
  while (k < ops.length) {
    if (ops[k].$1 == DiffOp.same) {
      k++;
      continue;
    }
    final start = max(0, k - context);
    var end = k;
    var lastChange = k;
    while (end < ops.length && end - lastChange <= context * 2) {
      if (ops[end].$1 != DiffOp.same) lastChange = end;
      end++;
    }
    final stop = min(ops.length, lastChange + context + 1);
    final slice = ops.sublist(start, stop);
    hunks.add(
      DiffHunk(
        oldStart: slice.first.$3,
        newStart: slice.first.$4,
        lines: [for (final o in slice) DiffLine(o.$1, o.$2)],
      ),
    );
    k = stop;
  }
  return hunks;
}

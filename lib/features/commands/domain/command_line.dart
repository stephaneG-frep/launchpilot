/// Découpe une ligne saisie en exécutable et arguments, à la manière d'un
/// shell mais SANS aucune interprétation : ni variables, ni jokers, ni
/// redirections, ni enchaînements. Les guillemets servent seulement à
/// grouper.
List<String>? splitCommandLine(String input) {
  final out = <String>[];
  final current = StringBuffer();
  var inToken = false;
  String? quote;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (quote != null) {
      if (c == quote) {
        quote = null;
      } else if (c == r'\' && quote == '"' && i + 1 < input.length) {
        current.write(input[++i]);
      } else {
        current.write(c);
      }
      continue;
    }
    if (c == '"' || c == "'") {
      quote = c;
      inToken = true;
    } else if (c == ' ' || c == '\t') {
      if (inToken) {
        out.add(current.toString());
        current.clear();
        inToken = false;
      }
    } else if (c == r'\' && i + 1 < input.length) {
      current.write(input[++i]);
      inToken = true;
    } else {
      current.write(c);
      inToken = true;
    }
  }
  if (quote != null) return null;
  if (inToken) out.add(current.toString());
  return out;
}

/// Opérateurs de shell qui n'auront AUCUN effet (pas de shell) : on les
/// signale pour éviter un malentendu.
bool containsShellOperators(List<String> tokens) => tokens.any(
  (t) => const {
    '|',
    '||',
    '&&',
    ';',
    '>',
    '>>',
    '<',
    '&',
    '2>',
    '2>&1',
  }.contains(t),
);

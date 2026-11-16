import 'package:flutter/material.dart';

/// Affiche un message court en remplaçant le précédent : le dernier résultat
/// d'une action est toujours visible immédiatement, sans file d'attente.
void showInfo(ScaffoldMessengerState messenger, String text) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

// lib/providers/search_provider.dart
import 'package:flutter/foundation.dart';

import '../models/note_model.dart';

class SearchProvider extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────

  String _query = '';

  // ── Getters ────────────────────────────────────────────────

  String get query => _query;

  bool get isActive => _query.isNotEmpty;

  // ── Actions ────────────────────────────────────────────────

  void setQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void clear() {
    _query = '';
    notifyListeners();
  }

  // ── Filter ─────────────────────────────────────────────────

  /// Returns notes that match the current query.
  /// Matches against title, content, summary, and tags.
  List<NoteModel> filter(List<NoteModel> notes) {
    if (_query.isEmpty) return notes;

    final q = _query.toLowerCase();

    return notes.where((note) {
      if (note.title.toLowerCase().contains(q)) return true;
      if (note.content.toLowerCase().contains(q)) return true;
      if (note.summary?.toLowerCase().contains(q) ?? false) return true;
      if (note.tags.any((t) => t.toLowerCase().contains(q))) return true;
      return false;
    }).toList();
  }
}

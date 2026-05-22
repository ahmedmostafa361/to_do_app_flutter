import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/local_storage_service.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final LocalStorageService _storage;

  NotesProvider(this._storage);

  // ── State ──────────────────────────────────────────────────

  final List<NoteModel> _notes = [];
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────

  List<NoteModel> get notes => List.unmodifiable(_notes);

  bool get isLoading => _isLoading;

  int get totalNotes => _notes.length;

  // ✅ FIXED: was always returning 0
  int get completedNotes => _notes.where((n) => n.isCompleted).length;

  // ── Load ───────────────────────────────────────────────────

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    final saved = await _storage.getAllNotes();
    _notes
      ..clear()
      ..addAll(saved);

    _isLoading = false;
    notifyListeners();
  }

  // ── Add ────────────────────────────────────────────────────

  Future<void> addNote({
    required String title,
    required String content,
    required List<String> tags,
    String? summary,
    required String symbol,
    required int accentColorValue,
  }) async {
    final note = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
      summary: summary,
      symbol: symbol,
      accentColorValue: accentColorValue,
    );

    _notes.insert(0, note);
    notifyListeners();

    await _storage.saveNote(note);
  }

  // ── Toggle Complete ────────────────────────────────────────

  // ✅ NEW: flips isCompleted and persists
  Future<void> toggleComplete(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final updated = _notes[index].copyWith(
      isCompleted: !_notes[index].isCompleted,
    );

    _notes[index] = updated;
    notifyListeners();

    await _storage.updateNote(updated);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<void> updateNote(NoteModel updated) async {
    final index = _notes.indexWhere((n) => n.id == updated.id);
    if (index == -1) return;

    _notes[index] = updated;
    notifyListeners();

    await _storage.updateNote(updated);
  }

  // ── Delete ─────────────────────────────────────────────────

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();

    await _storage.deleteNote(id);
  }
}

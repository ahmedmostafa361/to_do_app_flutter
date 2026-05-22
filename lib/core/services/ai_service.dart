import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class AiService {
  Future<String> summarize(String text);

  Future<List<String>> generateTags(String text);

  Future<String> extractTitle(String spokenText);

  Future<String> extractContent(String spokenText);

  /// Splits one transcript into title + description + tags in a single API call.
  /// Use this instead of calling extractTitle / extractContent / generateTags
  /// separately — it's faster (1 call vs 3) and guarantees the title and
  /// description are always different from each other.
  Future<TaskData> extractTask(String spokenText);
}

// ─────────────────────────────────────────────────────────────────────────────
// Value object returned by extractTask
// ─────────────────────────────────────────────────────────────────────────────

class TaskData {
  final String title;
  final String description;
  final List<String> tags;

  const TaskData({
    required this.title,
    required this.description,
    required this.tags,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class GroqAiService implements AiService {
  final String apiKey;

  GroqAiService({required String apiKey}) : apiKey = apiKey.trim();

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  // ── Core JSON call ─────────────────────────────────────────

  Future<Map<String, dynamic>> _callJson(String system, String user) async {
    if (apiKey.isEmpty) throw Exception('Groq API key is empty.');

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.0,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>;
    final content = choices.first['message']['content'] as String;
    return jsonDecode(content) as Map<String, dynamic>;
  }

  // ── extractTask — ONE call, THREE results ──────────────────
  //
  // This is the main method used by the voice modal.
  //
  // The key rule enforced by the prompt:
  //   title       = 3–5 word LABEL for the task (what it IS)
  //   description = the FULL sentence the user spoke (what to DO)
  //
  // Example:
  //   User says  → "buy groceries from the supermarket tomorrow morning"
  //   title      → "Buy Groceries Tomorrow"
  //   description→ "Buy groceries from the supermarket tomorrow morning."
  //   tags       → ["Shopping", "Errands"]

  @override
  Future<TaskData> extractTask(String spokenText) async {
    const system = '''
You are a task creation assistant. The user spoke one sentence to create a task.
Your job is to split it into three parts.

STRICT RULES:
1. "title" = a SHORT label, 3 to 5 words maximum, capitalised like a title.
   - It must name WHAT the task is (e.g. "Buy Groceries Tomorrow").
   - It must NOT be the same as the description.
   - Use the same language as the input.

2. "description" = the FULL detail of what the user said, written as one clean sentence.
   - It must contain MORE information than the title.
   - Do not cut or shorten it — keep everything the user said.
   - Use the same language as the input.

3. "tags" = 2 to 3 short category words separated by commas (e.g. "Shopping, Errands").
   - Use the same language as the input.

OUTPUT FORMAT (JSON only, nothing else):
{
  "title": "short task label here",
  "description": "full sentence with all details here",
  "tags": "Tag1, Tag2"
}
''';

    final data = await _callJson(system, 'User said: $spokenText');

    final title = (data['title'] as String? ?? '').trim();
    final description = (data['description'] as String? ?? '').trim();
    final tagsRaw = (data['tags'] as String? ?? '').trim();

    final tags = tagsRaw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(3)
        .toList();

    // Safety fallback: if AI returns identical title and description,
    // shorten the title to the first 4 words of the description.
    final safeTitle = (title.isEmpty || title == description)
        ? description.split(' ').take(4).join(' ')
        : title;

    return TaskData(
      title: safeTitle,
      description: description.isNotEmpty ? description : spokenText,
      tags: tags,
    );
  }

  // ── Individual methods (used by CreateTaskScreen) ──────────

  @override
  Future<String> extractTitle(String spokenText) async {
    final data = await _callJson(
      'Extract a short task title (3–5 words, same language as input). '
          'Return JSON: {"title": "..."}',
      'Input: $spokenText',
    );
    return (data['title'] as String? ?? '').trim();
  }

  @override
  Future<String> extractContent(String spokenText) async {
    final data = await _callJson(
      'Write a clean full task description from the input (1–2 sentences, '
          'same language, keep all details). Return JSON: {"description": "..."}',
      'Input: $spokenText',
    );
    return (data['description'] as String? ?? '').trim();
  }

  @override
  Future<String> summarize(String text) async {
    final data = await _callJson(
      'Summarize in under 12 words, same language. '
          'Return JSON: {"summary": "..."}',
      'Text: $text',
    );
    return (data['summary'] as String? ?? '').trim();
  }

  @override
  Future<List<String>> generateTags(String text) async {
    final data = await _callJson(
      'Generate 2–3 tags separated by commas, same language. '
          'Return JSON: {"tags": "Tag1, Tag2"}',
      'Task: $text',
    );
    final raw = (data['tags'] as String? ?? '').trim();
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(3)
        .toList();
  }
}

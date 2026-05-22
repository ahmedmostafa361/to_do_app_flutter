# ✅ Flutter AI To-Do App

A smart task manager built with Flutter that combines voice input, AI-powered summaries & tag generation, and a clean minimal UI — all powered by the free Groq API (LLaMA 3.3 70B).

---

## 📺 Demo

[![Watch the demo]([https://img.shields.io/badge/YouTube-Watch%20Demo-red?style=for-the-badge&logo=youtube)](https://youtu.be/rS6KpSlP69E](https://youtu.be/rS6KpSlP69E))

---

## ✨ Features

- **Voice-to-Task** — Speak a task aloud; AI extracts the title, description, and tags in a single API call
- **AI Summarize** — Instantly condense long task descriptions into a short label
- **AI Tag Generation** — Auto-generate 2–3 smart category tags from your task content
- **Search** — Filter tasks by title, content, summary, or tags in real time
- **Complete / Uncomplete** — Tap the checkbox to toggle a task's status with a live progress bar
- **Swipe to Delete** — Swipe left on any task to remove it
- **Symbol & Accent Color Picker** — Personalize each task with an icon and a color
- **In-Memory Storage** — All data lives in memory (easy to swap for a persistent backend)

---

## 🏗️ Architecture

```
lib/
├── core/
│   └── services/
│       ├── ai_service.dart             # Groq (LLaMA 3.3 70B) — summarize, tags, voice extraction
│       ├── speech_service.dart         # Microphone → real-time transcription stream
│       └── local_storage_service.dart  # In-memory storage (swap for Hive/SQLite)
├── models/
│   └── note_model.dart                 # NoteModel with copyWith, toJson, fromJson
├── providers/
│   ├── notes_provider.dart             # CRUD + toggleComplete + loading state
│   └── search_provider.dart            # Live search filter across all note fields
└── ui/
    ├── home/
    │   └── home_screen.dart            # Dashboard, progress bar, task list, FABs
    └── note/
        └── create_note_screen.dart     # Manual + voice task creation with AI actions
```

**State management:** Provider  
**AI backend:** [Groq API](https://console.groq.com) (free tier, `llama-3.3-70b-versatile`)  
**Speech:** `speech_to_text` package — dictation mode, 10-second silence timeout

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.9.2`
- A free [Groq API key](https://console.groq.com)

### Installation

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
flutter pub get
```

### Add your Groq API key

Open `lib/main.dart` and paste your key:

```dart
const _groqApiKey = 'gsk_YOUR_KEY_HERE';
```

### Run

```bash
flutter run
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `speech_to_text` | Microphone & transcription |
| `http` | Groq API calls |
| `uuid` | Unique task IDs |
| `google_fonts` | Typography |

Full list in [`pubspec.yaml`](pubspec.yaml).

---

## 🤖 How the AI Works

All AI features call the Groq API with `response_format: json_object` and `temperature: 0.0` for deterministic output.

| Feature | API calls | Model output |
|---|---|---|
| Voice task creation | 1 | `{ title, description, tags }` |
| Summarize | 1 | `{ summary }` |
| Generate tags | 1 | `{ tags }` |

The `extractTask` method deliberately uses **one combined call** instead of three separate ones, so the title and description are always meaningfully different from each other.

---

## 📝 License

MIT — feel free to use, modify, and distribute.

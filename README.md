# Nexa Personal AI

Nexa is a single personal assistant workspace. It has no accounts, plans, upgrades, subscriptions, payments, or feature locks.

## Requirements

- Node.js 18 or newer
- A modern Chromium, Firefox, or Safari browser
- Secure context for browser camera access: `localhost` works during development; deployed builds should use HTTPS

## Start Nexa

```bash
npm install
copy .env.example .env
# Add keys to .env when you want cloud AI or live web search.
npm run backend
```

In a second terminal run `npm run dev`, then open `http://localhost:3000/`.

Run checks with `npm run lint` and `npm run build`.

## What Works

- Provider based chat, saved conversation history, contextual follow-ups, writing, translation, summaries, and coding help. The actual provider and model are shown in the interface.
- Live web search when a backend search provider is configured; returned result links are shown as sources. Search is reported unavailable when no provider is connected.
- DuckDuckGo Instant Answer is available as a free, keyless provider for summaries and related topics.
- A separate `SEARCH` module using Google Programmable Search Engine `f6f3634866dca43af` for direct browser searches.
- Browser push-to-talk speech input and speech-synthesis read aloud. Browser permissions, installed voices, recognition support and audio handling determine availability.
- Optional continuous wake listening from the Voice module. It keeps the microphone active and matches speech recognition transcripts; it is not an offline acoustic wake model, and the browser may send audio to its own service.
- Text, Markdown, JSON, CSV, PDF, and DOCX uploads. Documents are extracted in the browser and included as question-answering context.
- Image uploads. With `GEMINI_API_KEY` configured, images are sent to Gemini as vision input; without it, Nexa reports that the AI service is unavailable.
- Emotion-aware response guidance and safety filtering for grief, distress, frustration, and emergencies.
- Personal settings for voice behavior, animation, appearance, memory, providers, vision, and automation.
- A Tools capability matrix and read-only diagnostics page that shows live backend/browser checks and marks missing, disconnected, hardware dependent, and fictional capabilities.
- A privacy-preserving execution trace for real chat requests. It records operational stages and outcome only; prompts, responses, files, images, and credentials are excluded. The Tools module also has an emergency stop that cancels registered in-app work, browser speech, and wake listening until explicitly released.

Desktop control is available only through the optional, paired localhost Windows bridge. It opens a fixed allowlist of applications after a session pairing token and explicit confirmation; it does not provide arbitrary commands, file operations, mouse/keyboard, browser-tab control, or remote access. Arbitrary local file operations, terminal execution, calendar/email, smart-home devices, robotics, background automation and full-duplex voice are not connected. The capability matrix is the current implementation status; a visible module or setting does not imply an integration exists.

## Conversation Memory

Nexa keeps follow-up context per conversation. Earlier user/assistant turns from the **active conversation only** are sent to the AI backend as role-tagged history (`system` prompt first, history in original order, the current message last and never duplicated), so questions like "What is my name?" after "My name is Suraj." answer correctly. History is bounded to the most recent 12 turns per request, so long chats stay fast and prompts stay small.

- **Scope:** each conversation (session) is isolated. Starting a new chat begins with a clean context; switching chats restores only that conversation's history.
- **Persistence:** conversations are stored **on this device only**, in browser `localStorage` under `nexus_chat_sessions_v2` (plus `nexus_active_session_id_v2` for the last active chat). There is no server-side memory and nothing is stored outside your browser.
- **Privacy:** before conversation history is written to browser storage, credential-shaped values are replaced with `[REDACTED]`; stored history is capped (50 conversations, 200 messages each). Chat prompts, recent turns and attached images are sent to the configured backend provider. Provider-side handling depends on that provider and its configuration.
- **Clearing:** use **"Clear all conversation memory"** at the bottom of the chat sidebar to erase every stored conversation, or the trash icon in the chat toolbar / sidebar to clear or delete a single conversation.

## Configuration

Copy `.env.example` to `.env` for the backend:

| Variable | Purpose |
| --- | --- |
| `GEMINI_API_KEY` | Enables backend Gemini chat and image understanding. |
| `GEMINI_MODEL` | Optional Gemini model name. |
| `AI_PROVIDER=lmstudio` | Uses LM Studio's local OpenAI-compatible server. `ollama` and `gemini` remain optional. |
| `OLLAMA_BASE_URL` | Ollama HTTP API base URL, normally `http://127.0.0.1:11434`. |
| `OLLAMA_MODEL` | Local model name, default `llama3.2:3b`. |
| `LMSTUDIO_BASE_URL` | LM Studio OpenAI-compatible API, normally `http://127.0.0.1:1234/v1`. |
| `LMSTUDIO_MODEL` | Optional model-name match. Nexa also discovers the first loaded model from LM Studio. |
| `WEB_SEARCH_PROVIDER=google` | Uses Google Custom Search JSON API for AI web search. `duckduckgo` and `brave` are also supported. |
| `GOOGLE_CSE_API_KEY` | Server-side Google Custom Search JSON API key. |
| `GOOGLE_CSE_ID` | Programmable Search Engine ID, currently `f6f3634866dca43af`. |
| `WEB_SEARCH_API_KEY` | Server-side Brave key when `WEB_SEARCH_PROVIDER=brave`. |
| `API_PORT` | Backend port, default `4000`. |

Keys remain in the backend environment and are never placed in frontend JavaScript. Live search and cloud AI are unavailable until their keys are configured; Nexa does not claim otherwise.

### Optional local desktop bridge

To enable a personal, Windows-only launch bridge, set `NEXA_DESKTOP_BRIDGE_ENABLED="true"` and a unique `NEXA_DESKTOP_BRIDGE_TOKEN` of at least 24 characters in `.env`, then restart the backend. Enter the same token manually in **Tools → Local Desktop Bridge** for each browser session. Every launch needs a confirmation. The backend only accepts loopback requests and only opens VS Code, Chrome, Windows Terminal, Explorer, or Notepad from its fixed allowlist.

Set `NEXA_DESKTOP_WORKSPACE_ROOT` to an absolute project directory to additionally enable workspace-scoped file search/read, confirmed text-file saving, and confirmed `npm run lint`, `npm test`, and `npm run build`. The bridge rejects traversal outside that root, skips dependency/build directories during search, limits text reads/writes to 512 KB, bounds command output, and does not expose arbitrary commands, deletion, or broad filesystem access.

The Google Programmable Search module remains a visible embedded search box. Separately, when `WEB_SEARCH_PROVIDER=google`, Nexa&apos;s backend uses Google Custom Search JSON API with the server-side `GOOGLE_CSE_API_KEY` and `GOOGLE_CSE_ID`; returned titles, snippets, and URLs are passed to Gemini as context and displayed as chat sources. The browser embed itself is never read by the AI backend.

Firebase settings are optional for anonymous auth and capability event storage. Google OAuth, Drive, Calendar, Gmail, Contacts, Docs, Sheets, and YouTube service adapters are not connected in this build; adding client IDs or API keys does not enable them. Supabase settings are only needed for the existing workspace integrations. Browser speech, local document extraction, local memory, and camera-based vision do not require API keys.

DuckDuckGo Instant Answer uses `https://api.duckduckgo.com/` with no API key. It is not a complete ranked search engine: many queries return no Instant Answer or only related topics. Nexa passes only returned real sources to the model and reports no results honestly. Use Google Custom Search JSON API or Brave when ranked, broad web results are required.

## Local Ollama AI

The current machine has about 15.7 GB RAM, so `llama3.2:3b` is a conservative starting point. Expect roughly a 2 GB model download and several GB of working memory; actual speed depends on CPU/GPU. Nexa does not download models automatically.

Install Ollama from https://ollama.com/download/windows, then in PowerShell:

```powershell
ollama --version
ollama pull llama3.2:3b
ollama serve
```

In another terminal, start Nexa with `npm run backend`. If Ollama or the model is unavailable, Nexa returns an actionable error instead of pretending to generate an answer. Use `AI_PROVIDER=gemini` only when a valid server-side `GEMINI_API_KEY` is configured.

## Local LM Studio AI

The attached GGUF models can be loaded in LM Studio without copying them into Nexa. Load `Qwen2.5-Coder-0.5B-Instruct-Q8_0.gguf` or `SmolLM2-360M-Instruct-Q8_0.gguf` in LM Studio, start the local server on port `1234`, and keep `AI_PROVIDER=lmstudio`. Nexa checks `/v1/models` and uses the configured model match or the first loaded model. No cloud key is required.

## Capabilities and Firebase

The **Capabilities** tab includes Firebase Auth and Firestore, image input, and browser speech transcription. To enable Firebase anonymous authentication and capability event storage, create `.env.local` with the values from your Firebase web app:

```bash
VITE_FIREBASE_API_KEY=...
VITE_FIREBASE_AUTH_DOMAIN=...
VITE_FIREBASE_PROJECT_ID=...
VITE_FIREBASE_STORAGE_BUCKET=...
VITE_FIREBASE_MESSAGING_SENDER_ID=...
VITE_FIREBASE_APP_ID=...
```

Enable **Anonymous** sign-in in Firebase Authentication and create the `capabilityEvents` Firestore collection/rules. Gemini Live, Nano Banana 2, Veo, Search Grounding, and Maps Grounding require provider credentials and server-side endpoints before their actions can be enabled.

## Voice and Vision

Use the microphone button for push-to-talk input and the response speaker action for text-to-speech. Wake listening is opt-in in the Voice module and can be stopped there; while enabled, the microphone stays active. Wake detection uses transcripts from the browser speech recognition service, not a local acoustic model. Audio handling is controlled by the browser and may use a network service.

Image understanding is available through the chat attachment button when the backend is running with Gemini configured. Camera analysis requires browser permission and compatible model assets. Image generation is not simulated and requires a supported image-generation endpoint.

Uploaded documents are extracted locally before being added to the chat request. Images are sent to the configured Gemini backend only when attached to a backend chat request. External provider availability, browser permissions, and API quotas can affect these features.

## Troubleshooting

- **CAMERA: DENIED**: Allow camera access for the site in browser permissions, then retry from the Vision module.
- **CAMERA: NOT FOUND**: Connect a webcam and reload the page.
- **CAMERA: ERROR**: Check whether another application is using the webcam and confirm the page is served from `localhost` or HTTPS.

## Performance and Extension

The local vision pipeline uses bounded frame processing, cleanup of camera resources, and local-only defaults. Vision remains independent from chat, voice, and document processing.

# ArkChatBot

ArkChatBot is a HarmonyOS chatbot app built with ArkUI, ArkTS, and DevEco Studio 5.0.5. It provides a simple chat interface and connects to a Node.js backend that calls the Qwen model.

## Features

- ArkUI chat interface
- User and assistant message bubbles
- Scrollable conversation view
- Loading state while waiting for response
- Node.js backend integration

## Architecture

```text
ArkUI App
   ↓ HTTP request
Node.js Backend
   ↓ DashScope API
Qwen-Max LLM
   ↓
Node.js Backend
   ↓
ArkUI App
```

## Project Structure

```text
ArkChatBot/
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── api/
│       │   │   └── ChatApi.ets
│       │   ├── entryability/
│       │   └── pages/
│       │       └── Index.ets
│       ├── resources/
│       └── module.json5
├── server/
│   ├── package.json
│   ├── server.js
│   └── .env
├── AppScope/
├── build-profile.json5
├── hvigorfile.ts
├── oh-package.json5
└── README.md
```

## Future Work

- Streaming responses
- Document upload
- PDF summarization
- RAG-based question answering
- Chat history storage
- Markdown rendering
- Dark mode

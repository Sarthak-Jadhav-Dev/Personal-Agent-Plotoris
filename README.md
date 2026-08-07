# Schedular (Plotoris)

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Node.js-18%2B-339933?logo=node.js&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/Express-5.x-000000?logo=express&logoColor=white" alt="Express" />
  <img src="https://img.shields.io/badge/MongoDB-Mongoose-47A248?logo=mongodb&logoColor=white" alt="MongoDB" />
  <img src="https://img.shields.io/badge/AI-OpenRouter-8A2BE2" alt="OpenRouter" />
</div>

A comprehensive platform comprising a **Flutter Mobile Application** (`Plotoris-App`) and a **Smart Node.js Backend** (`Backend`). The system is designed for scheduling, inbox automation, and AI-powered email analysis. It authenticates users with Google OAuth, stores hook-based rules, analyzes Gmail content safely, and prepares structured summaries for downstream AI processing.

---

## 🧭 Architecture Overview

```mermaid
flowchart LR
    A[Plotoris Flutter App] --> B[Express API (Backend)]
    B --> C[Auth Routes]
    B --> D[Hooks Routes]
    B --> E[Email Analysis Controller]
    C --> F[Google OAuth]
    D --> G[MongoDB Models]
    E --> H[Privacy Filter]
    E --> I[OpenRouter AI]
    G --> J[User + Features + Hooks Data]
```

---

## ✨ Features

### Mobile App (Plotoris-App)
- Cross-platform Flutter application
- Google Authentication / Login & Sign-in flows
- Hook management UI for user-defined automation rules

### Backend Service (Backend)
- Google authentication flow for Gmail access
- JWT-based protected routes
- Safe email filtering before sending content to AI
- AI-powered email analysis via OpenRouter
- MongoDB persistence through Mongoose

---

## 🧱 Repository Structure

This repository is structured as a monorepo containing both the frontend application and the backend service:

```text
.
├── Backend/                 # Node.js + Express Backend Service
│   ├── Controller/          # Route handlers and business logic
│   ├── DB/                  # Database connection setup
│   ├── Helpers/             # Utility helpers for auth, Gmail, and privacy filtering
│   ├── Middlewares/         # JWT authentication middleware
│   ├── Models/              # Mongoose schemas
│   ├── Routes/              # Express route definitions
│   ├── app.js               # Express app setup
│   ├── index.js             # Server entry point
│   └── package.json         # Dependencies and scripts
│
└── Plotoris-App/            # Flutter Mobile Application
    ├── lib/                 # Dart source code (screens, services, models)
    ├── android/             # Android native code
    ├── ios/                 # iOS native code
    ├── pubspec.yaml         # Flutter dependencies
    └── README.md            # App-specific documentation
```

---

## 🚀 Getting Started

### 1. Backend Setup

Navigate to the `Backend` directory:
```bash
cd Backend
npm install
```

Create an `.env` file in the `Backend` directory (an example might be provided as `.env.example`):
```env
PORT=8000

CLIENT_ID=your_google_client_id
CLIENT_SECRET=your_google_client_secret
REDIRECT_URL=http://localhost:8000/api/auth/google/callback

JWT_ACCESS_SECRET=your_access_secret
JWT_REFRESH_SECRET=your_refresh_secret
JWT_ACCESS_EXPIRY=1d
JWT_REFRESH_EXPIRY=7d

MONGODB_URI=mongodb://127.0.0.1:27017/schedular

OPENROUTER_API_KEY=your_openrouter_api_key
OPENROUTER_MODEL=openai/gpt-4o-mini
OPENROUTER_REFERER=http://localhost:8000
OPENROUTER_TITLE=Scheduler Backend
```

Run the backend server:
```bash
node index.js
# Or with nodemon: npx nodemon index.js
```

### 2. Mobile App Setup

Navigate to the `Plotoris-App` directory:
```bash
cd Plotoris-App
flutter pub get
```

Run the application on an emulator or physical device:
```bash
flutter run
```

*(Note: You may need to configure Firebase/Google Sign-In natively in Android/iOS folders depending on the authentication setup)*

---

## 🔐 Authentication Flow

1. The **Plotoris-App** directs the user to the Google OAuth URL (`GET /api/auth/google/url`).
2. After the user logs in, the backend's callback (`GET /api/auth/google/callback`) is triggered.
3. The backend issues JWT Access and Refresh tokens to the app, establishing a secure session.

---

## 🪝 Hooks Integration

Hooks allow users to define automation rules (e.g., "Notify me about invoices").
- **Frontend**: Users manage hooks via the Flutter app interface.
- **Backend API**: The app communicates with the backend via protected routes:
  - `PUT /api/hooks/setHook`
  - `GET /api/hooks/getHooks`
  - `DELETE /api/hooks/deleteHook`

---

## 📧 AI Email Analysis Flow

The system fetches Gmail messages, filters sensitive content, and sends only safe email previews to the AI for analysis.

1. Gmail messages are fetched using the user’s Google access token.
2. Email content is scanned for sensitive/private information via a **Privacy Filter Helper**.
3. Safe emails are sent to OpenRouter (AI layer) with a prompt including user information, configured hooks, and safe previews.
4. The AI returns a structured response containing:
   - Matched hooks
   - Summary of email events
   - Suggested actions
   - Manual review items

---

## 🛠️ Tech Stack

- **Mobile**: Flutter, Dart
- **Backend**: Node.js, Express.js
- **Database**: MongoDB + Mongoose
- **Auth**: Google OAuth, JWT
- **AI**: OpenRouter API

---

## 🤝 Contributing

Feel free to fork the repository and submit pull requests with improvements, fixes, or new features.

---

## 📄 License

This project is currently unlicensed. Add a license if you want to publish it publicly.

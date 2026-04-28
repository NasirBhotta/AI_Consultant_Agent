# agent_app

Scalable Flutter starter structure prepared for Firebase integration.

## Folder structure

```text
lib/
  main.dart
  src/
    app/
      app.dart
      router/
      theme/
    core/
      constants/
      utils/
    features/
      README.md
    services/
      firebase/
    shared/
      widgets/
```

## What goes where

- `app/`: app shell, navigation, themes, app-level configuration.
- `core/`: constants, helpers, validators, extensions, and utilities used across the project.
- `features/`: business modules like `auth`, `profile`, `chat`, `orders`.
- `services/`: Firebase and third-party integrations.
- `shared/`: reusable widgets, shared models, and common UI building blocks.

## Firebase plan

1. Add `firebase_core` and the Firebase packages you need.
2. Run `flutterfire configure`.
3. Put generated `firebase_options.dart` in `lib/src/services/firebase/`.
4. Replace the placeholder bootstrap with `Firebase.initializeApp(...)`.

## Suggested feature layout

```text
lib/src/features/auth/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    controllers/
    pages/
    widgets/
```

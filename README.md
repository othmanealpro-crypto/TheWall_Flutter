# TheWall_Flutter

TheWall est une application sociale mobile developpee avec Flutter et Supabase. Elle permet aux utilisateurs de creer un compte, gerer leur profil, publier des messages et consulter un fil d'actualite en temps reel.

Cette version correspond a la branche `Othmane`.

## Fonctionnalites

- Inscription et connexion utilisateur
- Persistance de session
- Profils utilisateurs
- Publication et consultation de messages publics
- Fil d'actualite en temps reel
- Ajout d'amis et gestion des demandes
- Messagerie entre utilisateurs
- Modification de la photo de profil
- Stockage des images avec Supabase Storage

## Technologies

- Flutter et Dart
- Supabase Auth
- Supabase Database / PostgreSQL
- Supabase Realtime
- Supabase Storage
- Firebase Core, Firebase Auth et Cloud Firestore
- `image_picker` pour la selection d'images

## Prerequis

- Flutter SDK compatible avec Dart 3.9+
- Android Studio ou Xcode selon la plateforme cible
- Un projet Supabase configure
- Les variables et identifiants necessaires dans la configuration de l'application

## Installation

```bash
git clone --branch Othmane https://github.com/othmanealpro-crypto/TheWall_Flutter.git
cd TheWall_Flutter
flutter pub get
```

Configurer ensuite les acces Supabase dans le projet avant de lancer l'application.

## Lancement

```bash
flutter run
```

Pour verifier le code et les tests :

```bash
flutter analyze
flutter test
```

## Structure

```text
lib/
├── auth/
├── components/
├── pages/
├── assets/
├── main.dart
└── session_manager.dart
```

## Branche

Le travail publie ici est disponible sur la branche `Othmane` :

```bash
git checkout Othmane
```

## Auteur

Othmane Al Amrani - [GitHub](https://github.com/othmanealpro-crypto)

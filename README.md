# The Wall (Supabase Version)

TheWall is a Flutter mobile social application built with Supabase. Users can create an account, manage their profile, publish public messages, interact with other users and follow a real-time news feed.

This version contains the work published on the `Othmane` branch.

## Features

- User registration and login with Supabase Auth
- Persistent sessions and logout
- Public wall with real-time posts
- User profiles and profile picture upload
- Image storage with Supabase Storage
- Friend requests and user interactions
- Messaging between users
- Realtime updates through Supabase streams
- Modern Flutter interface

## Tech Stack

- Flutter and Dart
- Supabase Auth
- Supabase PostgreSQL Database
- Supabase Realtime
- Supabase Storage
- Firebase Core, Firebase Auth and Cloud Firestore
- `image_picker` for image selection

## Architecture and Folder Structure

```text
lib/
├── auth/
│   ├── auth.dart
│   ├── login_or_register.dart
│   ├── login_page.dart
│   └── register_page.dart
├── components/
│   ├── button.dart
│   ├── text_field.dart
│   └── wall_post.dart
├── pages/
│   ├── home_page.dart
│   └── profile_page.dart
├── assets/
├── main.dart
└── session_manager.dart
```

## Prerequisites

- Flutter SDK with Dart 3.9 or later
- Android Studio or Xcode, depending on the target platform
- A configured Supabase project
- The required Supabase and Firebase credentials

## Installation

```bash
git clone --branch Othmane https://github.com/othmanealpro-crypto/TheWall_Flutter.git
cd TheWall_Flutter
flutter pub get
```

Configure the Supabase URL and anonymous key in `main.dart` or in the configuration used by the project:

```dart
await Supabase.initialize(
  url: 'https://YOUR-PROJECT.supabase.co',
  anonKey: 'YOUR-ANON-KEY',
);
```

Then start the application:

```bash
flutter run
```

## Supabase Database Setup

Create the main tables in the Supabase SQL editor. Adapt the columns and policies to the current application model if needed.

```sql
create table profiles (
  id uuid primary key,
  email text not null,
  nom text,
  prenom text,
  username text unique,
  created timestamp default now()
);

create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  content text not null,
  created_at timestamp default now()
);
```

Enable Row Level Security and define policies for authenticated users before using the application in production.

## Authentication Flow

- `auth.dart` listens to `Supabase.instance.client.auth.onAuthStateChange`.
- Authenticated users are redirected to `HomePage`.
- Unauthenticated users see `LoginOrRegister`.
- `login_page.dart` uses `signInWithPassword`.
- `register_page.dart` creates the Supabase user and its profile.

## Screens

| Screen | Description |
| --- | --- |
| Login / Register | Supabase authentication |
| HomePage | Public wall and posts |
| Profile | User information and profile picture |
| Messaging | Communication between users |
| Logout | Ends the current session |

## Quality Checks

```bash
flutter analyze
flutter test
```

## Branch

The published version is available on the `Othmane` branch:

```bash
git checkout Othmane
```

## Future Improvements

- Likes and comments
- Realtime notifications
- Dark mode
- Improved timestamp formatting
- More granular Supabase security policies

## Author

Othmane Al Amrani - [GitHub](https://github.com/othmanealpro-crypto)

## License

This project is licensed under the MIT License.

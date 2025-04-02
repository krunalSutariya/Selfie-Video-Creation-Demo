# Selfie Video App

This Flutter application allows authenticated users to record short selfie videos using a teleprompter, perform basic video edits (trim, cover), and share.  

## Features

- **User Registration & Authentication** (Mock API with async handlers)  
- **Dashboard** to manage recorded videos (view, delete)  
- **Video Recording with Teleprompter**  
- **Basic Video Editing** (Trim, Cover)  
- **Social Media Sharing** (Sharing intent)  
- **Error Handling** (Random server errors in login or register for now, like 503, 500, missing fields)  
- **State Management** using BLoC  
- **Local Storage** for video clips 

## Project Structure

The application follows clean architecture principles with a feature-based folder structure:

## Getting Started

### Prerequisites
- Flutter SDK ">=3.29.2"
- Dart SDK ">=3.7.0 <4.0.0"


### Installation
1. Clone the repository
```bash
git clone https://github.com/krunalSutariya/Selfie-Video-Creation-Demo.git
```

2. Navigate to the project directory
```bash
cd selfie-video-creation-demo
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Project Structure
```
lib/
├── app.dart
├── main.dart
├── config/
│   └── app_routes.dart
├── core/
│   ├── constants/
│   │   └── api_endpoints.dart
│   ├── di/
│   │   └── injection_container.dart
│   └── errors/
│       └── app_exceptions.dart
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── auth_local_datasource.dart
│   │   │   └── video_local_datasource.dart
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart
│   │       └── video_remote_datasource.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── video_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── video.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── video_repository.dart
│   └── usecases/
│       ├── auth/
│       │   ├── check_auth_status.dart
│       │   ├── login_user.dart
│       │   ├── logout_user.dart
│       │   └── register_user.dart
│       └── video/
│           ├── create_video.dart
│           ├── delete_video.dart
│           └── get_videos.dart
├── presentation/
│   ├── bloc/
|   |   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   └── auth_event.dart
|   |   |   └── auth_state.dart
│   │   ├── video/
│   │   │   ├── video_bloc.dart
│   │   │   └── video_event.dart
|   |   |   └── video_state.dart
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_page.dart
│   │   └── video/
│   │       ├── splash_page.dart
│   │       ├── video_capture_page.dart
│   │       ├── video_detail_page.dart
│   │       ├── video_edit_page.dart
│   │       └── video_share_page.dart
│   └── widgets/
│       ├── common/
│       │   ├── app_button.dart
│       │   ├── app_text_field.dart
│       │   ├── confirmation_dialog.dart
│       │   └── error_dialog.dart
│       ├── teleprompter/
│       │   └── teleprompter_widget.dart
│       └── video/
│           ├── video_item.dart
│           └── video_player_widget.dart
└── utils/
    ├── validators.dart
    └── video_utils.dart
```

## State Management

This project uses Bloc for state management.

## Auth Mock Data

lib/
├── data/
│   ├── datasources/
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart

## Platform Configuration

### Android

- Minimum SDK version: 21 (Android 5.0)
- Target SDK version: 33 (Android 13)
- Required permissions:
  - Camera
  - Microphone
  - Storage

### iOS

- Minimum deployment target: iOS 12.0
- Required permissions:
  - Camera
  - Microphone
  - Photo Library

## Development

The application uses Provider for state management and follows SOLID principles with a clean architecture approach. Each feature is isolated in its own directory with its respective screens, widgets, and providers.
# 📚 DigiBuks Mobile App

Mizoram's Digital eBook Ecosystem - Flutter Mobile Application

## Project Structure

```
digibuks/
├── lib/
│   ├── core/                    # Core functionality & configurations
│   │   ├── config/             # App configuration
│   │   │   └── app_config.dart
│   │   ├── constants/          # App constants
│   │   │   └── app_constants.dart
│   │   ├── theme/              # App themes
│   │   │   └── app_theme.dart
│   │   ├── network/            # Network layer
│   │   │   └── api_client.dart
│   │   ├── exceptions/         # Custom exceptions
│   │   │   └── api_exception.dart
│   │   └── utils/              # Utility functions
│   │       ├── logger.dart
│   │       ├── validators.dart
│   │       └── storage_helper.dart
│   │
│   ├── data/                    # Data layer (Repository Pattern)
│   │   ├── models/             # Data models
│   │   │   ├── user_model.dart
│   │   │   └── book_model.dart
│   │   ├── repositories/       # Repository implementations
│   │   └── datasources/        # Data sources
│   │       ├── remote/         # Remote API data sources
│   │       └── local/          # Local storage data sources
│   │
│   ├── domain/                  # Domain layer (Clean Architecture)
│   │   ├── entities/           # Business entities
│   │   ├── repositories/        # Repository interfaces
│   │   └── usecases/           # Business logic use cases
│   │
│   ├── presentation/            # Presentation layer (GetX)
│   │   ├── controllers/        # GetX controllers
│   │   ├── bindings/           # Dependency bindings
│   │   ├── views/              # UI screens
│   │   │   ├── auth/           # Authentication screens
│   │   │   ├── home/           # Home screens
│   │   │   ├── books/          # Book-related screens
│   │   │   ├── reader/         # eBook reader screens
│   │   │   ├── profile/        # Profile screens
│   │   │   ├── author/         # Author dashboard screens
│   │   │   └── admin/          # Admin dashboard screens
│   │   ├── widgets/            # Reusable widgets
│   │   └── routes/             # App routing
│   │       └── app_routes.dart
│   │
│   └── main.dart               # App entry point
│
├── assets/                      # App assets
│   ├── images/                 # Images
│   ├── icons/                  # Icons
│   └── fonts/                  # Custom fonts (Mizo language support)
│
├── test/                        # Unit & widget tests
├── pubspec.yaml                 # Dependencies
└── README.md                    # This file
```

## Architecture

This project follows **Clean Architecture** principles with **GetX** for state management:

- **Presentation Layer**: GetX controllers, views, and widgets
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Models, repositories, and data sources

## Key Features

- ✅ GetX state management
- ✅ Dio for API communication
- ✅ Flutter Secure Storage for sensitive data
- ✅ Clean Architecture pattern
- ✅ Theme support (Light/Dark mode)
- ✅ Mizo language support ready
- ✅ PDF & EPUB reader integration
- ✅ Payment integration (Razorpay)

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Dependencies

- **get**: State management, routing, dependency injection
- **dio**: HTTP client for API calls
- **flutter_secure_storage**: Secure token storage
- **syncfusion_flutter_pdfviewer**: PDF viewer
- **epubx**: EPUB reader
- **razorpay_flutter**: Payment gateway
- And more... (see `pubspec.yaml`)

## Development Guidelines

1. Follow the folder structure strictly
2. Use GetX controllers for state management
3. Keep business logic in use cases (domain layer)
4. Use models for data serialization
5. Follow naming conventions (snake_case for files, PascalCase for classes)

## Next Steps

- [ ] Implement authentication flow
- [ ] Create book listing and search
- [ ] Build eBook reader
- [ ] Integrate payment gateway
- [ ] Add offline reading support
- [ ] Implement DRM protection

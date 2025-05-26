# Enterprise Mobile App

> Enterprise-grade mobile application architecture designed for scalability, maintainability, and performance.

[![Flutter](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

This project demonstrates an enterprise mobile app architecture with built-in capabilities for:

- ✅ **Scalability**: Support for millions of users
- ✅ **Modularity**: Feature-based architecture
- ✅ **Testability**: Comprehensive testing strategy
- ✅ **Performance**: Multi-layer caching & optimization
- ✅ **Maintainability**: Clean architecture principles
- ✅ **Real-time**: WebSocket & gRPC support

## Getting Started

### Prerequisites

```bash
# Flutter SDK
flutter --version
# Should be >= 3.32.0

# Dart SDK  
dart --version
# Should be >= 3.8.0

# Tools
dart pub global activate melos
dart pub global activate build_runner
```

### Setup

1. Clone the repository:

```bash
git clone https://github.com/your-org/enterprise-mobile-app.git
cd enterprise-mobile-app
```

2. Setup workspace:

```bash
melos bootstrap
```

3. Generate code:

```bash
melos run build_runner
```

4. Run the app:

```bash
cd app
flutter run
```

## Architecture

This project follows a Clean Architecture approach with a strong focus on separation of concerns:

- **Domain Layer**: Entities, Use Cases, Repository Interfaces
- **Data Layer**: Repository Implementations, Data Sources, Models
- **Presentation Layer**: Pages, Widgets, Providers

Key architectural features:

- **Feature-based modularization**
- **Dependency injection** with GetIt and Injectable
- **State management** with Riverpod
- **Multi-layer caching** for optimal performance
- **Comprehensive error handling**
- **Analytics and monitoring** 

## Technology Stack

- **Core Framework**: Flutter 3.32.0, Dart 3.8.0
- **State Management**: flutter_riverpod 2.3.4
- **Dependency Injection**: get_it 8.0.0, injectable 2.5.0
- **Networking**: dio 5.7.0, web_socket_channel 3.0.0, grpc 3.2.4
- **Local Storage**: hive_flutter 1.1.0, sqlite3_flutter_libs 0.5.0
- **Analytics**: firebase_analytics 11.3.0, sentry_flutter 8.9.0
- **Build System**: melos 6.1.0

## Project Structure

```
enterprise_mobile_app/
├── 📦 packages/                    # Shared packages
│   ├── 🔧 core/                    # Core business logic
│   ├── 🎨 design_system/           # UI Design System
│   └── 🚀 features/                # Feature modules
│       └── user_management/        # Sample feature
├── 📱 app/                         # Main application
├── 🧪 tools/                       # Development tools
└── 📚 docs/                        # Documentation
```

## Development

To keep the codebase consistent, please follow these guidelines:

- Run `dart format .` before committing
- Run `dart analyze --fatal-infos` to check for issues
- Write tests for new features
- Update documentation as needed

## Build & Deploy

Use the build script to create optimized builds:

```bash
# Windows (PowerShell)
.\tools\build.ps1 -Environment production -Platform android
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

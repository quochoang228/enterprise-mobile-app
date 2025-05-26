# Contributing to Enterprise Mobile App

Thank you for your interest in contributing to our Enterprise Mobile App project! This document provides guidelines and instructions for contributing.

## Development Process

### Setting Up Development Environment

1. **Prerequisites**:
   - Flutter SDK (version 3.32.0 or higher)
   - Dart SDK (version 3.8.0 or higher)
   - VS Code, Android Studio, or another IDE with Flutter support
   - Git

2. **Clone and Setup**:
   ```bash
   git clone https://github.com/your-org/enterprise-mobile-app.git
   cd enterprise-mobile-app
   melos bootstrap  # Install all dependencies
   melos run build_runner  # Generate code
   ```

### Branch Naming Convention

- `feature/feature-name`: For new features
- `bugfix/issue-description`: For bug fixes
- `improvement/description`: For improvements to existing features
- `refactor/description`: For refactoring code
- `docs/description`: For documentation updates
- `test/description`: For adding or updating tests

### Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `perf:` Performance improvements
- `test:` Adding or updating tests
- `chore:` Maintenance tasks, dependency updates, etc.

Example: `feat: add user authentication flow`

## Pull Request Process

1. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**:
   - Follow the coding standards
   - Write tests for new features
   - Ensure existing tests pass
   - Update documentation as needed

3. **Commit Your Changes**:
   ```bash
   git commit -m "feat: add your feature description"
   ```

4. **Push to Your Branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**:
   - Fill in the PR template
   - Link any related issues
   - Request reviews from maintainers

6. **Review Process**:
   - Address review comments
   - Update your branch as needed
   - Once approved, your PR will be merged

## Code Style Guidelines

### Dart/Flutter

- Follow the [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- Run `flutter analyze` to check for issues
- Run `flutter format .` to format your code

### Architecture Guidelines

- Follow Clean Architecture principles
- Maintain proper separation between layers (presentation, domain, data)
- Make services injectable through dependency injection
- Use proper error handling with Either pattern for failures
- Write unit tests for business logic
- Write widget tests for UI components

### Performance Considerations

- Use const constructors where appropriate
- Avoid unnecessary rebuilds
- Implement caching for expensive operations
- Profile your code for performance bottlenecks

## Testing

- **Unit Tests**: Test business logic in isolation
- **Widget Tests**: Test UI components
- **Integration Tests**: Test feature workflows

Run tests with:
```bash
melos run test
```

## Documentation

- Update README.md with new features or changes
- Add inline documentation for complex logic
- Update API documentation for public interfaces

## Getting Help

If you need help, you can:
- Open an issue with a clear description
- Contact the maintainers
- Join our community channels

---

Thank you for contributing to making Enterprise Mobile App better for everyone!

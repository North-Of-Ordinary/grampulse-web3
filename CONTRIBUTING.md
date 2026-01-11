# Contributing to GramPulse

Thank you for your interest in contributing to GramPulse. This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

All contributors are expected to follow professional and respectful standards. We maintain an inclusive environment free from harassment or discrimination.

## Getting Started

### Fork and Clone
1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/grampulse-icsrf.git
   cd GramPulse
   ```

### Set Up Development Environment
1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Generate necessary code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. Create a development branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Code Standards

#### Dart/Flutter Guidelines
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Maintain consistent indentation (2 spaces)
- Keep lines under 80 characters when possible
- Add documentation for public APIs

#### File Organization
- Group related functionality into modules
- Follow Clean Architecture principles
- Maintain separation of concerns
- Use appropriate naming conventions

#### Naming Conventions
- Classes: PascalCase (`UserDashboard`, `ReportBloc`)
- Functions/methods: camelCase (`getUserReports()`, `submitReport()`)
- Constants: UPPER_SNAKE_CASE (`API_TIMEOUT`, `MAX_RETRIES`)
- Private members: prefix with underscore (`_privateField`)

### Commit Guidelines

#### Commit Messages
Follow conventional commit format:
```
<type>(<scope>): <description>

<body (optional)>

<footer (optional)>
```

#### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code restructuring without feature changes
- `perf`: Performance improvements
- `test`: Test additions or modifications
- `chore`: Build system, dependencies, or tooling changes
- `style`: Code style changes (formatting, missing semicolons, etc.)

#### Examples
```bash
git commit -m "feat(auth): Add phone number validation with regex"
git commit -m "fix(citizen): Resolve map loading issue on low bandwidth"
git commit -m "docs: Update installation instructions"
git commit -m "refactor(services): Extract API client logic into separate module"
```

### Branch Naming

Use descriptive branch names:
- Feature: `feature/user-authentication`
- Bug fix: `bugfix/map-crash-on-rotation`
- Documentation: `docs/api-documentation`
- Improvement: `improvement/performance-optimization`

## Testing

### Writing Tests
- Write tests for new features and bug fixes
- Maintain test coverage above 70%
- Use descriptive test names
- Test both success and failure cases

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_bloc_test.dart

# Run tests with coverage
flutter test --coverage
```

## Pull Request Process

### Before Submitting
1. Ensure your code follows project standards
2. Test thoroughly on both Android and iOS
3. Update documentation if needed
4. Verify no merge conflicts with the main branch

### Creating a Pull Request
1. Push your branch:
   ```bash
   git push origin feature/your-feature-name
   ```

2. Open a Pull Request with:
   - Clear, descriptive title
   - Detailed description of changes
   - Reference to related issues (if any)
   - Screenshots or demo links (for UI changes)

### PR Template
```markdown
## Description
Briefly describe the changes and why they were made.

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Performance improvement

## Related Issue
Closes #(issue number)

## Testing Performed
Describe how you tested these changes.

## Screenshots (if applicable)
Include screenshots for UI changes.

## Checklist
- [ ] Code follows project guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No new warnings generated
```

## Code Review Process

### For Reviewers
- Provide constructive feedback
- Review for code quality, security, and performance
- Request changes if necessary
- Approve when satisfied

### For Contributors
- Address all review comments
- Request re-review after making changes
- Engage in respectful discussion
- Thank reviewers for their time

## Reporting Issues

### Bug Reports
Include:
- Clear description of the issue
- Steps to reproduce
- Expected vs. actual behavior
- Platform and version information
- Relevant logs or error messages

### Feature Requests
Include:
- Clear description of desired functionality
- Use case and benefits
- Potential implementation approach
- Examples from similar applications

## Documentation

### Code Documentation
- Add comments for complex logic
- Document public functions and classes
- Update README for user-facing changes
- Maintain architecture documentation

### Commit Documentation
All commits should be clear and descriptive to understand the purpose of changes at a glance.

## Project Structure Maintenance

When adding new features:
1. Follow existing architectural patterns
2. Use the established folder structure
3. Maintain consistency with existing code style
4. Ensure new modules are properly integrated

## Release Process

The maintainers manage the release process. Version numbering follows Semantic Versioning:
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

## Questions and Support

- Open an issue for questions or discussions
- Use clear subject lines
- Provide context and examples
- Follow up on feedback promptly

## License

By contributing, you agree that your contributions will be licensed under the same terms as the project.

## Recognition

Contributors will be recognized in the project. Thank you for your efforts in making GramPulse better!

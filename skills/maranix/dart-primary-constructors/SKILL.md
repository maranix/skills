---
name: dart-primary-constructors
description: Refactor traditional Dart classes and Flutter widgets to use primary constructors introduced in Dart 3.13+. Use when migrating Dart classes to primary constructor syntax, configuring constant/enum primary constructors, setting up private fields, super parameters, primary constructor scoping, or enforcing Dart 3.13+ language standards.
---

# Dart Primary Constructors (Dart 3.13+)

Prefer and migrate Dart classes, Flutter widgets, and Enums to primary constructors to eliminate constructor boilerplate and field declarations.

## Prerequisites

- **Dart SDK Version**: `>=3.13.0` in `pubspec.yaml` (`environment: sdk: '>=3.13.0 <4.0.0'`).

## Quick Start

```dart
// Standard Class
class Point(final int x, final int y);

// Field Initialization from Parameter
class DeltaPoint(final int x, int delta) {
  final int y = x + delta; // Accesses 'x' and 'delta' constructor parameters
}

// Constant Class & Enum
class const Color(final int hex);
enum Status(final int code) { success(200), notFound(404); }
```

## Key Scoping & Language Rules

1. **Primary Initializer Scope** (non-late field initializers & initializer list `this : ...`): Parameter names refer directly to constructor parameters.
2. **Primary Parameter Scope** (inside constructor body `{ ... }`):
   - **Declaring parameters** (`final`/`var`): Refer to the **induced instance variable** (field).
   - **Non-declaring parameters** (no `final`/`var`): Refer to the **constructor parameter**.
3. **Implicit Field Induction**: Parameters in header marked with `final` or `var` create instance fields.
4. **Private Fields in Named Parameters**: `{required final String _name}` exposes public argument `name:` while inducing private field `_name`.
5. **Constant Primary Constructors (`class const`)**: Prohibits body blocks `{ ... }`; all fields must be `final`.
6. **In-Body Generative Constructors**: MUST redirect to primary constructor (`this(...)`).

## Migration Checklist

- [ ] **Verify SDK**: Set `pubspec.yaml` SDK constraint to `>=3.13.0`.
- [ ] **Header Signature**: Move parameters to class header using `final` or `var`.
- [ ] **Check Scoping**: Verify field initializers use Initializer Scope and body logic uses Parameter Scope.
- [ ] **Private Fields**: Use `final String _field` or `{required final String _privateField}` (public arg `privateField`).
- [ ] **Const & Enum**: Use `class const ClassName(...)` or `enum EnumName(final Type param)`. Ensure no body block on `const`.
- [ ] **Redirect In-Body Constructors**: Refactor secondary generative constructors to redirect to `this(...)`.
- [ ] **Verification**: Run `dart analyze` and `dart test` (or `flutter test`).

## Detailed Guides & Examples

- See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for scoping rules, step-by-step refactoring workflows, and constraints.
- See [EXAMPLES.md](EXAMPLES.md) for code samples (Scoping demo, Const, Enum, Private fields, Super parameters, Named constructors).

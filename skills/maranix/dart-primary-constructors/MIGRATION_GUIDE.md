# Dart 3.13+ Primary Constructors Migration Guide

This guide details how to refactor traditional Dart classes, Flutter widgets, and Enums to use primary constructors introduced in **Dart 3.13**.

---

## 1. Prerequisites & Version Constraints

Ensure your project's `pubspec.yaml` specifies Dart SDK 3.13 or higher:

```yaml
environment:
  sdk: '>=3.13.0 <4.0.0'
```

---

## 2. Primary Constructor Scopes

Dart manages visibility of primary constructor parameters using two distinct scopes:

### A. Primary Initializer Scope
- **Applies to**: Non-late field declarations in the class body and the primary constructor's initializer list (after `this :`).
- **Behavior**: A parameter name (e.g. `x` or `delta`) refers **directly to the constructor parameter**.
- **Use Case**: Initializing non-late fields directly from header parameters without an initializer list.

```dart
class DeltaPoint(final int x, int delta) {
  // 'x' and 'delta' refer directly to the constructor parameters!
  final int y = x + delta;
}
```

### B. Primary Parameter Scope
- **Applies to**: The constructor body block (inside `{ ... }`).
- **Behavior**:
  - **Declaring parameters** (`final` or `var`): Parameter name refers to the **induced instance variable (field)**. Assigning to it inside the body updates the field on `this`.
  - **Non-declaring parameters** (no `final` or `var`): Parameter name still refers to the **constructor parameter**.

---

## 3. Comprehensive Feature Breakdown

### A. Scoping & Body Execution Demo

```dart
class ScopingDemo(var String x, String suffix) {
  // 1. Primary Initializer Scope: 'x' refers to constructor parameter 'x'
  final String fieldAtDeclaration = x;
  final String fieldInInitializer;

  // 2. Initializer List: 'x' refers to constructor parameter 'x'
  this : fieldInInitializer = x {
    // 3. Primary Parameter Scope (Body):
    // 'x' is a declaring parameter, so it refers to the induced instance variable.
    // Assigning to 'x' updates the field!
    x = x.toUpperCase();

    // 'suffix' is a non-declaring parameter (no final/var), so it refers to constructor parameter.
    print('$x$suffix');
  }
}
```

---

### B. Private Field Initialization
You can declare private fields directly in the primary constructor header using leading underscores:

1. **Positional Parameters**:
   ```dart
   class User(final String _id, final String _name);
   ```
   *Creates private fields `_id` and `_name`.*

2. **Named Parameters with Private Backing Fields**:
   ```dart
   class User({required final String _name, final int _age = 0});
   ```
   *Note: To callers, the named argument is public (`User(name: 'Alice', age: 30)`), but the implicitly induced field inside the class is private (`_name` and `_age`).*

---

### C. Constant Primary Constructors (`class const`)

To make a class's primary constructor `const`, place `const` after `class`:

```dart
class const Point(final int x, final int y);
```

#### Rules for `class const`:
- All induced fields must be `final`.
- **Cannot have a constructor body block (`{ ... }`)**, even an empty one. Must end with `;` or an initializer list followed by `;`.
- Cannot use `var` modifier on declaring parameters.

---

### D. Enum Primary Constructors

Enums with primary constructors eliminate the need to declare separate instance fields and constructors:

```dart
enum Priority(final int level, final String label) {
  low(1, 'Low Priority'),
  medium(2, 'Medium Priority'),
  high(3, 'High Priority');
}
```

#### Rules for Enums:
- Enum primary constructors are **implicitly constant**.
- Writing `enum const Priority(...)` is redundant and triggers the `unnecessary_const_in_enum_constructor` diagnostic lint.

---

### E. Super Parameters

Primary constructors support `super.parameterName` forwarding directly in the header signature:

```dart
abstract class BaseEntity(final String id, final DateTime createdAt);

class User(super.id, super.createdAt, final String email)
    extends BaseEntity;
```

In Flutter widgets:
```dart
class MyWidget({super.key, required final String title})
    extends StatelessWidget;
```

---

### F. In-Body Named Constructors & Concise Syntax

When a class has a primary constructor, **all other generative constructors defined in the class body MUST redirect** to the primary constructor (`this(...)`).

In Dart 3.13+, in-body named constructors can also use the concise syntax:

```dart
class Vector(final double x, final double y) {
  // Traditional redirection
  Vector.zero() : this(0.0, 0.0);

  // Concise in-body syntax (new keyword)
  new unitX() : this(1.0, 0.0);

  // Factory constructors are NOT generative, so they do not need to redirect directly
  factory Vector.fromJson(Map<String, dynamic> json) {
    return Vector(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}
```

---

## 4. Strict Rules & Constraints Summary

| Feature / Modifier | Allowed in Primary Constructor Header? | Notes / Constraints |
| :--- | :--- | :--- |
| `final` | ✅ Yes | Induces a `final` instance variable |
| `var` | ✅ Yes | Induces a mutable instance variable |
| `const` | ✅ Yes (`class const Name(...)`) | Prohibits body blocks `{}`; all fields must be `final` |
| `{ ... }` (Body) | ✅ Yes (Non-const classes only) | Primary parameter scope; declaring params refer to fields |
| `super.param` | ✅ Yes | Forwards argument to superclass constructor |
| Plain param (no `final`/`var`) | ✅ Yes | Does NOT create a field; scoped to initializer/body as constructor parameter |
| `late` | ❌ No (Compile Error) | Disallowed on primary constructor parameters |
| `external` | ❌ No (Compile Error) | Disallowed on primary constructor parameters |
| Non-redirecting generative constructor | ❌ No (Compile Error) | All in-body generative constructors must redirect to `this(...)` |

---

## 5. Verification Workflow

1. Run static analysis to detect syntax errors or lint warnings:
   ```bash
   dart analyze
   ```
2. Run test suite:
   ```bash
   dart test
   # or for Flutter projects
   flutter test
   ```

# Dart Primary Constructors Code Examples (Dart 3.13+)

This document provides comprehensive code examples for all primary constructor features and scoping behaviors.

---

## 1. Primary Constructor Scopes (Initializer Scope vs Parameter Scope)

Dart manages parameter visibility using two scopes:
- **Primary Initializer Scope** (non-late field initializers & initializer lists): Parameter names refer directly to constructor parameters.
- **Primary Parameter Scope** (inside constructor body `{ ... }`): Declaring parameters (`final`/`var`) refer to induced fields; non-declaring parameters refer to constructor parameters.

### A. Comprehensive Scoping & Body Execution Example
```dart
class ScopingDemo(var String x, String suffix) {
  // In a non-late field initializer, 'x' refers to the parameter 'x'.
  final String fieldAtDeclaration = x;
  final String fieldInInitializer;

  // In the initializer list, 'x' refers to the parameter 'x'.
  this : fieldInInitializer = x {
    // Inside the body, 'x' refers to the induced instance variable,
    // so assigning to it updates the field.
    x = x.toUpperCase();

    // 'suffix' induces no field, so it still refers to the parameter.
    print('$x$suffix');
  }
}
```

### B. Direct Field Initialization from Constructor Parameter
```dart
class DeltaPoint(final int x, int delta) {
  // 'x' (declaring param) and 'delta' (non-declaring param) are directly accessible
  // in non-late field initializers via the Primary Initializer Scope!
  final int y = x + delta;
}
```

---

## 2. Primary Constructors with Constructor Bodies (Validation & Logic)

When object instantiation requires validation, assertions, or logging, primary constructors can have a body block (`{ ... }`) immediately following the header signature or initializer list.

### A. Assertion & Validation Body
```dart
// Traditional
class UserAccount {
  final String username;
  final String email;

  UserAccount(this.username, this.email) {
    assert(username.isNotEmpty, 'Username cannot be empty');
    assert(email.contains('@'), 'Invalid email address');
  }
}

// Primary Constructor with Body
class UserAccount(final String username, final String email) {
  assert(username.isNotEmpty, 'Username cannot be empty');
  assert(email.contains('@'), 'Invalid email address');

  // Scoped body logic (runs after fields are initialized)
  print('Initialized UserAccount for $username');
}
```

### B. Initializer List Combined with Constructor Body
```dart
import 'dart:math' as math;

// Traditional
class Circle {
  final double radius;
  final double area;

  Circle(this.radius) : area = math.pi * radius * radius {
    assert(radius > 0, 'Radius must be positive');
  }
}

// Primary Constructor with Initializer List and Body
class Circle(final double radius) : area = math.pi * radius * radius {
  final double area; // Field declared in body, initialized via initializer list

  assert(radius > 0, 'Radius must be positive');
}
```

> **Note**: Constant primary constructors (`class const`) **cannot** have a constructor body block `{ ... }`.

---

## 3. Initializing Private Fields

### A. Positional Private Fields
```dart
// Traditional
class User {
  final String _id;
  final String _secretKey;

  User(this._id, this._secretKey);
}

// Primary Constructor
class User(final String _id, final String _secretKey);
```

### B. Named Parameters with Private Backing Fields
```dart
// Traditional
class Settings {
  final String _theme;
  final bool _notificationsEnabled;

  Settings({
    required String theme,
    bool notificationsEnabled = true,
  })  : _theme = theme,
        _notificationsEnabled = notificationsEnabled;
}

// Primary Constructor
// Callers pass `theme:` and `notificationsEnabled:`, but fields induced are `_theme` and `_notificationsEnabled`.
class Settings({
  required final String _theme,
  final bool _notificationsEnabled = true,
});
```

---

## 4. Constant Primary Constructors (`class const`)

### Before (Traditional Syntax)
```dart
class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);
}
```

### After (Primary Constructor Syntax)
```dart
// Place `const` after `class`. Note: NO body block allowed!
class const Point(final int x, final int y);
```

---

## 5. Enum Primary Constructors

### Before (Traditional Syntax)
```dart
enum HttpStatus {
  ok(200, 'OK'),
  notFound(404, 'Not Found'),
  internalServerError(500, 'Internal Server Error');

  final int code;
  final String message;

  const HttpStatus(this.code, this.message);
}
```

### After (Primary Constructor Syntax)
```dart
// Enums with primary constructors are implicitly constant.
enum HttpStatus(final int code, final String message) {
  ok(200, 'OK'),
  notFound(404, 'Not Found'),
  internalServerError(500, 'Internal Server Error');
}
```

---

## 6. Super Parameters & Class Inheritance

### Before (Traditional Syntax)
```dart
abstract class Appliance {
  final String brand;
  final double powerWatts;

  const Appliance(this.brand, this.powerWatts);
}

class WashingMachine extends Appliance {
  final double capacityKg;

  const WashingMachine(
    super.brand,
    super.powerWatts,
    this.capacityKg,
  );
}
```

### After (Primary Constructor Syntax)
```dart
abstract class Appliance(final String brand, final double powerWatts);

class WashingMachine(
  super.brand,
  super.powerWatts,
  final double capacityKg,
) extends Appliance;
```

---

## 7. In-Body Named Constructors & Factory Constructors

### Before (Traditional Syntax)
```dart
class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  const Complex.real(double real) : this(real, 0.0);
  const Complex.imaginary(double imaginary) : this(0.0, imaginary);

  factory Complex.zero() => const Complex(0.0, 0.0);
}
```

### After (Primary Constructor Syntax)
```dart
class const Complex(final double real, final double imaginary) {
  // Named constructors in body MUST redirect to primary constructor
  const Complex.real(double real) : this(real, 0.0);

  // Concise in-body constructor syntax (Dart 3.13+)
  const new imaginary(double imaginary) : this(0.0, imaginary);

  factory Complex.zero() => const Complex(0.0, 0.0);
}
```

---

## 8. Flutter StatelessWidget & StatefulWidget

### StatelessWidget Example
```dart
import 'package:flutter/material.dart';

class UserTile({
  super.key,
  required final String _name,
  required final String _email,
  final VoidCallback? onTap,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_name),
      subtitle: Text(_email),
      onTap: onTap,
    );
  }
}
```

### StatefulWidget Example
```dart
import 'package:flutter/material.dart';

class ExpandablePanel({
  super.key,
  required final Widget child,
  final bool initialExpanded = false,
}) extends StatefulWidget {
  @override
  State<ExpandablePanel> createState() => _ExpandablePanelState();
}
```

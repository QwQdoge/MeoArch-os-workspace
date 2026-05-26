# MeoUI Component Development Guidelines

All components in this repository must follow these strict guidelines to ensure consistency, high performance, and a "geeky" high-quality feel.

## 1. Material Design 3 (MD3) Compliance
- Follow the official MD3 specifications from [m3.material.io](https://m3.material.io).
- Use proper tokens from `MeoTheme.qml` for colors, spacing, and typography.

## 2. Dynamic Scaling
- **Every** pixel-based value (width, height, margin, padding, font size, radius) MUST be multiplied by `MeoTheme.globalScale`.
- Example: `font.pixelSize: 14 * MeoTheme.globalScale`
- Use `implicitWidth` and `implicitHeight` to ensure components adapt to their content and scaling.

## 3. Animation and Easing
- Use the "Soul Curve" for all smooth transitions: `easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]`.
- Standard duration is `150ms`.
- Always use `Behavior` on properties like `color`, `opacity`, `width`, and `scale`.

## 4. State Layer (Interactive Feedback)
- Hover and Pressed states should use the "State Layer" pattern:
  - **Hover:** `Qt.tint(baseColor, Qt.rgba(textColor.r, textColor.g, textColor.b, 0.08))`
  - **Pressed:** `Qt.tint(baseColor, Qt.rgba(textColor.r, textColor.g, textColor.b, 0.12))`
- Avoid pure `transparent` for backgrounds when animating tints to prevent black edge artifacts in Qt. Instead, use `Qt.rgba(textColor.r, textColor.g, textColor.b, 0)`.

## 5. Scope Protection
- Components should be "atomic" and self-contained.
- Use `readonly property bool isDarkMode: MeoTheme.isDarkMode` and similar aliases to avoid direct global scope dependency issues during instantiation.
- Provide safe default values for theme properties using `typeof MeoTheme !== 'undefined'` checks if the component might be used in environments where the singleton isn't registered.

## 6. Code Style
- Add clear comments explaining MD3 specific logic.
- Use emojis (🌟, 🎨, 📐, 🔤, 🖼️) to categorize sections of the QML file (consistent with existing components).
- Ensure `import MeoUI` is used if one component depends on another within the same module.

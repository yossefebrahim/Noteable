import SwiftUI

extension Color {
  // MARK: - Light Theme Colors

  static let appBackgroundLight = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF
  static let appSurfaceLight = Color(red: 0.96, green: 0.96, blue: 0.97) // #F5F5F7
  static let appTextPrimaryLight = Color(red: 0.10, green: 0.10, blue: 0.10) // #1A1A1A
  static let appTextSecondaryLight = Color(red: 0.42, green: 0.42, blue: 0.42) // #6B6B6B
  static let appAccentLight = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
  static let appBorderLight = Color(red: 0.90, green: 0.90, blue: 0.90) // #E5E5E5

  // MARK: - Dark Theme Colors

  static let appBackgroundDark = Color(red: 0.0, green: 0.0, blue: 0.0) // #000000
  static let appSurfaceDark = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E
  static let appTextPrimaryDark = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF
  static let appTextSecondaryDark = Color(red: 0.60, green: 0.60, blue: 0.62) // #98989D
  static let appAccentDark = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF
  static let appBorderDark = Color(red: 0.22, green: 0.22, blue: 0.23) // #38383A

  // MARK: - Semantic Colors (Adaptive)

  static let appBackground = Color(
    light: appBackgroundLight,
    dark: appBackgroundDark
  )

  static let appSurface = Color(
    light: appSurfaceLight,
    dark: appSurfaceDark
  )

  static let appTextPrimary = Color(
    light: appTextPrimaryLight,
    dark: appTextPrimaryDark
  )

  static let appTextSecondary = Color(
    light: appTextSecondaryLight,
    dark: appTextSecondaryDark
  )

  static let appAccent = Color(
    light: appAccentLight,
    dark: appAccentDark
  )

  static let appBorder = Color(
    light: appBorderLight,
    dark: appBorderDark
  )
}

// MARK: - Adaptive Color Helper

extension Color {
  init(light: Color, dark: Color) {
    self.init(UIColor { traitCollection in
      if traitCollection.userInterfaceStyle == .dark {
        return UIColor(dark)
      } else {
        return UIColor(light)
      }
    })
  }
}

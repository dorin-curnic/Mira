# Mira

[![Build](https://github.com/dorin-curnic/Mira/actions/workflows/build.yml/badge.svg)](https://github.com/dorin-curnic/Mira/actions/workflows/build.yml)
![Swift](https://img.shields.io/badge/language-Swift-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey)
![Status](https://img.shields.io/badge/status-active%20development-yellow)
![License](https://img.shields.io/badge/license-none-lightgrey)

Mira is an early-stage SwiftUI app for iOS and macOS that helps UTM students work with campus network-related tools from one place.

The project currently focuses on Wi-Fi connection support, network activity visibility, basic speed testing, credential-related settings, localization, and a problem reporting flow. Mira is still in active development and is not published on the App Store yet.

## Project status

Mira is currently a student-built prototype in active development.

The goal of the project is to become a practical, maintainable, open-source Apple-platform app for UTM students. The app is not production-ready yet, and some features are still mocked, local-only, or waiting for a real backend integration.

Current status:

- iOS and macOS targets exist.
- Shared SwiftUI code is used across both platforms.
- The app builds through GitHub Actions.
- Localization support is already present.
- Backend integration is not implemented yet.
- App Store distribution is not configured yet.
- A final open-source license still needs to be selected before the project is treated as fully open source.

## Features

Mira currently includes the following areas:

### Dashboard

The Dashboard provides a quick overview of the current connection state and includes a basic download speed test interface.

Current functionality includes:

- Theme selection.
- Language selection.
- Wi-Fi connection status UI.
- Connection-related action cards.
- Speed test card.
- Radial speed chart.

### Network

The Network page displays network usage information collected from the device.

Current functionality includes:

- Download and upload traffic display.
- Network usage chart.
- Chart tooltip support.
- Network traffic type models.
- Platform-aware network interface reading.

### Settings

The Settings page contains app configuration and support-related flows.

Current functionality includes:

- Connection settings.
- Credential management UI.
- Support section.
- Report Problem sheet.

### Localization

Mira uses `Localizable.xcstrings` for localized strings.

Currently supported localization identifiers include:

- English
- Romanian
- Russian
- French
- Simplified Chinese
- Japanese

Localization is part of the app architecture and should be considered when adding new user-facing strings.

## Supported platforms

Mira currently has two app targets:

- iOS
- macOS

The shared app code lives in `MiraShared`, while each platform has its own app entry point.

## Requirements

To build and run Mira locally, you need:

- macOS
- Xcode
- iOS Simulator for the iOS target
- SwiftUI-compatible Apple SDKs

The project is developed with Xcode and uses a standard `.xcodeproj` setup.

## Getting started

Clone the repository:

```bash
git clone https://github.com/dorin-curnic/Mira.git
cd Mira
```

Open the project in Xcode:

```bash
open Mira.xcodeproj
```

Then choose one of the available schemes:

- `Mira_iOS`
- `Mira_macOS`

Build and run the selected scheme from Xcode.

## Building from the command line

### Build iOS

```bash
xcodebuild \
  -project Mira.xcodeproj \
  -scheme Mira_iOS \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### Build macOS

```bash
xcodebuild \
  -project Mira.xcodeproj \
  -scheme Mira_macOS \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

These are similar to the commands used by the GitHub Actions build workflow.

## Project structure

The main project structure is:

```text
Mira/
├── Mira.xcodeproj/
├── MiraShared/
│   ├── App/
│   ├── DesignSystem/
│   ├── Features/
│   ├── Models/
│   ├── Resources/
│   ├── Services/
│   └── Utilities/
├── MiraiOS/
└── MiramacOS/
```

### `MiraShared`

Contains most of the app code shared between iOS and macOS.

Important areas:

```text
MiraShared/App
```

Contains shared app-level views such as `ContentView`.

```text
MiraShared/DesignSystem
```

Contains reusable UI components, styles, layout helpers, form controls, theme tokens, and toast UI.

```text
MiraShared/Features
```

Contains feature-specific SwiftUI screens and components.

Current feature areas include:

- Dashboard
- Network
- Settings
- Report Problem
- Credentials

```text
MiraShared/Models
```

Contains shared data models and app enums, including page definitions, localization models, theme models, network usage models, report categories, and Wi-Fi credential models.

```text
MiraShared/Resources
```

Contains app resources, including localization files.

```text
MiraShared/Services
```

Contains service-layer code such as authentication, clipboard handling, network usage reading, and speed test logic.

```text
MiraShared/Utilities
```

Contains formatting helpers and small Swift extensions used across the app.

### `MiraiOS`

Contains the iOS app entry point.

### `MiramacOS`

Contains the macOS app entry point.

## Architecture notes

Mira uses a shared SwiftUI architecture.

The main idea is:

- Keep platform-specific entry points small.
- Put reusable app UI in `MiraShared`.
- Organize code by feature.
- Keep reusable visual components in the design system.
- Keep app state ownership close to the views that need it.
- Use services for platform/system interactions such as authentication, clipboard, network usage, and speed testing.
- Use localization keys instead of hardcoded user-facing strings.

The root app view is responsible for selecting the active page, applying the selected theme, applying the selected language, and starting/stopping the network usage service.

On iOS, Mira uses a tab-based layout.

On macOS, Mira uses a sidebar/detail layout.

## Security and privacy

Mira touches several security-sensitive areas, so changes in these areas should be reviewed carefully.

Sensitive areas include:

- Wi-Fi credentials
- Password reveal actions
- Local device authentication
- Clipboard copy actions
- Network usage data
- Report Problem attachments
- Future backend communication

Current security expectations:

- Do not log passwords, tokens, credentials, or sensitive network data.
- Do not expose credentials in debug output.
- Keep password reveal protected by local authentication.
- Treat clipboard actions as user-visible and intentional.
- Treat report attachments as potentially sensitive user data.
- Avoid sending any user data to a backend until the backend behavior is explicit and reviewed.
- Prefer minimal, focused changes when touching authentication, credentials, or networking code.

Mira should not claim production-level credential security until the storage and backend behavior are fully reviewed and documented.

## Localization

User-facing strings should go through the localization system instead of being hardcoded directly in views.

Main localization files and models:

```text
MiraShared/Resources/Localizable.xcstrings
MiraShared/Models/MiraText.swift
MiraShared/Models/MiraLanguage.swift
MiraShared/Utilities/Extensions/MiraText_Text.swift
```

When adding new UI text:

1. Add a key to `MiraText`.
2. Add the localized value to `Localizable.xcstrings`.
3. Use the existing localization helper in the SwiftUI view.
4. Check that the UI still works in longer languages.

## Development workflow

The project is developed through small GitHub issues and focused branches.

Recommended workflow:

1. Pick or create a clear GitHub issue.
2. Create a focused branch for the issue.
3. Make the smallest maintainable change that solves the issue.
4. Build both iOS and macOS targets.
5. Manually test the affected screens.
6. Open a pull request.
7. Merge after review.

Issue templates are available in `.github/ISSUE_TEMPLATE`.

## Testing and validation

Mira currently relies mainly on build checks and manual validation.

GitHub Actions currently builds:

- iOS target
- macOS target

Before opening or merging a pull request, validate the relevant behavior manually.

Recommended manual checks:

- App launches on iOS.
- App launches on macOS.
- Dashboard renders correctly.
- Network page handles connected and disconnected states.
- Settings page renders correctly.
- Theme switching works.
- Language switching works.
- Credential UI does not expose sensitive values unintentionally.
- Password reveal requires authentication.
- Report Problem form handles empty and filled states.
- Attachment selection and removal behave correctly.
- No sensitive data is printed in logs.

Automated tests are not yet a major part of the project, but they should be added as the app logic becomes more stable.

## License

A license has not been added yet.

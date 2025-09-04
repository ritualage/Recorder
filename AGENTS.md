# Repository Guidelines

## Project Structure & Module Organization
- Source code: `Sources/Recorder/` organized by feature (`RecordScreen/`, `RecordVision/`, `RecordNotes/`). One primary type per file.
- Shared app scaffolding: `Sources/Recorder/RecorderApp.swift`, `Models.swift`, and views like `RecordPromptView.swift`.
- Assets and plists: `Resources/` (`Assets.xcassets`, `Info.iOS.plist`, `Info.macOS.plist`).
- Project definition: `project.yml` (XcodeGen). The checked-in `Recorder.xcodeproj` is generated.

## Build, Test, and Development Commands
- Generate project: `xcodegen generate` (requires `brew install xcodegen`).
- Open in Xcode: `open Recorder.xcodeproj` and select target: `Recorder macOS` or `Recorder iOS`.
- CLI build (macOS): `xcodebuild -scheme "Recorder macOS" -destination 'platform=macOS' build`.
- CLI build (iOS sim): `xcodebuild -scheme "Recorder iOS" -destination 'platform=iOS Simulator,name=iPad Pro (11-inch) (latest)' build`.

## Coding Style & Naming Conventions
- Language: Swift 5+, SwiftUI-first. Indentation: 4 spaces; max line length ~120.
- Follow Swift API Design Guidelines: Types `UpperCamelCase`, methods/properties `lowerCamelCase`, enums `UpperCamelCase` with `lowerCamelCase` cases when associated meaning fits.
- Structure by feature folders (e.g., `RecordScreen/RecordScreenView.swift`). Prefer small, focused views and models.
- Optional tools: SwiftFormat/SwiftLint (if added later); otherwise use Xcode defaults and organize imports.

## Testing Guidelines
- Framework: XCTest. Place tests under `Tests/RecorderTests/` mirroring feature folders.
- File names: `<TypeName>Tests.swift`; methods start with `test...()` and assert observable behavior.
- Run tests: `xcodebuild test -scheme "Recorder macOS" -destination 'platform=macOS'` (or an iPad simulator destination).
- Aim to cover permission flows, recording start/stop logic, and URL parsing for YouTube notes.

## Commit & Pull Request Guidelines
- Commits: imperative mood and scoped by feature, e.g., `RecordScreen: fix drawing overlay sizing`.
- PRs: clear description, linked issue, screenshots/GIFs for UI changes, and notes on permissions/entitlements if touched.
- Keep PRs focused; update `README.md`/`project.yml` when project structure or targets change. Ensure `xcodegen generate` and CLI builds succeed locally.

## Security & Configuration Tips
- Permissions: camera/microphone usage prompts rely on `Info.*.plist` entries; keep messages clear.
- Entitlements: advanced screen recording is stubbed—add entitlements deliberately and document them in the PR.

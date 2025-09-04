# Recorder (macOS + iPadOS)

This is a minimal, working SwiftUI project scaffold for the **Recorder** app you designed. It provides functional previews for camera and audio capture plus the **Record Notes From YouTube** and **Record Prompt** flows you mocked. Some advanced recording features are stubbed to keep the sample buildable without extra entitlements.

## Build

1. Install XcodeGen (one-time):  
   `brew install xcodegen`
2. Generate the Xcode project:  
   `cd Recorder`  
   `xcodegen generate`
3. Open the project in Xcode and select **Recorder macOS** or **Recorder iOS** (iPad simulator):  
   `open Recorder.xcodeproj`

> First camera/microphone use will trigger permission prompts.

## Structure

```
Recorder/
 ├─ project.yml                # XcodeGen project definition
 ├─ Resources/
 │   ├─ Info.iOS.plist
 │   ├─ Info.macOS.plist
 │   └─ Assets.xcassets/
 └─ Sources/Recorder/
     ├─ RecorderApp.swift      # App + navigation
     ├─ Models.swift
     ├─ RecordPromptView.swift
     ├─ RecordScreen/
     │   ├─ RecordScreenView.swift
     │   ├─ RecordWebcam.swift
     │   └─ RecordDrawing.swift
     ├─ RecordVision/
     │   ├─ RecordVisionAudio.swift
     │   └─ RecordVisionVideo.swift
     └─ RecordNotes/
         └─ RecordNotesFromYoutube.swift
```

### Notes
- **Record Screen** is a UI placeholder; macOS ScreenCaptureKit & iOS ReplayKit hooks can be added later.
- **Record Webcam** and **Record Vision Video** start a live camera preview; video recording saves temp files.
- **Record Vision Audio** records to an `.m4a` in temporary directory.
- **Record Notes From YouTube** accepts a YouTube URL, infers the thumbnail via `img.youtube.com`, and shows the *list view* (thumbnail + title + clip times | transcript | notes).
- **Record Prompt** implements the *pinned* vs *un‑pinned* model response UX including an **Unpin** confirmation.

Enjoy!
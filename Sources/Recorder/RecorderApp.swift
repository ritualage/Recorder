import SwiftUI

@main
struct RecorderApp: App {
    @StateObject var store = AppStore()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

struct RootView: View {
    enum Section: String, CaseIterable, Identifiable {
        case recordScreen = "Record Screen"
        case recordWebcam = "Record Webcam"
        case recordDrawing = "Record Drawing"
        case recordVisionAudio = "Record Vision Audio"
        case recordVisionVideo = "Record Vision Video"
        case recordNotesFromYouTube = "Record Notes From YouTube"
        case recordPrompt = "Record Prompt"
        var id: String { rawValue }
    }
    @State private var selection: Section? = .recordScreen
    var body: some View {
        NavigationSplitView {
            List(Section.allCases, selection: $selection) { section in
                Text(section.rawValue).tag(section)
            }
            .navigationTitle("Recorder")
        } detail: {
            switch selection {
            case .recordScreen: RecordScreenView()
            case .recordWebcam: RecordWebcam()
            case .recordDrawing: RecordDrawing()
            case .recordVisionAudio: RecordVisionAudio()
            case .recordVisionVideo: RecordVisionVideo()
            case .recordNotesFromYouTube: RecordNotesFromYouTube()
            case .recordPrompt: RecordPromptView()
            case .none: Text("Select a section")
            }
        }
    }
}
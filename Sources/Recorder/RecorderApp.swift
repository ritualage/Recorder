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
    enum NavItem: String, CaseIterable, Identifiable {
        case recordScreen = "Record Screen"
        case recordWebcam = "Record Webcam"
        case recordDrawing = "Record Drawing"
        case recordVisionHeader = "Record Vision"
        case recordVisionAudio = "Record Vision Audio"
        case recordVisionVideo = "Record Vision Video"
        case recordNotesHeader = "Record Notes"
        case recordNotesFromYouTube = "Record Notes From YouTube"
        case recordPrompt = "Record Prompt"
        var id: String { rawValue }
    }
    @State private var selection: NavItem? = .recordScreen
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Group {
                    Text(NavItem.recordScreen.rawValue).tag(NavItem.recordScreen as NavItem?)
                    Text(NavItem.recordWebcam.rawValue).tag(NavItem.recordWebcam as NavItem?)
                    Text(NavItem.recordDrawing.rawValue).tag(NavItem.recordDrawing as NavItem?)
                }
                Section(NavItem.recordVisionHeader.rawValue) {
                    Text(NavItem.recordVisionAudio.rawValue).tag(NavItem.recordVisionAudio as NavItem?)
                    Text(NavItem.recordVisionVideo.rawValue).tag(NavItem.recordVisionVideo as NavItem?)
                }
                Section(NavItem.recordNotesHeader.rawValue) {
                    Text(NavItem.recordNotesFromYouTube.rawValue).tag(NavItem.recordNotesFromYouTube as NavItem?)
                }
                Text(NavItem.recordPrompt.rawValue).tag(NavItem.recordPrompt as NavItem?)
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
                case .some(.recordVisionHeader): Text("Select a section")
                case .some(.recordNotesHeader): Text("Select a section")
            }
        }
    }
}

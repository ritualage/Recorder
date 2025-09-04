import Foundation
import SwiftUI
import AVFoundation

struct YouTubeClip: Identifiable, Hashable {
    let id = UUID()
    var videoID: String
    var title: String
    var start: TimeInterval
    var end: TimeInterval
    var transcript: String
    var notes: [Note]
}

enum Note: Identifiable, Hashable {
    case text(String)
    case audio(url: URL, duration: TimeInterval)
    case video(url: URL, duration: TimeInterval)
    case drawing(image: UIImageOrNSImage)
    var id: UUID { UUID() }
}

#if os(iOS)
import UIKit
typealias UIImageOrNSImage = UIImage
#else
import AppKit
typealias UIImageOrNSImage = NSImage
#endif

struct PromptRecord: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var webcamClip: URL?
    var audioClip: URL?
    var drawing: UIImageOrNSImage?
    var attachment: URL?
    var pinnedModel: ModelRun?
    var otherRuns: [ModelRun] = []
}

struct ModelRun: Identifiable, Hashable {
    let id = UUID()
    var modelName: String
    var summary: String
    var pinned: Bool = false
}

class AppStore: ObservableObject {
    @Published var clips: [YouTubeClip] = []
    @Published var prompts: [PromptRecord] = []
}
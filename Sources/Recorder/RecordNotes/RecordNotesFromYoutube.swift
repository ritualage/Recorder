import SwiftUI

struct RecordNotesFromYouTube: View {
    @EnvironmentObject var store: AppStore
    @State private var urlString: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    @State private var videoTitle: String = "The Changing Earth"
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("YouTube URL", text: $urlString).textFieldStyle(.roundedBorder)
                Button("Add Clip") {
                    let id = YouTubeIDParser.videoID(from: urlString) ?? "dQw4w9WgXcQ"
                    let clip = YouTubeClip(videoID: id, title: videoTitle, start: 30, end: 75, transcript: "Sample transcript for the selected range.", notes: [.text("My text note")])
                    store.clips.append(clip)
                }.buttonStyle(.borderedProminent)
            }
            Table(store.clips) {
                TableColumn("Clip") { clip in
                    HStack {
                        YouTubeThumbnailView(videoID: clip.videoID).frame(width: 120, height: 68).clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading) {
                            Text(clip.title).font(.headline)
                            Text(timeRange(clip)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                TableColumn("Transcript") { clip in
                    Text(clip.transcript).font(.body)
                }
                TableColumn("My Notes") { clip in
                    NotesListView(clip: clip)
                }
            }
        }
        .padding()
        .navigationTitle("Record Notes From YouTube")
    }
    func timeRange(_ c: YouTubeClip) -> String {
        func fmt(_ t: TimeInterval) -> String {
            String(format: "%02d:%02d", Int(t) / 60, Int(t) % 60)
        }
        return "\(fmt(c.start))–\(fmt(c.end))"
    }
}

struct NotesListView: View {
    let clip: YouTubeClip
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(clip.notes.enumerated()), id: \.__offset) { (_, note) in
                switch note {
                case .text(let s): Text("📝 " + s)
                case .audio(let url, let dur): Text("🎙️ Audio \(Int(dur))s → \(url.lastPathComponent)")
                case .video(let url, let dur): Text("📹 Video \(Int(dur))s → \(url.lastPathComponent)")
                case .drawing: Text("✏️ Drawing attached")
                }
            }
        }
    }
}

struct YouTubeThumbnailView: View {
    var videoID: String
    var body: some View {
        AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(.secondary.opacity(0.2))
        }
    }
}

enum YouTubeIDParser {
    static func videoID(from url: String) -> String? {
        if let u = URL(string: url), let host = u.host, host.contains("youtu") {
            if host.contains("youtu.be") { return u.lastPathComponent }
            let comps = URLComponents(url: u, resolvingAgainstBaseURL: false)
            return comps?.queryItems?.first(where: { $0.name == "v" })?.value
        }
        return nil
    }
}
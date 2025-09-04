import SwiftUI

struct RecordNotesFromYouTube: View {
    @EnvironmentObject var store: AppStore
    @State private var urlString: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    @State private var videoTitle: String = "The Changing Earth"
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Input row
            HStack {
                TextField("YouTube URL", text: $urlString).textFieldStyle(.roundedBorder)
                Button("Add Clip") {
                    let id = YouTubeIDParser.videoID(from: urlString) ?? "dQw4w9WgXcQ"
                    let clip = YouTubeClip(
                        videoID: id,
                        title: videoTitle,
                        start: 30,
                        end: 75,
                        transcript: "Sample transcript for the selected range.",
                        notes: [.text("Key points on plate tect…"), .audio(url: URL(fileURLWithPath: "/tmp/audio.m4a"), duration: 13), .drawing(image: UIImageOrNSImage())]
                    )
                    store.clips.append(clip)
                }.buttonStyle(.borderedProminent)
            }

            // Headings row
            HStack {
                Text("Clip").font(.headline)
                Spacer()
                Text("Transcript").font(.headline)
                Spacer()
                Text("My Notes").font(.headline)
            }
            .overlay(Divider(), alignment: .bottom)

            // Rows
            ForEach(store.clips) { clip in
                HStack(alignment: .top, spacing: 16) {
                    // Column 1: Clip
                    HStack(alignment: .top, spacing: 12) {
                        YouTubeThumbnailView(videoID: clip.videoID)
                            .frame(width: 120, height: 68)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(clip.title).font(.title3.weight(.semibold))
                            Text(timeRange(clip)).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .frame(minWidth: 260, alignment: .leading)

                    // Column 2: Transcript
                    Text(clip.transcript)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Column 3: Notes
                    VStack(alignment: .leading, spacing: 8) {
                        NotesListView(clip: clip)
                    }
                    .frame(minWidth: 260, alignment: .leading)
                }
                .padding(.vertical, 8)
                .overlay(Divider(), alignment: .bottom)
            }
        }
        .padding()
        .navigationTitle("Record Notes")
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
            ForEach(Array(clip.notes.enumerated()), id: \.offset) { _, note in
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

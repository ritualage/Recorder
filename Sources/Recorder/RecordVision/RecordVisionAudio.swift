import SwiftUI
import AVFoundation

struct RecordVisionAudio: View {
    @StateObject private var audio = AudioRecorder()
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Record Vision", leftMenuTitle: "Mic", rightMenuTitle: "Monitor Off")
            Card { WaveformPlaceholder().frame(minHeight: 220) }
            HStack {
                Button(audio.isRecording ? "Stop" : "Record") { audio.toggle() }
                    .buttonStyle(.borderedProminent)
                if let url = audio.lastFile { Text("Saved: \(url.lastPathComponent)").font(.footnote) }
                Spacer()
            }
            TransportBar(position: $pos, timeString: "00:00", showLevel: true)
        }
        .padding()
        .navigationTitle("Record Vision Audio")
    }
}

final class AudioRecorder: NSObject, ObservableObject {
    private var recorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var lastFile: URL?
    func toggle() {
        if isRecording { stop() } else { start() }
    }
    private func start() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audio-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2
        ]
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            isRecording = true
        } catch { print(error) }
    }
    private func stop() {
        recorder?.stop()
        lastFile = recorder?.url
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

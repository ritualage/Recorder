import SwiftUI
import AVFoundation

struct RecordVisionVideo: View {
    @StateObject private var movie = MovieRecorder()
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Record Vision", leftMenuTitle: "Camera", rightMenuTitle: "Mic")
            Card { PlayCardPlaceholder() }
                .frame(minHeight: 260)
            HStack {
                Button(movie.isRecording ? "Stop" : "Record") { movie.toggle() }
                    .buttonStyle(.borderedProminent)
                if let url = movie.lastFile { Text("Saved: \(url.lastPathComponent)").font(.footnote) }
                Spacer()
            }
            TransportBar(position: $pos, timeString: "00:00", showLevel: true)
        }
        .padding()
        .task { await movie.configure() }
        .navigationTitle("Record Vision Video")
    }
}

final class MovieRecorder: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    let session = AVCaptureSession()
    private let output = AVCaptureMovieFileOutput()
    @Published var isRecording = false
    @Published var lastFile: URL?
    func configure() async {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()
        session.startRunning()
    }
    func toggle() {
        if isRecording {
            output.stopRecording()
        } else {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("movie-\(UUID().uuidString).mov")
            output.startRecording(to: url, recordingDelegate: self)
        }
        isRecording.toggle()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        lastFile = outputFileURL
        isRecording = false
    }
}

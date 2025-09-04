import SwiftUI

struct RecordScreenView: View {
    @State private var isRecording = false
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Camera", leftMenuTitle: "Camera", rightMenuTitle: "No Microphone")
            Card {
                ZStack {
                    Rectangle().fill(.black.opacity(0.75))
                    Text("Screen preview placeholder")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(minHeight: 320)
            HStack {
                Button(isRecording ? "Stop" : "Start") { isRecording.toggle() }
                    .buttonStyle(.borderedProminent)
                Text(isRecording ? "Recording…" : "Idle").foregroundStyle(isRecording ? .red : .secondary)
                Spacer()
            }
            TransportBar(position: $pos, timeString: "0:00", showLevel: true)
        }
        .padding()
        .navigationTitle("Record Screen")
    }
}

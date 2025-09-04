import SwiftUI

struct RecordScreenView: View {
    @State private var isRecording = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Screen capture prototype")
                .font(.headline)
            Rectangle().fill(.secondary.opacity(0.2))
                .overlay(Text("Live screen preview not implemented in this demo"))
                .frame(minHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                Button(isRecording ? "Stop" : "Start") { isRecording.toggle() }
                    .buttonStyle(.borderedProminent)
                Text(isRecording ? "Recording…" : "Idle")
                    .foregroundStyle(isRecording ? .red : .secondary)
            }
        }
        .padding()
        .navigationTitle("Record Screen")
    }
}
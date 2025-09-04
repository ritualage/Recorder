import SwiftUI

struct RecordPromptView: View {
    @EnvironmentObject var store: AppStore
    @State private var current = PromptRecord(text: "Generate a chart showing carbon emissions by country", webcamClip: nil, audioClip: nil, drawing: nil, attachment: nil, pinnedModel: nil, otherRuns: [])
    @State private var generatedPinned = ModelRun(modelName: "GPT-5 Vision-Audio", summary: "A bar chart displaying carbon emissions by country, using audio + sketch + attachment.", pinned: true)
    @State private var otherRun = ModelRun(modelName: "Other Vision Model", summary: "Similar chart proposal with slightly different labels.", pinned: false)
    @State private var showDeleteConfirm = false
    var body: some View {
        HStack(spacing: 16) {
            // Left column: Inputs
            VStack(alignment: .leading, spacing: 12) {
                Text("Prompt Inputs").font(.headline)
                TextEditor(text: $current.text).frame(height: 80).overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(.tertiary))
                InputRow(icon: "person.crop.square", title: "Webcam clip")
                InputRow(icon: "mic", title: "Mic audio")
                InputRow(icon: "pencil.and.outline", title: "Tablet drawing")
                InputRow(icon: "doc", title: "attachment.zip")
                Spacer()
            }
            .frame(minWidth: 320)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            // Middle: Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("Summary").font(.headline)
                Text("A bar chart displaying carbon emissions by country, using data from the included audio description, hand‑drawn sketch, and document.")
                Spacer()
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            // Right: Model & Response
            VStack(alignment: .leading, spacing: 12) {
                Text("Model & Response").font(.headline)
                HStack {
                    Label("GPT-5 Vision-Audio", systemImage: "pin.fill")
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    Button("Unpin") { showDeleteConfirm = true }
                        .buttonStyle(.borderless)
                }
                Text("Summary (Pinned)")
                    .font(.subheadline).bold()
                Text(generatedPinned.summary)
                    .padding(8).background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                Divider().padding(.vertical, 4)
                Text("Other runs").font(.subheadline).bold()
                HStack {
                    Menu(otherRun.modelName) { Text("Switch model placeholder") }
                    Spacer()
                    Button("Pin") { generatedPinned = otherRun; otherRun.pinned = false }
                }
                Text("Summary (Unpinned)")
                    .font(.subheadline).bold()
                Text(otherRun.summary)
                    .padding(8).background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .navigationTitle("Record Prompt")
        .alert("Are you sure you want to delete this model response?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { generatedPinned.pinned = false }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct InputRow: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).frame(width: 24)
            Text(title)
            Spacer()
        }
        .padding(10)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }
}
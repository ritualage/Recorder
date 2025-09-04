import SwiftUI

struct RecordDrawing: View {
    #if os(iOS)
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Record Drawing")
            Card { PencilKitCanvasView() }.frame(minHeight: 300)
            TransportBar(position: $pos, timeString: "0:00")
        }
        .padding()
        .navigationTitle("Record Drawing")
    }
    #else
    @State private var points: [CGPoint] = []
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Record Drawing")
            Card {
                Canvas { ctx, size in
                    var path = Path()
                    if let first = points.first {
                        path.move(to: first)
                        for p in points.dropFirst() { path.addLine(to: p) }
                    }
                    ctx.stroke(path, with: .color(.primary), lineWidth: 3)
                }
                .gesture(DragGesture(minimumDistance: 0).onChanged { points.append($0.location) })
            }
            .frame(minHeight: 300)
            TransportBar(position: $pos, timeString: "0:00")
        }
        .padding()
        .navigationTitle("Record Drawing")
    }
    #endif
}

#if os(iOS)
import PencilKit
struct PencilKitCanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.tool = PKInkingTool(.pen, color: .label, width: 4)
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}
#endif

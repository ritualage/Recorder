import SwiftUI

struct RecordDrawing: View {
    #if os(iOS)
    var body: some View { PencilKitCanvasView().navigationTitle("Record Drawing") }
    #else
    @State private var points: [CGPoint] = []
    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            if let first = points.first {
                path.move(to: first)
                for p in points.dropFirst() { path.addLine(to: p) }
            }
            ctx.stroke(path, with: .color(.primary), lineWidth: 2)
        }
        .gesture(DragGesture(minimumDistance: 0).onChanged { points.append($0.location) })
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
import SwiftUI
import AVFoundation

struct RecordWebcam: View {
    @StateObject private var camera = CameraController()
    var body: some View {
        VStack(spacing: 12) {
            CameraPreview(session: camera.session)
                .frame(minHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            HStack {
                Button(camera.isRunning ? "Stop" : "Start") {
                    camera.toggleSession()
                }.buttonStyle(.borderedProminent)
                Button("Capture") { camera.captureSnapshot() }
            }
        }
        .padding()
        .task { await camera.configure() }
        .navigationTitle("Record Webcam")
    }
}

final class CameraController: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var isRunning = false
    private var photoOutput = AVCapturePhotoOutput()
    func configure() async {
        session.beginConfiguration()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ??
                AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        } catch { print(error) }
        session.commitConfiguration()
    }
    func toggleSession() {
        if isRunning { session.stopRunning() } else { session.startRunning() }
        isRunning.toggle()
    }
    func captureSnapshot() { /* left as an exercise; saves a still photo */ }
}

#if os(iOS)
import UIKit
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer)?.frame = uiView.bounds
    }
}
#else
import AppKit
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.wantsLayer = true
        view.layer?.addSublayer(layer)
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer)?.frame = nsView.bounds
    }
}
#endif
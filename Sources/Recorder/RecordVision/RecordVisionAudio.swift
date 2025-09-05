import SwiftUI
import AVFoundation
import Accelerate
#if os(macOS)
import CoreAudio
#endif

struct RecordVisionAudio: View {
    @StateObject private var audio = AudioRecorder()
    @State private var pos: Double = 0
    var body: some View {
        VStack(spacing: 16) {
            RecordingHeader(leadingLabel: "Record Vision", leftMenuTitle: "Mic", rightMenuTitle: "Monitor Off")
            // Device picker + monitoring indicator
            HStack {
                Picker("Input", selection: $audio.selectedDeviceID) {
                    ForEach(audio.devices) { dev in
                        Text(dev.name).tag(Optional(dev.id))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: audio.selectedDeviceID) { id in
                    if let id { audio.selectDevice(id: id) }
                }
                Spacer()
                Text("Monitor: On").foregroundStyle(.secondary)
            }
            Card { WaveformPlaceholder().frame(minHeight: 220) }
            HStack {
                Button(audio.isRecording ? "Stop" : "Record") { audio.toggle() }
                    .buttonStyle(.borderedProminent)
                if let url = audio.lastFile { Text("Saved: \(url.lastPathComponent)").font(.footnote) }
                Spacer()
            }
            TransportBar(position: $pos, timeString: "00:00", showLevel: true, meterLevel: audio.meterLevel)
        }
        .padding()
        .navigationTitle("Record Vision Audio")
    }
}

struct AudioInputDevice: Identifiable, Hashable { let id: String; let name: String }

final class AudioRecorder: NSObject, ObservableObject {
    // UI state
    @Published var isRecording = false
    @Published var lastFile: URL?
    @Published var meterLevel: Double = -60 // dBFS
    @Published var devices: [AudioInputDevice] = []
    @Published var selectedDeviceID: String?

    // Engine + recording
    private let engine = AVAudioEngine()
    private var audioFile: AVAudioFile?

    override init() {
        super.init()
        refreshDevices()
        startEngine()
    }

    func toggle() {
        if isRecording { stopRecording() } else { startRecording() }
    }

    private func startEngine() {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            #endif
            try engine.start()
        } catch {
            print("Audio engine start error:", error)
        }
    }

    private func process(buffer: AVAudioPCMBuffer) {
        // Metering
        guard let channelData = buffer.floatChannelData?.pointee else { return }
        let frameCount = Int(buffer.frameLength)
        if frameCount > 0 {
            var rms: Float = 0
            vDSP_measqv(channelData, 1, &rms, vDSP_Length(frameCount))
            var avg = sqrtf(rms)
            let clamped = max(avg, 0.000_000_01)
            let db = 20 * log10f(clamped)
            DispatchQueue.main.async { self.meterLevel = Double(max(-60, db)) }
        }
        // Recording
        if let file = audioFile {
            do { try file.write(from: buffer) } catch { print("write error", error) }
        }
    }

    private func startRecording() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("audio-\(UUID().uuidString).m4a")
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        do {
            audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            isRecording = true
        } catch { print("startRecording error:", error) }
    }

    private func stopRecording() {
        isRecording = false
        lastFile = audioFile?.url
        audioFile = nil
    }

    func refreshDevices() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs ?? []
        devices = inputs.map { AudioInputDevice(id: $0.uid, name: $0.portName) }
        selectedDeviceID = session.preferredInput?.uid ?? session.currentRoute.inputs.first?.uid ?? devices.first?.id
        #else
        devices = MacAudioDeviceManager.inputDevices()
        selectedDeviceID = devices.first?.id
        #endif
    }

    func selectDevice(id: String) {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        if let port = (session.availableInputs ?? []).first(where: { $0.uid == id }) {
            do { try session.setPreferredInput(port) } catch { print("setPreferredInput error", error) }
        }
        #else
        MacAudioDeviceManager.setDefaultInputDevice(id)
        // Restart engine to pick up new default device
        engine.stop(); startEngine()
        #endif
    }
}

#if os(macOS)
enum MacAudioDeviceManager {
    static func inputDevices() -> [AudioInputDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize)
        guard status == noErr else { return [] }
        let count = Int(dataSize) / MemoryLayout<AudioObjectID>.size
        var deviceIDs = [AudioObjectID](repeating: 0, count: count)
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceIDs)
        guard status == noErr else { return [] }
        var results: [AudioInputDevice] = []
        for dev in deviceIDs {
            // Check if device has input streams
            var streamConfigAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreamConfiguration,
                mScope: kAudioDevicePropertyScopeInput,
                mElement: kAudioObjectPropertyElementMain
            )
            var propSize: UInt32 = 0
            if AudioObjectGetPropertyDataSize(dev, &streamConfigAddress, 0, nil, &propSize) != noErr { continue }
            let bufferListPtr = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: 1)
            defer { bufferListPtr.deallocate() }
            if AudioObjectGetPropertyData(dev, &streamConfigAddress, 0, nil, &propSize, bufferListPtr) != noErr { continue }
            let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPtr)
            let channels = bufferList.reduce(0) { $0 + Int($1.mNumberChannels) }
            if channels <= 0 { continue }

            // Name
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioObjectPropertyName,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            var name: CFString = "Unknown" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            AudioObjectGetPropertyData(dev, &nameAddress, 0, nil, &nameSize, &name)

            // UID
            var uidAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceUID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            var uid: CFString = "\(dev)" as CFString
            var uidSize = UInt32(MemoryLayout<CFString>.size)
            AudioObjectGetPropertyData(dev, &uidAddress, 0, nil, &uidSize, &uid)

            results.append(AudioInputDevice(id: uid as String, name: name as String))
        }
        return results
    }

    static func setDefaultInputDevice(_ uid: String) {
        // Find device by UID
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize) == noErr else { return }
        let count = Int(dataSize) / MemoryLayout<AudioObjectID>.size
        var deviceIDs = [AudioObjectID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceIDs) == noErr else { return }
        var match: AudioObjectID?
        for dev in deviceIDs {
            var uidAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceUID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            var cf: CFString = "" as CFString
            var size = UInt32(MemoryLayout<CFString>.size)
            if AudioObjectGetPropertyData(dev, &uidAddress, 0, nil, &size, &cf) == noErr, (cf as String) == uid {
                match = dev; break
            }
        }
        guard var deviceID = match else { return }
        var setAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &setAddress, 0, nil, UInt32(MemoryLayout<AudioObjectID>.size), &deviceID)
        if status != noErr { print("Failed to set default input device: \(status)") }
    }
}
#endif

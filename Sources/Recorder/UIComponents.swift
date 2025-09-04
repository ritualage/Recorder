import SwiftUI

// MARK: - Common UI building blocks to mirror design mocks

struct RecordingHeader: View {
    var leadingLabel: String
    var leftMenuTitle: String? = nil
    var rightMenuTitle: String? = nil
    var body: some View {
        HStack(spacing: 12) {
            Label(leadingLabel, systemImage: "record.circle.fill")
                .labelStyle(.titleAndIcon)
                .foregroundStyle(.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

            if let left = leftMenuTitle {
                MenuLabel(title: left)
            }
            if let right = rightMenuTitle {
                MenuLabel(title: right)
            }
            Spacer()
        }
    }
}

struct MenuLabel: View {
    var title: String
    var body: some View {
        Menu {
            Button("Default") {}
            Button("Built‑in Microphone") {}
            Button("External Device") {}
        } label: {
            HStack(spacing: 6) {
                Text(title)
                Image(systemName: "chevron.down")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(.secondary.opacity(0.08))
            .overlay(content.clipShape(RoundedRectangle(cornerRadius: 12)))
    }
}

struct TransportBar: View {
    @Binding var position: Double
    var timeString: String
    var showLevel: Bool = false
    @State private var level: Double = 0
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Text(timeString).monospacedDigit()
                Slider(value: $position, in: 0...1)
                if showLevel {
                    LevelMeter(level: level)
                        .frame(width: 40)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

            if showLevel {
                Slider(value: $level, in: -60...6)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct LevelMeter: View {
    var level: Double // dBFS
    var body: some View {
        GeometryReader { proxy in
            let h = proxy.size.height
            let ratio = max(0, min(1, (level + 60) / 66))
            VStack {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 2).fill(.green)
                    .frame(height: h * CGFloat(ratio))
            }
        }
    }
}

struct WaveformPlaceholder: View {
    var body: some View {
        Canvas { ctx, size in
            let barCount = Int(size.width / 6)
            let midY = size.height / 2
            for i in 0..<barCount {
                let x = CGFloat(i) * 6 + 2
                let amp = (sin(CGFloat(i) * 0.23) + 1) * 0.5
                let height = max(6, amp * (size.height * 0.8))
                let rect = CGRect(x: x, y: midY - height/2, width: 2, height: height)
                ctx.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(.secondary))
            }
        }
        .background(Color.black.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PlayCardPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.85))
            Image(systemName: "play.circle.fill")
                .resizable().scaledToFit().frame(width: 56, height: 56)
                .foregroundStyle(.white)
        }
    }
}


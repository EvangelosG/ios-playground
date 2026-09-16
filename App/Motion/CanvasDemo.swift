import SwiftUI

/// Immediate-mode drawing with `Canvas`, driven by `TimelineView` so the frame
/// is a pure function of the current date — no animation state to keep in sync.
struct CanvasDemo: View {
    @State private var isRunning = true
    @State private var particleCount: Double = 90

    var body: some View {
        DemoCard("Canvas + TimelineView", caption: "One draw call per frame instead of one view per particle.") {
            VStack(spacing: 12) {
                TimelineView(.animation(paused: !isRunning)) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    Canvas { context, size in
                        context.addFilter(.blur(radius: 0.4))
                        for index in 0..<Int(particleCount) {
                            let progress = Double(index) / particleCount
                            let angle = progress * .pi * 2 + time * 0.6
                            let radius = (0.18 + 0.3 * sin(time * 0.9 + progress * .pi * 4)) * size.height
                            let point = CGPoint(
                                x: size.width / 2 + cos(angle) * radius,
                                y: size.height / 2 + sin(angle) * radius
                            )
                            let dotSize = 3 + 4 * abs(sin(time + progress * .pi * 2))
                            let rect = CGRect(x: point.x, y: point.y, width: dotSize, height: dotSize)
                            context.fill(
                                Path(ellipseIn: rect),
                                with: .color(Color(hue: progress, saturation: 0.75, brightness: 0.95))
                            )
                        }
                    }
                    .frame(height: 260)
                    .background(.black.opacity(0.85), in: .rect(cornerRadius: 20))
                }

                Toggle("Animate", isOn: $isRunning)
                HStack {
                    Text("Particles")
                    Slider(value: $particleCount, in: 20...240, step: 10)
                    Text("\(Int(particleCount))").monospacedDigit()
                }
                .font(.callout)
            }
        }

        TryItNote("Pause the timeline and drag the slider — the same frame redraws with more particles.")
    }
}

#Preview {
    ScrollView { VStack { CanvasDemo() }.padding() }
}

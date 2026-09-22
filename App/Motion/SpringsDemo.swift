import SwiftUI

struct SpringsDemo: View {
    @State private var moved = false
    @State private var bounce = 0.4
    @State private var duration = 0.5

    private var spring: Animation {
        .spring(duration: duration, bounce: bounce)
    }

    var body: some View {
        DemoCard("Tune a spring", caption: "Bounce controls overshoot; duration controls how quickly it settles.") {
            GeometryReader { proxy in
                Circle()
                    .fill(.tint)
                    .frame(width: 56, height: 56)
                    .offset(x: moved ? proxy.size.width - 56 : 0)
                    .animation(spring, value: moved)
            }
            .frame(height: 56)

            LabeledContent("Bounce") {
                Slider(value: $bounce, in: 0...0.8)
            }
            LabeledContent("Duration") {
                Slider(value: $duration, in: 0.2...1.5)
            }
            Button(moved ? "Send back" : "Send across") { moved.toggle() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("springToggle")
        }

        DemoCard("withAnimation", caption: "Animates everything caused by one state change.") {
            ExplicitAnimationSample()
        }
    }
}

private struct ExplicitAnimationSample: View {
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: expanded ? 32 : 8)
                .fill(expanded ? AnyShapeStyle(.orange.gradient) : AnyShapeStyle(.blue.gradient))
                .frame(width: expanded ? 200 : 88, height: 88)
                .overlay(Text(expanded ? "Expanded" : "Tap").foregroundStyle(.white))
            Button("Toggle") {
                withAnimation(.snappy) { expanded.toggle() }
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { SpringsDemo() }.padding() }
}

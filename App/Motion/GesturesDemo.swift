import SwiftUI

/// Drag, magnify, rotate and long press — including how gestures are combined
/// and how gesture state is reset automatically with `@GestureState`.
struct GesturesDemo: View {
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @State private var rotation: Angle = .zero
    @GestureState private var isPressing = false
    @State private var pressCount = 0

    var body: some View {
        DemoCard("Drag, pinch, rotate", caption: "Three gestures composed simultaneously on one view.") {
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.accentColor.gradient)
                    .frame(width: 160, height: 160)
                    .overlay {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(scale)
                    .rotationEffect(rotation)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { offset = $0.translation }
                            .simultaneously(with: MagnifyGesture().onChanged { scale = max(0.4, $0.magnification) })
                            .simultaneously(with: RotateGesture().onChanged { rotation = $0.rotation })
                    )
                    .frame(maxWidth: .infinity)

                Button("Reset") {
                    withAnimation(.spring) {
                        offset = .zero
                        scale = 1
                        rotation = .zero
                    }
                }
                Text(String(format: "offset %.0f, %.0f · scale %.2f · %.0f°", offset.width, offset.height, scale, rotation.degrees))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }

        DemoCard("@GestureState", caption: "Transient state that snaps back the instant the finger lifts.") {
            VStack(spacing: 10) {
                Circle()
                    .fill(isPressing ? Color.green : Color.secondary)
                    .frame(width: 84, height: 84)
                    .scaleEffect(isPressing ? 1.15 : 1)
                    .animation(.bouncy, value: isPressing)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .updating($isPressing) { value, state, _ in state = value }
                            .onEnded { _ in pressCount += 1 }
                    )
                Text(isPressing ? "Holding…" : "Press and hold (\(pressCount) completed)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }

        TryItNote("On the Simulator, hold ⌥ (Option) and drag to pinch or rotate with two pointers.")
    }
}

#Preview {
    ScrollView { VStack { GesturesDemo() }.padding() }
}

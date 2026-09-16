import SwiftUI

/// Insertion/removal transitions plus the two multi-step animation drivers:
/// `phaseAnimator` for discrete states and `keyframeAnimator` for timelines.
struct TransitionsDemo: View {
    private enum Pulse: CaseIterable {
        case rest, grow, settle

        var scale: CGFloat {
            switch self {
            case .rest: 1
            case .grow: 1.35
            case .settle: 0.92
            }
        }

        var hue: Color {
            switch self {
            case .rest: .blue
            case .grow: .pink
            case .settle: .purple
            }
        }
    }

    private struct BounceValues {
        var yOffset: CGFloat = 0
        var scale: CGFloat = 1
        var angle: Angle = .zero
    }

    @State private var showBadge = false
    @State private var transitionIndex = 0
    @State private var bounceTrigger = 0

    private let transitions: [(name: String, transition: AnyTransition)] = [
        ("slide", .slide),
        ("scale + opacity", .scale.combined(with: .opacity)),
        ("push from bottom", .push(from: .bottom)),
        ("asymmetric", .asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
    ]

    var body: some View {
        DemoCard("Transitions", caption: "How a view enters and leaves the hierarchy.") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Transition", selection: $transitionIndex) {
                    ForEach(transitions.indices, id: \.self) { index in
                        Text(transitions[index].name).tag(index)
                    }
                }
                .pickerStyle(.menu)

                Button(showBadge ? "Remove" : "Insert") {
                    withAnimation(.smooth(duration: 0.45)) { showBadge.toggle() }
                }
                .buttonStyle(.borderedProminent)

                ZStack {
                    if showBadge {
                        Label("New message", systemImage: "envelope.badge.fill")
                            .padding()
                            .background(.tint.opacity(0.18), in: .rect(cornerRadius: 14))
                            .transition(transitions[transitionIndex].transition)
                    }
                }
                .frame(height: 70, alignment: .leading)
            }
        }

        DemoCard("phaseAnimator", caption: "Cycles through discrete phases; SwiftUI animates between them.") {
            Image(systemName: "heart.fill")
                .font(.system(size: 52))
                .phaseAnimator(Pulse.allCases) { view, phase in
                    view
                        .scaleEffect(phase.scale)
                        .foregroundStyle(phase.hue)
                } animation: { _ in .spring(duration: 0.6, bounce: 0.4) }
                .frame(maxWidth: .infinity)
        }

        DemoCard("keyframeAnimator", caption: "Independent tracks per property — the tool for choreographed motion.") {
            VStack(spacing: 10) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(.orange)
                    .keyframeAnimator(initialValue: BounceValues(), trigger: bounceTrigger) { view, value in
                        view
                            .offset(y: value.yOffset)
                            .scaleEffect(value.scale)
                            .rotationEffect(value.angle)
                    } keyframes: { _ in
                        KeyframeTrack(\.yOffset) {
                            SpringKeyframe(-42, duration: 0.3, spring: .bouncy)
                            SpringKeyframe(0, duration: 0.45, spring: .bouncy)
                        }
                        KeyframeTrack(\.scale) {
                            CubicKeyframe(1.25, duration: 0.25)
                            CubicKeyframe(0.9, duration: 0.25)
                            CubicKeyframe(1, duration: 0.25)
                        }
                        KeyframeTrack(\.angle) {
                            CubicKeyframe(.degrees(-18), duration: 0.2)
                            CubicKeyframe(.degrees(14), duration: 0.2)
                            CubicKeyframe(.zero, duration: 0.3)
                        }
                    }
                Button("Ring") { bounceTrigger += 1 }
                    .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
        }

        TryItNote("Switch the transition, then insert and remove the badge to compare them.")
    }
}

#Preview {
    ScrollView { VStack { TransitionsDemo() }.padding() }
}

import SwiftUI

@MainActor
enum MotionTab {
    static let tab = DemoTab(
        id: "motion",
        title: "Motion",
        symbol: "wand.and.sparkles",
        blurb: "Animation, gestures, transitions and scroll effects — the things that make an app feel native.",
        sections: [
            DemoSection(id: "motion.animation", title: "Animation", demos: [
                Demo(
                    id: "motion.springs",
                    title: "Springs & implicit animation",
                    summary: "The difference between animating a value and animating a change.",
                    symbol: "waveform.path",
                    notes: DemoNotes(
                        explanation: """
                        iOS animation is physics, not duration curves: a spring is described by how \
                        bouncy it is and how long it takes to settle. `.animation(_:value:)` animates \
                        whenever that value changes, while `withAnimation` animates whatever a specific \
                        state mutation causes.
                        """,
                        code: """
                        Circle()
                            .offset(x: moved ? 120 : 0)
                            .animation(.spring(duration: 0.5, bounce: 0.4), value: moved)

                        withAnimation(.snappy) { moved.toggle() }
                        """,
                        apis: ["Animation.spring", "withAnimation", "animation(_:value:)"]
                    ),
                    content: { SpringsDemo() }
                )
            ])
        ]
    )
}

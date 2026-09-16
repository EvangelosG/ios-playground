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
                ),
                Demo(
                    id: "motion.transitions",
                    title: "Transitions & keyframes",
                    summary: "Insertion/removal transitions, phaseAnimator and keyframeAnimator.",
                    symbol: "rectangle.on.rectangle.angled",
                    notes: DemoNotes(
                        explanation: """
                        A transition describes how a view enters or leaves the hierarchy, and it only \
                        runs if the change is inside `withAnimation`. For motion with more than two \
                        states there are two drivers: `phaseAnimator` walks a sequence of discrete \
                        phases, and `keyframeAnimator` runs independent tracks per property so scale, \
                        offset and rotation can follow different timings in one choreographed move.
                        """,
                        code: """
                        Badge()
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))

                        Image(systemName: "heart.fill")
                            .phaseAnimator(Pulse.allCases) { view, phase in
                                view.scaleEffect(phase.scale)
                            }

                        .keyframeAnimator(initialValue: BounceValues(), trigger: count) { view, value in
                            view.offset(y: value.yOffset).scaleEffect(value.scale)
                        } keyframes: { _ in
                            KeyframeTrack(\\.yOffset) { SpringKeyframe(-42, duration: 0.3, spring: .bouncy) }
                        }
                        """,
                        apis: ["transition", "phaseAnimator", "keyframeAnimator", "KeyframeTrack"]
                    ),
                    content: { TransitionsDemo() }
                ),
                Demo(
                    id: "motion.matchedgeometry",
                    title: "Hero transition",
                    summary: "matchedGeometryEffect moving one element between two layouts.",
                    symbol: "arrow.up.left.and.arrow.down.right",
                    notes: DemoNotes(
                        explanation: """
                        Give two views in different layouts the same `matchedGeometryEffect` id inside a \
                        shared `@Namespace` and SwiftUI treats them as the same element: when one is \
                        replaced by the other it interpolates position, size and corner radius instead \
                        of cross-fading. This is how grid-to-detail "hero" animations are built.
                        """,
                        code: """
                        @Namespace private var namespace

                        RoundedRectangle(cornerRadius: 16)
                            .matchedGeometryEffect(id: card.id, in: namespace)

                        withAnimation(.spring(duration: 0.45, bounce: 0.25)) { selected = card.id }
                        """,
                        apis: ["@Namespace", "matchedGeometryEffect", "withAnimation"]
                    ),
                    content: { MatchedGeometryDemo() }
                )
            ]),
            DemoSection(id: "motion.input", title: "Input & scrolling", demos: [
                Demo(
                    id: "motion.gestures",
                    title: "Gestures",
                    summary: "Drag, magnify, rotate, long press — and how they compose.",
                    symbol: "hand.draw",
                    notes: DemoNotes(
                        explanation: """
                        Gestures are values you attach with `.gesture`, and they compose: `simultaneously` \
                        runs several at once, `sequenced` chains them, `exclusively` picks the first to \
                        win. State written with `@GestureState` is automatically reset when the gesture \
                        ends, which is what makes press highlights impossible to leave stuck on.
                        """,
                        code: """
                        @GestureState private var isPressing = false

                        shape.gesture(
                            DragGesture().onChanged { offset = $0.translation }
                                .simultaneously(with: MagnifyGesture().onChanged { scale = $0.magnification })
                        )

                        LongPressGesture().updating($isPressing) { value, state, _ in state = value }
                        """,
                        apis: ["DragGesture", "MagnifyGesture", "RotateGesture", "@GestureState", "simultaneously"]
                    ),
                    content: { GesturesDemo() }
                ),
                Demo(
                    id: "motion.scroll",
                    title: "Scroll effects",
                    summary: "scrollTransition, paging, scroll position and visualEffect.",
                    symbol: "scroll",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        Modern SwiftUI exposes the scroll view's geometry declaratively. \
                        `scrollTransition` gives each item a phase describing where it sits relative to \
                        the viewport, `scrollTargetBehavior(.viewAligned)` turns a stack into a pager, \
                        `scrollPosition` binds the visible item's id, and `visualEffect` lets a view read \
                        its own frame to drive effects without triggering a re-render.
                        """,
                        code: """
                        .scrollTransition { content, phase in
                            content.opacity(phase.isIdentity ? 1 : 0.4)
                                .scaleEffect(phase.isIdentity ? 1 : 0.85)
                        }
                        .scrollTargetLayout()
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $scrolledID)

                        .visualEffect { content, proxy in
                            content.opacity(fade(for: proxy.frame(in: .scrollView)))
                        }
                        """,
                        apis: ["scrollTransition", "scrollTargetBehavior", "scrollPosition", "visualEffect", "contentMargins"]
                    ),
                    content: { ScrollEffectsDemo() }
                ),
                Demo(
                    id: "motion.canvas",
                    title: "Canvas & TimelineView",
                    summary: "Immediate-mode drawing on a per-frame timeline.",
                    symbol: "sparkles",
                    notes: DemoNotes(
                        explanation: """
                        When there are hundreds of moving elements, views are the wrong tool. `Canvas` \
                        draws them imperatively in a single pass, and `TimelineView(.animation)` \
                        re-invokes the body once per display frame with the current date — so the scene \
                        is a pure function of time and there is no animation state to keep in sync.
                        """,
                        code: """
                        TimelineView(.animation(paused: !isRunning)) { timeline in
                            let time = timeline.date.timeIntervalSinceReferenceDate
                            Canvas { context, size in
                                context.fill(Path(ellipseIn: rect), with: .color(color))
                            }
                        }
                        """,
                        apis: ["Canvas", "TimelineView", "GraphicsContext", "Path"]
                    ),
                    content: { CanvasDemo() }
                )
            ])
        ]
    )
}

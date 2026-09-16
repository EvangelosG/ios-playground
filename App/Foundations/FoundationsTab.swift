import SwiftUI

@MainActor
enum FoundationsTab {
    static let tab = DemoTab(
        id: "foundations",
        title: "Foundations",
        symbol: "square.grid.2x2",
        blurb: "The building blocks of a SwiftUI screen: materials, type, layout, lists, controls, navigation and presentation.",
        sections: [
            DemoSection(id: "foundations.look", title: "Look & feel", demos: [
                Demo(
                    id: "foundations.materials",
                    title: "Materials & Liquid Glass",
                    summary: "System materials and the glass effect used across iOS.",
                    symbol: "circle.hexagongrid.fill",
                    notes: DemoNotes(
                        explanation: """
                        iOS layers translucent surfaces over content instead of flat colours. \
                        `Material` blurs what is behind it, and `glassEffect` adds the Liquid Glass \
                        treatment introduced in iOS 26, including the way adjacent glass shapes merge \
                        inside a `GlassEffectContainer`.
                        """,
                        code: """
                        GlassEffectContainer(spacing: 16) {
                            HStack(spacing: 16) {
                                Image(systemName: "play.fill")
                                    .glassEffect(.regular.tint(.blue).interactive(), in: .circle)
                            }
                        }

                        VStack { … }
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                        """,
                        apis: ["Material", "glassEffect(_:in:)", "GlassEffectContainer", "ShapeStyle"]
                    ),
                    content: { MaterialsDemo() }
                ),
                Demo(
                    id: "foundations.typography",
                    title: "Type & SF Symbols",
                    summary: "Semantic text styles, Dynamic Type, symbol effects and locale-aware formatting.",
                    symbol: "textformat",
                    notes: DemoNotes(
                        explanation: """
                        iOS text is sized semantically: you ask for `.headline`, not 17pt, so every \
                        label follows the reader's Dynamic Type setting. SF Symbols are the matching \
                        icon set — they inherit font metrics and colour, and animate with \
                        `symbolEffect`. Numbers, dates and measurements are rendered with `format:` \
                        so they localise themselves.
                        """,
                        code: """
                        Text("Aa").font(.headline)

                        Image(systemName: "bell.fill")
                            .symbolEffect(.bounce, value: tapCount)

                        Text(1234.56, format: .currency(code: "USD"))
                        """,
                        apis: ["Font", "dynamicTypeSize", "symbolEffect", "FormatStyle"]
                    ),
                    content: { TypographyDemo() }
                )
            ]),
            DemoSection(id: "foundations.structure", title: "Structure", demos: [
                Demo(
                    id: "foundations.layout",
                    title: "Layout",
                    summary: "Stacks, Grid, LazyVGrid, ViewThatFits and a custom Layout.",
                    symbol: "rectangle.3.group",
                    notes: DemoNotes(
                        explanation: """
                        SwiftUI layout is a negotiation: a parent proposes a size, each child reports \
                        what it wants, and the parent places them. `Grid` aligns cells across rows, \
                        `LazyVGrid` flows items and only builds what is visible, and `ViewThatFits` \
                        picks the first arrangement that fits. When none of those apply, the `Layout` \
                        protocol lets you do the arithmetic yourself.
                        """,
                        code: """
                        ViewThatFits(in: .horizontal) {
                            HStack { label; Spacer(); detail }   // preferred
                            VStack(alignment: .leading) { label; detail }
                        }

                        struct FlowLayout: Layout {
                            func sizeThatFits(proposal:subviews:cache:) -> CGSize
                            func placeSubviews(in:proposal:subviews:cache:)
                        }
                        """,
                        apis: ["Grid", "LazyVGrid", "ViewThatFits", "Layout"]
                    ),
                    content: { LayoutDemo() }
                ),
                Demo(
                    id: "foundations.lists",
                    title: "Lists",
                    summary: "Swipe actions, context menus, edit mode, reordering and pull-to-refresh.",
                    symbol: "list.bullet.rectangle",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        `List` is where most iOS content lives, and nearly every interaction users \
                        expect from it is a modifier rather than custom code: swipe actions on either \
                        edge, a long-press context menu, `onMove`/`onDelete` with `EditButton`, and \
                        `refreshable` for pull-to-refresh, which takes an async closure and keeps the \
                        spinner up until it returns.
                        """,
                        code: """
                        ForEach(tasks) { task in
                            row(task)
                                .swipeActions(edge: .leading) { Button("Flag", …) }
                                .contextMenu { Button("Duplicate", …) }
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)

                        .refreshable { await reload() }
                        """,
                        apis: ["List", "swipeActions", "contextMenu", "onMove", "refreshable", "EditButton"]
                    ),
                    content: { ListsDemo() }
                ),
                Demo(
                    id: "foundations.navigation",
                    title: "Navigation",
                    summary: "A typed NavigationStack path you can push, inspect and deep-link into.",
                    symbol: "arrow.forward.square",
                    notes: DemoNotes(
                        explanation: """
                        Modern navigation is state, not a sequence of push calls: the screen stack is \
                        an array of `Hashable` route values bound to a `NavigationStack`. Setting that \
                        array jumps anywhere in the app — which is how deep links, restoring state on \
                        relaunch, and "pop to root" all reduce to ordinary value edits.
                        """,
                        code: """
                        @State private var path: [Route] = []

                        NavigationStack(path: $path) { … }
                            .navigationDestination(for: Route.self) { destination(for: $0) }

                        path = [.album("Blue Train"), .track("Moment's Notice")]  // deep link
                        path.removeAll()                                          // pop to root
                        """,
                        apis: ["NavigationStack", "navigationDestination", "NavigationLink(value:)"]
                    ),
                    content: { NavigationDemo() }
                )
            ]),
            DemoSection(id: "foundations.input", title: "Input & presentation", demos: [
                Demo(
                    id: "foundations.controls",
                    title: "Controls & forms",
                    summary: "Text fields with focus and validation, pickers, toggles, sliders, buttons.",
                    symbol: "switch.2",
                    notes: DemoNotes(
                        explanation: """
                        Controls bind to state rather than reporting events, so a field and its \
                        validation stay in sync by construction. `@FocusState` moves the keyboard \
                        between fields and dismisses it, `textContentType` unlocks autofill, and \
                        picker style is a modifier — the same data can be a segmented control, a \
                        menu, or a wheel.
                        """,
                        code: """
                        @FocusState private var focus: Field?

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .focused($focus, equals: .email)
                            .submitLabel(.done)
                            .onSubmit { focus = nil }
                        """,
                        apis: ["TextField", "@FocusState", "Picker", "Toggle", "Slider", "ButtonRole"]
                    ),
                    content: { ControlsDemo() }
                ),
                Demo(
                    id: "foundations.presentation",
                    title: "Sheets, alerts & popovers",
                    summary: "Every way iOS presents something on top of the current screen.",
                    symbol: "rectangle.portrait.on.rectangle.portrait",
                    notes: DemoNotes(
                        explanation: """
                        Presentation is driven by a boolean or optional value, so the app never \
                        "presents" imperatively — it describes that something should be showing. \
                        Detents let a sheet occupy part of the screen and be dragged larger, and the \
                        presented view dismisses itself through `@Environment(\\.dismiss)` without \
                        needing the binding.
                        """,
                        code: """
                        .sheet(isPresented: $showing) {
                            Editor()
                                .presentationDetents([.height(180), .medium, .large])
                        }

                        .confirmationDialog("Delete this item?", isPresented: $confirming) {
                            Button("Delete", role: .destructive) { … }
                        }
                        """,
                        apis: ["sheet", "fullScreenCover", "popover", "alert", "confirmationDialog", "presentationDetents"]
                    ),
                    content: { PresentationDemo() }
                ),
                Demo(
                    id: "foundations.accessibility",
                    title: "Accessibility & adaptivity",
                    summary: "Environment signals, VoiceOver grouping and Reduce Motion.",
                    symbol: "accessibility",
                    notes: DemoNotes(
                        explanation: """
                        The system hands a view its context — size class, colour scheme, Dynamic Type \
                        size, Reduce Motion — through the environment, and a well-behaved screen reads \
                        those instead of assuming. For VoiceOver, the important move is usually \
                        grouping: collapse a decorative row into one element with a label, value and \
                        hint so it is announced as a sentence.
                        """,
                        code: """
                        @Environment(\\.accessibilityReduceMotion) private var reduceMotion

                        row
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Water intake")
                            .accessibilityValue("1.2 of 3 litres")

                        .animation(reduceMotion ? nil : .easeInOut, value: spin)
                        """,
                        apis: ["accessibilityElement", "accessibilityLabel", "@Environment", "DynamicTypeSize"]
                    ),
                    content: { AccessibilityDemo() }
                )
            ])
        ]
    )
}

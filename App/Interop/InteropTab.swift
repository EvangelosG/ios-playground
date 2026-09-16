import SwiftUI

@MainActor
enum InteropTab {
    static let tab = DemoTab(
        id: "interop",
        title: "Interop",
        symbol: "arrow.left.arrow.right.square",
        blurb: "Most real apps are a mix. These screens cross the SwiftUI ↔ UIKit boundary in both directions.",
        sections: [
            DemoSection(id: "interop.uikit", title: "UIKit inside SwiftUI", demos: [
                Demo(
                    id: "interop.uiviewrepresentable",
                    title: "UIViewRepresentable",
                    summary: "Wrap a UIKit view and drive it from SwiftUI state.",
                    symbol: "rectangle.on.rectangle",
                    notes: DemoNotes(
                        explanation: """
                        `UIViewRepresentable` has three jobs: make the UIKit view once, push SwiftUI \
                        state into it on every update, and route its callbacks back out. The callbacks \
                        go through a `Coordinator`, which is the object UIKit holds as target or delegate.
                        """,
                        code: """
                        struct PageControl: UIViewRepresentable {
                            @Binding var page: Int

                            func makeUIView(context: Context) -> UIPageControl { … }
                            func updateUIView(_ view: UIPageControl, context: Context) {
                                view.currentPage = page
                            }
                            func makeCoordinator() -> Coordinator { Coordinator($page) }
                        }
                        """,
                        apis: ["UIViewRepresentable", "Coordinator", "UIPageControl"]
                    ),
                    content: { PageControlDemo() }
                ),
                Demo(
                    id: "interop.delegate",
                    title: "Delegates & coordinators",
                    summary: "UITextView bridged in, with its delegate writing back into SwiftUI state.",
                    symbol: "text.cursor",
                    notes: DemoNotes(
                        explanation: """
                        UIKit talks back through delegates: long-lived objects that receive callbacks. \
                        SwiftUI views are structs recreated constantly, so they cannot be the delegate — \
                        the `Coordinator` can, because SwiftUI keeps exactly one of them alive for the \
                        lifetime of the representable. The coordinator holds the current representable \
                        value so callbacks can write to its bindings.
                        """,
                        code: """
                        final class Coordinator: NSObject, UITextViewDelegate {
                            var parent: RichTextView
                            func textViewDidChange(_ textView: UITextView) {
                                parent.text = textView.text      // writes the SwiftUI @Binding
                            }
                        }

                        func updateUIView(_ view: UITextView, context: Context) {
                            context.coordinator.parent = self    // keep the bindings fresh
                        }
                        """,
                        apis: ["UIViewRepresentable", "Coordinator", "UITextViewDelegate", "@Binding"]
                    ),
                    content: { TextViewDemo() }
                ),
                Demo(
                    id: "interop.collectionview",
                    title: "UIKit collection view",
                    summary: "Compositional layout and a diffable data source, hosted in SwiftUI.",
                    symbol: "square.grid.3x3",
                    layout: .plain,
                    notes: DemoNotes(
                        explanation: """
                        This is the contrast screen: everything a SwiftUI `LazyVGrid` gives you for free \
                        — layout, identity, animated inserts — spelled out in UIKit as a compositional \
                        layout plus a diffable data source. It is still the right tool for very large or \
                        highly customised collections, and `UIViewControllerRepresentable` lets a SwiftUI \
                        app keep using it.
                        """,
                        code: """
                        let registration = UICollectionView.CellRegistration<UICollectionViewCell, String> { … }
                        dataSource = UICollectionViewDiffableDataSource(collectionView: view) { view, indexPath, id in
                            view.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: id)
                        }

                        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
                        snapshot.appendSections([0])
                        snapshot.appendItems(items)
                        dataSource.apply(snapshot, animatingDifferences: true)
                        """,
                        apis: [
                            "UIViewControllerRepresentable",
                            "UICollectionViewCompositionalLayout",
                            "UICollectionViewDiffableDataSource",
                            "CellRegistration"
                        ]
                    ),
                    content: { CollectionViewDemo() }
                )
            ]),
            DemoSection(id: "interop.swiftui", title: "SwiftUI inside UIKit", demos: [
                Demo(
                    id: "interop.hosting",
                    title: "UIHostingController",
                    summary: "A UIKit screen embedding a SwiftUI view, sharing one @Observable model.",
                    symbol: "square.stack.3d.up",
                    notes: DemoNotes(
                        explanation: """
                        Adopting SwiftUI in an existing app usually goes this way round: a \
                        `UIHostingController` wraps a SwiftUI view and is added as a child view \
                        controller like any other. Both sides read and write the same `@Observable` \
                        model, so UIKit buttons and SwiftUI buttons stay in sync with no bridging code.
                        """,
                        code: """
                        let hosting = UIHostingController(rootView: TallyView(tally: tally))
                        addChild(hosting)
                        view.addSubview(hosting.view)
                        hosting.didMove(toParent: self)

                        UIAction { [tally] _ in tally.value += 1 }   // SwiftUI re-renders
                        """,
                        apis: ["UIHostingController", "addChild", "@Observable", "@Bindable"]
                    ),
                    content: { HostingControllerDemo() }
                )
            ])
        ]
    )
}

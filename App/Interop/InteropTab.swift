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
                )
            ])
        ]
    )
}

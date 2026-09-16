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
                        treatment introduced in iOS 26, including the way adjacent glass shapes merge.
                        """,
                        code: """
                        Text("Glass")
                            .padding()
                            .glassEffect(.regular, in: .capsule)

                        VStack { … }
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                        """,
                        apis: ["Material", "glassEffect(_:in:)", "GlassEffectContainer"]
                    ),
                    content: { MaterialsDemo() }
                )
            ])
        ]
    )
}

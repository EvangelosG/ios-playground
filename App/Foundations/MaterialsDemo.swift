import SwiftUI

struct MaterialsDemo: View {
    @State private var glassTint: Color = .blue

    private let materials: [(String, Material)] = [
        ("ultraThin", .ultraThinMaterial),
        ("thin", .thinMaterial),
        ("regular", .regularMaterial),
        ("thick", .thickMaterial)
    ]

    var body: some View {
        DemoCard("Liquid Glass", caption: "Glass takes its colour from whatever it floats over — drag the tint to see it react.") {
            ZStack {
                backdrop
                GlassEffectContainer(spacing: 16) {
                    HStack(spacing: 16) {
                        ForEach(["play.fill", "pause.fill", "forward.fill"], id: \.self) { symbol in
                            Image(systemName: symbol)
                                .font(.title2)
                                .frame(width: 56, height: 56)
                                .glassEffect(.regular.tint(glassTint.opacity(0.6)).interactive(), in: .circle)
                        }
                    }
                }
            }
            .frame(height: 180)
            .clipShape(.rect(cornerRadius: 16))

            Picker("Tint", selection: $glassTint) {
                Text("Blue").tag(Color.blue)
                Text("Pink").tag(Color.pink)
                Text("Mint").tag(Color.mint)
            }
            .pickerStyle(.segmented)
        }

        DemoCard("Materials", caption: "Blur levels that let content show through with legible foreground text.") {
            ZStack {
                backdrop
                VStack(spacing: 8) {
                    ForEach(materials, id: \.0) { name, material in
                        Text(".\(name)Material")
                            .font(.footnote.monospaced())
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(material, in: .rect(cornerRadius: 10))
                    }
                }
                .padding(12)
            }
            .clipShape(.rect(cornerRadius: 16))
        }

        DemoCard("Hierarchical foreground styles", caption: "One colour, four levels of emphasis.") {
            VStack(alignment: .leading, spacing: 6) {
                Text("primary").foregroundStyle(.primary)
                Text("secondary").foregroundStyle(.secondary)
                Text("tertiary").foregroundStyle(.tertiary)
                Text("quaternary").foregroundStyle(.quaternary)
            }
        }
    }

    private var backdrop: some View {
        LinearGradient(
            colors: [.orange, .pink, .purple, .indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { MaterialsDemo() }.padding() }
}

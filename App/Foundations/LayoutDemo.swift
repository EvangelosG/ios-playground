import SwiftUI

struct LayoutDemo: View {
    @State private var available: Double = 320

    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

    var body: some View {
        DemoCard("Stacks & spacers", caption: "Layout is composition: stacks propose sizes to children, children choose.") {
            HStack {
                swatch(.blue, "fixed")
                    .frame(width: 70)
                swatch(.purple, "flexible")
                    .frame(maxWidth: .infinity)
                swatch(.pink, "hugging")
            }
            .frame(height: 56)
        }

        DemoCard("Grid", caption: "Aligned rows and columns when cells must line up; LazyVGrid when they just need to flow.") {
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    Text("").gridCellUnsizedAxes([.horizontal, .vertical])
                    Text("Mon").font(.caption)
                    Text("Tue").font(.caption)
                    Text("Wed").font(.caption)
                }
                GridRow {
                    Text("AM").font(.caption)
                    cell(.mint); cell(.teal); cell(.cyan)
                }
                GridRow {
                    Text("PM").font(.caption)
                    cell(.orange); cell(.yellow); cell(.red)
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.indigo.opacity(0.2 + Double(index) * 0.08))
                        .frame(height: 56)
                        .overlay(Text("\(index + 1)").font(.caption))
                }
            }
        }

        DemoCard("ViewThatFits", caption: "Give iOS several layouts and it picks the first that fits the space.") {
            ViewThatFits(in: .horizontal) {
                HStack {
                    Label("Download", systemImage: "arrow.down.circle")
                    Spacer()
                    Text("128 MB remaining")
                }
                VStack(alignment: .leading) {
                    Label("Download", systemImage: "arrow.down.circle")
                    Text("128 MB remaining").font(.caption)
                }
            }
            .padding(10)
            .frame(width: available)
            .background(.background.tertiary, in: .rect(cornerRadius: 10))

            LabeledContent("Available width") {
                Slider(value: $available, in: 120...340)
            }
            TryItNote("Narrow the slider until the row flips to a stacked layout.")
        }

        DemoCard("Custom Layout", caption: "The Layout protocol: the chips in every 'How it works' sheet use this.") {
            FlowChips(items: ["Layout", "sizeThatFits", "placeSubviews", "ProposedViewSize", "Subviews"])
        }
    }

    private func swatch(_ color: Color, _ label: String) -> some View {
        color.opacity(0.3)
            .overlay(Text(label).font(.caption2))
            .clipShape(.rect(cornerRadius: 8))
    }

    private func cell(_ color: Color) -> some View {
        color.opacity(0.35)
            .frame(width: 44, height: 28)
            .clipShape(.rect(cornerRadius: 6))
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { LayoutDemo() }.padding() }
}

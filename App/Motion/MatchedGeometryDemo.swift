import SwiftUI

/// A hero transition: the same logical view exists in two layouts and
/// `matchedGeometryEffect` interpolates between the two frames.
struct MatchedGeometryDemo: View {
    private struct Card: Identifiable {
        let id: String
        let symbol: String
        let color: Color
    }

    private let cards = [
        Card(id: "sun", symbol: "sun.max.fill", color: .orange),
        Card(id: "moon", symbol: "moon.stars.fill", color: .indigo),
        Card(id: "cloud", symbol: "cloud.rain.fill", color: .teal)
    ]

    @Namespace private var namespace
    @State private var selected: String?

    var body: some View {
        DemoCard("Grid ⇄ detail", caption: "Tap a card: the tile and its title fly into the detail layout.") {
            ZStack {
                if let selected, let card = cards.first(where: { $0.id == selected }) {
                    VStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(card.color.gradient)
                            .matchedGeometryEffect(id: card.id, in: namespace)
                            .frame(height: 160)
                            .overlay {
                                Image(systemName: card.symbol)
                                    .font(.system(size: 56))
                                    .foregroundStyle(.white)
                            }
                        Text(card.id.capitalized)
                            .font(.title2.bold())
                            .matchedGeometryEffect(id: "\(card.id).title", in: namespace)
                        Button("Close") { withAnimation(.spring(duration: 0.45, bounce: 0.25)) { self.selected = nil } }
                    }
                } else {
                    HStack(spacing: 12) {
                        ForEach(cards) { card in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(card.color.gradient)
                                    .matchedGeometryEffect(id: card.id, in: namespace)
                                    .frame(height: 76)
                                    .overlay {
                                        Image(systemName: card.symbol)
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                    }
                                Text(card.id.capitalized)
                                    .font(.caption)
                                    .matchedGeometryEffect(id: "\(card.id).title", in: namespace)
                            }
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.45, bounce: 0.25)) { selected = card.id }
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 200)
        }

        TryItNote("Tap a tile, then Close — nothing fades, the same rectangle moves and resizes.")
    }
}

#Preview {
    ScrollView { VStack { MatchedGeometryDemo() }.padding() }
}

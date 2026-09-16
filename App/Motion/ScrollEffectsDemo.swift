import SwiftUI

/// Scroll-driven effects: per-item `scrollTransition`, paging behaviour,
/// position tracking and a `visualEffect` that reads the item's geometry.
struct ScrollEffectsDemo: View {
    private let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal]

    @State private var scrolledID: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Paging carousel")
                .font(.headline)
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(colors.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 24)
                            .fill(colors[index].gradient)
                            .frame(width: 240, height: 160)
                            .overlay {
                                Text("Page \(index + 1)")
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                            }
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.4)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                    .rotation3DEffect(.degrees(phase.value * 18), axis: (x: 0, y: 1, z: 0))
                            }
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .contentMargins(.horizontal, 20, for: .scrollContent)

            Text(scrolledID.map { "Showing page \($0 + 1)" } ?? "Swipe the carousel")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            Divider()

            Text("visualEffect")
                .font(.headline)
                .padding(.horizontal, 20)
            Text("Each row reads its own frame and fades as it approaches the edges.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<20) { index in
                        HStack {
                            Image(systemName: "circle.hexagongrid.fill")
                                .foregroundStyle(colors[index % colors.count])
                            Text("Row \(index + 1)")
                            Spacer()
                        }
                        .padding()
                        .background(.background.secondary, in: .rect(cornerRadius: 14))
                        .visualEffect { content, proxy in
                            let midY = proxy.frame(in: .scrollView).midY
                            let height = proxy.bounds(of: .scrollView)?.height ?? 1
                            let distance = abs(midY - height / 2) / (height / 2)
                            return content
                                .opacity(1 - distance * 0.7)
                                .scaleEffect(1 - distance * 0.12)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 280)
        }
        .padding(.vertical)
    }
}

#Preview {
    NavigationStack { ScrollEffectsDemo() }
}

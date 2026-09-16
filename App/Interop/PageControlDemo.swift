import SwiftUI
import UIKit

/// A UIKit `UIPageControl` bridged into SwiftUI, with two-way state flow.
struct PageControl: UIViewRepresentable {
    let pageCount: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = pageCount
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.pageChanged(_:)),
            for: .valueChanged
        )
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        context.coordinator.currentPage = $currentPage
        uiView.numberOfPages = pageCount
        uiView.currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage)
    }

    @MainActor
    final class Coordinator: NSObject {
        var currentPage: Binding<Int>

        init(currentPage: Binding<Int>) {
            self.currentPage = currentPage
        }

        @objc func pageChanged(_ sender: UIPageControl) {
            currentPage.wrappedValue = sender.currentPage
        }
    }
}

struct PageControlDemo: View {
    @State private var page = 0

    private let colors: [Color] = [.blue, .purple, .pink, .orange]

    var body: some View {
        DemoCard("UIPageControl driving SwiftUI", caption: "Tap the dots, or swipe the pages — state flows both ways.") {
            TabView(selection: $page) {
                ForEach(colors.indices, id: \.self) { index in
                    Rectangle()
                        .fill(colors[index].gradient)
                        .overlay(Text("Page \(index + 1)").font(.title).foregroundStyle(.white))
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.horizontal, 2)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)

            PageControl(pageCount: colors.count, currentPage: $page)
                .frame(height: 24)
                .accessibilityIdentifier("pageControl")

            Text("SwiftUI state: page \(page + 1)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { PageControlDemo() }.padding() }
}

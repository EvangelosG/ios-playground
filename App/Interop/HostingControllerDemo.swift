import SwiftUI
import UIKit

/// The other direction of interop: a UIKit view controller that embeds SwiftUI
/// through `UIHostingController`, which is how existing apps adopt SwiftUI
/// screen by screen.
struct HostingControllerDemo: View {
    @State private var showing = false

    var body: some View {
        DemoCard("UIKit hosting SwiftUI", caption: "A UIViewController with a UIKit toolbar and a SwiftUI child view.") {
            VStack(alignment: .leading, spacing: 10) {
                Button("Present the UIKit screen", systemImage: "rectangle.inset.filled.and.person.filled") {
                    showing = true
                }
                .buttonStyle(.borderedProminent)
                Text("The counter inside is SwiftUI; the navigation bar and the button below it are UIKit.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showing) {
            MixedScreen()
                .ignoresSafeArea()
        }

        TryItNote("Tap the UIKit button at the bottom — it mutates state the SwiftUI view is observing.")
    }
}

@MainActor
@Observable
final class SharedTally {
    var value = 0
}

private struct MixedScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: MixedViewController())
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}
}

/// Plain UIKit: the SwiftUI view is added as a child view controller and pinned
/// with Auto Layout, exactly like any other child.
private final class MixedViewController: UIViewController {
    private let tally = SharedTally()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit container"
        view.backgroundColor = .systemBackground

        let hosting = UIHostingController(rootView: TallyView(tally: tally))
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Increment from UIKit"
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.imagePadding = 8
        let button = UIButton(configuration: configuration, primaryAction: UIAction { [tally] _ in
            tally.value += 1
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.topAnchor.constraint(equalTo: hosting.view.bottomAnchor, constant: 24),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
}

private struct TallyView: View {
    @Bindable var tally: SharedTally

    var body: some View {
        VStack(spacing: 16) {
            Text("SwiftUI view")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(tally.value)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.snappy, value: tally.value)
            Button("Increment from SwiftUI") { tally.value += 1 }
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background.secondary)
    }
}

#Preview {
    ScrollView { VStack { HostingControllerDemo() }.padding() }
}

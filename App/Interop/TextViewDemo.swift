import SwiftUI
import UIKit

/// `UITextView` has no SwiftUI equivalent for rich text attributes, so it is a
/// realistic reason to reach for `UIViewRepresentable` — and a good place to
/// show what a Coordinator is for: it is the object that adopts the UIKit
/// delegate protocol and writes back into SwiftUI state.
struct RichTextView: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var onSelectionChange: (NSRange) -> Void

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        view.isScrollEnabled = true
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        context.coordinator.parent = self
        if view.text != text {
            view.text = text
        }
        view.font = .systemFont(ofSize: fontSize)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView

        init(parent: RichTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.onSelectionChange(textView.selectedRange)
        }
    }
}

struct TextViewDemo: View {
    @State private var text = "UITextView bridged into SwiftUI.\n\nType here: the delegate reports every change and selection back through the Coordinator."
    @State private var fontSize: CGFloat = 16
    @State private var selection = NSRange(location: 0, length: 0)

    var body: some View {
        DemoCard("UIViewRepresentable + Coordinator", caption: "Delegate callbacks become SwiftUI state changes.") {
            VStack(alignment: .leading, spacing: 12) {
                RichTextView(text: $text, fontSize: fontSize) { selection = $0 }
                    .frame(height: 180)

                HStack {
                    Text("Size")
                    Slider(value: $fontSize, in: 12...28, step: 1)
                    Text("\(Int(fontSize))").monospacedDigit()
                }
                .font(.callout)

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 4) {
                    GridRow {
                        Text("Characters").foregroundStyle(.secondary)
                        Text("\(text.count)").monospacedDigit()
                    }
                    GridRow {
                        Text("Selection").foregroundStyle(.secondary)
                        Text("\(selection.location)…\(selection.location + selection.length)").monospacedDigit()
                    }
                }
                .font(.caption)
            }
        }

        TryItNote("Select some text: the range updates because the Coordinator is the UITextViewDelegate.")
    }
}

#Preview {
    ScrollView { VStack { TextViewDemo() }.padding() }
}

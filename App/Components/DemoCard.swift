import SwiftUI

/// Titled container used to group the individual examples inside a demo screen.
struct DemoCard<Content: View>: View {
    let title: String
    var caption: String?
    @ViewBuilder let content: Content

    init(_ title: String, caption: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.caption = caption
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: 16))
    }
}

/// Short inline hint used to point out what to try on a screen.
struct TryItNote: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Label(text, systemImage: "hand.tap")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

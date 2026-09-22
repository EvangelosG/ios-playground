import SwiftUI

/// Hosts a demo's interactive content and hangs the "How it works" explanation
/// off the toolbar so the example itself is never covered up.
struct DemoScreen: View {
    let demo: Demo

    @State private var showingNotes = false

    var body: some View {
        Group {
            switch demo.layout {
            case .scroll:
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        demo.content()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            case .plain:
                demo.content()
            }
        }
        .navigationTitle(demo.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.\(demo.id.rawValue)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("How it works", systemImage: "info.circle") {
                    showingNotes = true
                }
                .accessibilityIdentifier("howItWorks")
            }
        }
        .sheet(isPresented: $showingNotes) {
            DemoNotesSheet(demo: demo)
        }
    }
}

struct DemoNotesSheet: View {
    let demo: Demo

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(demo.summary)
                        .font(.headline)
                    Text(demo.notes.explanation)
                        .font(.body)
                    if !demo.notes.apis.isEmpty {
                        FlowChips(items: demo.notes.apis)
                    }
                    CodeBlock(code: demo.notes.code)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle(demo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct CodeBlock: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .padding(12)
        }
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
    }
}

/// Wrapping row of API-name chips, built with the `Layout` protocol so the
/// catalog also demonstrates custom layout in a place people actually see.
struct FlowChips: View {
    let items: [String]

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(.caption, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.tint.opacity(0.15), in: .capsule)
            }
        }
    }
}

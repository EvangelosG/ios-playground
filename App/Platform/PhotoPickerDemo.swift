import PhotosUI
import SwiftUI

/// PhotosPicker runs out of process, so the app never asks for photo library
/// permission — it only receives the items the user explicitly picked.
struct PhotoPickerDemo: View {
    @State private var selection: [PhotosPickerItem] = []
    @State private var images: [Image] = []
    @State private var isLoading = false
    @State private var message = "The Simulator ships with a small sample library."

    var body: some View {
        DemoCard("PhotosPicker", caption: "No permission prompt: the picker is a separate process.") {
            VStack(alignment: .leading, spacing: 12) {
                PhotosPicker(selection: $selection, maxSelectionCount: 4, matching: .images) {
                    Label("Choose photos", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.borderedProminent)

                if isLoading {
                    ProgressView("Loading…")
                } else if images.isEmpty {
                    Text(message).font(.caption).foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                        }
                    }
                    Button("Clear", role: .destructive) {
                        images = []
                        selection = []
                    }
                }
            }
        }
        .onChange(of: selection) { _, items in
            Task { await load(items) }
        }

        TryItNote("Pick two or three photos — loading happens asynchronously off the main actor.")
    }

    private func load(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        var loaded: [Image] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                loaded.append(Image(uiImage: uiImage))
            }
        }
        images = loaded
        message = loaded.isEmpty ? "Nothing could be loaded from that selection." : message
    }
}

#Preview {
    ScrollView { VStack { PhotoPickerDemo() }.padding() }
}

import SwiftUI

struct PresentationDemo: View {
    @State private var showSheet = false
    @State private var showResizableSheet = false
    @State private var showFullScreen = false
    @State private var showPopover = false
    @State private var showAlert = false
    @State private var showConfirmation = false
    @State private var lastAction = "nothing yet"

    var body: some View {
        DemoCard("Sheets", caption: "Modal, but still in context. Detents let a sheet start small and grow.") {
            Button("Plain sheet") { showSheet = true }
                .buttonStyle(.borderedProminent)
            Button("Sheet with detents") { showResizableSheet = true }
                .buttonStyle(.bordered)
            Button("Full screen cover") { showFullScreen = true }
                .buttonStyle(.bordered)
        }

        DemoCard("Popovers", caption: "Anchored to the control that opened them; becomes a sheet when space is tight.") {
            Button("Show popover") { showPopover = true }
                .buttonStyle(.bordered)
                .popover(isPresented: $showPopover) {
                    Text("Anchored to the button.")
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
        }

        DemoCard("Alerts & confirmation", caption: "Alerts interrupt for one decision; confirmation dialogs offer a choice of actions.") {
            Button("Show alert") { showAlert = true }
                .buttonStyle(.bordered)
            Button("Delete something…", role: .destructive) { showConfirmation = true }
                .buttonStyle(.bordered)
            Text("Last action: \(lastAction)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .alert("Save changes?", isPresented: $showAlert) {
            Button("Save") { lastAction = "saved" }
            Button("Cancel", role: .cancel) { lastAction = "cancelled" }
        } message: {
            Text("Alerts are for a single, blocking decision.")
        }
        .confirmationDialog("Delete this item?", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { lastAction = "deleted" }
            Button("Archive") { lastAction = "archived" }
        }
        .sheet(isPresented: $showSheet) {
            SamplePresented(title: "A plain sheet")
        }
        .sheet(isPresented: $showResizableSheet) {
            SamplePresented(title: "Drag the grabber")
                .presentationDetents([.height(180), .medium, .large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            SamplePresented(title: "Full screen cover")
        }
    }
}

private struct SamplePresented: View {
    let title: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)
                Text(title).font(.headline)
                Text("Dismissal comes from the environment, so the presented view does not need a binding.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { PresentationDemo() }.padding() }
}

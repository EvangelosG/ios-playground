import SwiftUI

@Observable
final class SharedCounter {
    var value: Int = 0
    var label: String = "Shared"
}

struct StateOwnershipDemo: View {
    @State private var localValue = 0
    @State private var shared = SharedCounter()

    var body: some View {
        DemoCard("@State", caption: "Owned by this view. Recreating the view does not reset it.") {
            Stepper("Local value: \(localValue)", value: $localValue)
                .accessibilityIdentifier("localStepper")
        }

        DemoCard("@Binding", caption: "A read/write window onto someone else's state.") {
            ChildEditor(value: $localValue)
        }

        DemoCard("@Observable", caption: "A reference type shared by several views; only readers of a changed property re-render.") {
            VStack(alignment: .leading, spacing: 12) {
                @Bindable var shared = shared
                TextField("Label", text: $shared.label)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Text("\(shared.label): \(shared.value)")
                    Spacer()
                    Button("Increment") { shared.value += 1 }
                        .buttonStyle(.borderedProminent)
                }
                ObservingBadge(counter: shared)
            }
        }
    }
}

private struct ChildEditor: View {
    @Binding var value: Int

    var body: some View {
        HStack {
            Button("−") { value -= 1 }
            Text("\(value)")
                .monospacedDigit()
                .frame(minWidth: 40)
            Button("+") { value += 1 }
        }
        .buttonStyle(.bordered)
    }
}

private struct ObservingBadge: View {
    let counter: SharedCounter

    var body: some View {
        Text("A separate view reading the same object: \(counter.value)")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { StateOwnershipDemo() }.padding() }
}

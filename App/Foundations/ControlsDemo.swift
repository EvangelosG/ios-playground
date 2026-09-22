import SwiftUI

struct ControlsDemo: View {
    enum Field: Hashable { case name, email }

    @State private var name = ""
    @State private var email = ""
    @State private var notifications = true
    @State private var reminder = Date.now
    @State private var priority = 1
    @State private var portions = 2
    @State private var budget: Double = 40
    @State private var favouriteColor = Color.indigo
    @FocusState private var focus: Field?

    private var emailIsValid: Bool {
        email.isEmpty || (email.contains("@") && email.contains("."))
    }

    var body: some View {
        DemoCard("Form fields & focus", caption: "Validation as you type, and a keyboard that moves between fields.") {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .focused($focus, equals: .name)
                .submitLabel(.next)
                .onSubmit { focus = .email }

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focus, equals: .email)
                .submitLabel(.done)
                .onSubmit { focus = nil }

            if !emailIsValid {
                Label("That does not look like an email address", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack {
                Button("Focus name") { focus = .name }
                Button("Dismiss keyboard") { focus = nil }
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }

        DemoCard("Pickers", caption: "Same data, three presentations — style is a modifier, not a different control.") {
            Picker("Priority", selection: $priority) {
                Text("Low").tag(0)
                Text("Normal").tag(1)
                Text("High").tag(2)
            }
            .pickerStyle(.segmented)

            Picker("Priority", selection: $priority) {
                Text("Low").tag(0)
                Text("Normal").tag(1)
                Text("High").tag(2)
            }
            .pickerStyle(.menu)

            DatePicker("Reminder", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
            ColorPicker("Accent", selection: $favouriteColor)
        }

        DemoCard("Value controls") {
            Toggle("Notifications", isOn: $notifications)
            Stepper("Portions: \(portions)", value: $portions, in: 1...12)
            LabeledContent("Budget") {
                Slider(value: $budget, in: 0...100, step: 5)
            }
            Text(budget, format: .currency(code: "USD"))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }

        DemoCard("Buttons", caption: "Roles and styles carry meaning; iOS draws them consistently everywhere.") {
            HStack {
                Button("Prominent") {}.buttonStyle(.borderedProminent)
                Button("Bordered") {}.buttonStyle(.bordered)
                Button("Plain") {}.buttonStyle(.plain)
            }
            HStack {
                Button("Delete", role: .destructive) {}.buttonStyle(.bordered)
                Button("Disabled") {}.buttonStyle(.bordered).disabled(true)
            }
        }
    }
}

#Preview {
    ScrollView { VStack(spacing: 20) { ControlsDemo() }.padding() }
}

import SwiftUI

struct SettingsSheet: View {
    @ObservedObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State var showConfirmClear = false

    let hours = Array(0...23)

    func hourLabel(_ h: Int) -> String {
        let period = h < 12 ? "am" : "pm"
        let hour12 = h % 12 == 0 ? 12 : h % 12
        return "\(hour12)\(period)"
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("These are now real push notifications — no more manually remembering.")
                        .font(.system(size: 13))
                        .foregroundColor(.barrySlate)
                }
                Section("Weekdays") {
                    Picker("Time", selection: $store.settings.weekdayHour) {
                        ForEach(hours, id: \.self) { h in Text(hourLabel(h)).tag(h) }
                    }
                }
                Section("Weekends") {
                    Picker("Time", selection: $store.settings.weekendHour) {
                        ForEach(hours, id: \.self) { h in Text(hourLabel(h)).tag(h) }
                    }
                }
                Section {
                    Button("Clear all logged data", role: .destructive) {
                        showConfirmClear = true
                    }
                }
            }
            .navigationTitle("Nudge time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.saveSettings()
                        dismiss()
                    }
                }
            }
            .alert("Clear all logged assignments and outcomes?", isPresented: $showConfirmClear) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) { store.resetAll() }
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}

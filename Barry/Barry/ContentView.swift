import SwiftUI
import AVKit

enum Screen {
    case tapsGate, assignment, captured, closed
}

struct ContentView: View {
    @StateObject var store = Store()
    @State var screen: Screen = .tapsGate

    @State var whereCtx = "home"
    @State var energy = "low"
    @State var minutes = 5

    @State var currentAssignment: Assignment? = nil
    @State var currentTier = "primary"
    @State var pendingTapAt = ""

    @State var showCamera = false
    @State var capturedURL: URL? = nil
    @State var saveStatus: String = "Save to Photos"

    @State var showSettings = false

    var body: some View {
        ZStack {
            Color.barryBG.ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                cardView
                    .padding(24)
                    .background(CardBackground())
                    .frame(maxWidth: 390)
                HStack(spacing: 16) {
                    Button("Adjust context") { screen = .tapsGate }
                    Button("Nudge time") { showSettings = true }
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.barrySlate)
                Spacer()
            }
            .padding(20)
        }
        .onAppear {
            whereCtx = store.settings.lastWhere
            energy = store.settings.lastEnergy
            minutes = store.settings.lastMinutes
            screen = store.dayIsClosed() ? .closed : .tapsGate
            NotificationManager.shared.requestPermission()
            NotificationManager.shared.reschedule(settings: store.settings)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCapture(
                onCapture: { url in
                    showCamera = false
                    handleCapture(url: url)
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet(store: store)
        }
    }

    @ViewBuilder
    var cardView: some View {
        switch screen {
        case .tapsGate: tapsGateView
        case .assignment: assignmentView
        case .captured: capturedView
        case .closed: closedView
        }
    }

    // ---------- Taps gate ----------
    var tapsGateView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Masthead(tag: timeLabel())
            Text("Where's Barry right now?")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(.barryForest)

            pillRow(label: "Where", options: [("home", "Home"), ("out", "Out / walk")], selected: whereCtx) { whereCtx = $0 }
            pillRow(label: "Energy", options: [("low", "Low"), ("ok", "Okay"), ("good", "Good")], selected: energy) { energy = $0 }
            pillRow(label: "Minutes you have", options: [("2", "2"), ("5", "5"), ("15", "15")], selected: String(minutes)) { minutes = Int($0) ?? 5 }

            Button("Show today's assignment") {
                store.settings.lastWhere = whereCtx
                store.settings.lastEnergy = energy
                store.settings.lastMinutes = minutes
                store.saveSettings()
                currentAssignment = store.pickAssignment(whereCtx: whereCtx, energy: energy, tier: "primary")
                currentTier = "primary"
                screen = .assignment
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    func pillRow(label: String, options: [(String, String)], selected: String, action: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.0)
                .foregroundColor(.barrySlate)
            HStack(spacing: 8) {
                ForEach(options, id: \.0) { opt in
                    Button(opt.1) { action(opt.0) }
                        .buttonStyle(PillButtonStyle(active: selected == opt.0))
                }
            }
        }
    }

    // ---------- Assignment ----------
    var assignmentView: some View {
        guard let a = currentAssignment else { return AnyView(EmptyView()) }
        let smaller = currentTier == "smaller"
        return AnyView(
            VStack(alignment: .leading, spacing: 20) {
                Masthead(tag: smaller ? "Alt · " + store.bankNumber(a) : store.bankNumber(a))
                Text(a.text)
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundColor(.barryForest)
                Text(a.sub + " " + pacingNote(minutes))
                    .font(.system(size: 14.5, design: .serif))
                    .italic()
                    .foregroundColor(.barryCharcoal.opacity(0.85))

                VStack(spacing: 10) {
                    Button("Film it") {
                        pendingTapAt = ISO8601DateFormatter().string(from: Date())
                        showCamera = true
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button(smaller ? "Not today" : "Not now") {
                        onNotNow()
                    }
                    .buttonStyle(GhostButtonStyle())
                }
            }
        )
    }

    func onNotNow() {
        guard let a = currentAssignment else { return }
        if currentTier == "primary" {
            store.logEntry(assignment: a, whereCtx: whereCtx, energy: energy, minutes: minutes, outcome: "not_now", tier: "primary", tapAt: ISO8601DateFormatter().string(from: Date()))
            currentAssignment = store.pickAssignment(whereCtx: whereCtx, energy: energy, tier: "smaller")
            currentTier = "smaller"
        } else {
            store.logEntry(assignment: a, whereCtx: whereCtx, energy: energy, minutes: minutes, outcome: "declined_final", tier: "smaller", tapAt: ISO8601DateFormatter().string(from: Date()))
            screen = .closed
        }
    }

    // ---------- Capture ----------
    func handleCapture(url: URL) {
        guard let a = currentAssignment else { return }
        store.logEntry(
            assignment: a, whereCtx: whereCtx, energy: energy, minutes: minutes,
            outcome: currentTier == "smaller" ? "smaller_accepted" : "filmed",
            tier: currentTier, tapAt: pendingTapAt, capturedAt: ISO8601DateFormatter().string(from: Date())
        )
        capturedURL = url
        saveStatus = "Save to Photos"
        screen = .captured
    }

    var capturedView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Masthead(tag: "Logged")
            Text("That's today's clip.")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(.barryForest)

            if let url = capturedURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 300)
                    .overlay(Rectangle().stroke(Color.barrySage, lineWidth: 1))
            }

            Button(saveStatus) {
                guard let url = capturedURL else { return }
                saveVideoToPhotos(url: url) { success in
                    saveStatus = success ? "Saved" : "Couldn't save — check Photos permission in Settings"
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Done") {
                screen = .closed
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    // ---------- Closed ----------
    var closedView: some View {
        let success = store.todaysEntries().contains { ["filmed", "smaller_accepted"].contains($0.outcome) }
        return VStack(alignment: .leading, spacing: 18) {
            Masthead(tag: "Logged")
            Text(success ? "Got today's clip." : "That's alright.")
                .font(.system(size: 26, weight: .regular, design: .serif))
                .foregroundColor(.barryForest)
            Text(success ? "It's in your Photos. Nothing to post, nothing to edit." : "See you tomorrow.")
                .font(.system(size: 14.5, design: .serif))
                .italic()
                .foregroundColor(.barryCharcoal.opacity(0.85))
            Button("Feeling it? Do one more.") {
                screen = .tapsGate
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    func timeLabel() -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mma · EEE"
        return f.string(from: Date()).uppercased()
    }
}

#Preview {
    ContentView()
}

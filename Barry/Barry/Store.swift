import Foundation
import Combine

struct OutcomeEntry: Codable, Identifiable {
    var id: String
    var date: String
    var tapAt: String
    var assignmentId: String
    var assignmentText: String
    var whereCtx: String
    var energy: String
    var minutes: Int
    var outcome: String  // "filmed" | "not_now" | "smaller_accepted" | "declined_final"
    var tier: String
    var capturedAt: String?
}

struct AppSettings: Codable {
    var weekdayHour: Int = 17
    var weekendHour: Int = 11
    var lastWhere: String = "home"
    var lastEnergy: String = "low"
    var lastMinutes: Int = 5
}

class Store: ObservableObject {
    @Published var outcomes: [OutcomeEntry] = []
    @Published var settings = AppSettings()

    private let outcomesURL: URL
    private let settingsURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        outcomesURL = docs.appendingPathComponent("barry_outcomes.json")
        settingsURL = docs.appendingPathComponent("barry_settings.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: outcomesURL),
           let decoded = try? JSONDecoder().decode([OutcomeEntry].self, from: data) {
            outcomes = decoded
        }
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }

    func saveOutcomes() {
        if let data = try? JSONEncoder().encode(outcomes) {
            try? data.write(to: outcomesURL)
        }
    }

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
        NotificationManager.shared.reschedule(settings: settings)
    }

    func resetAll() {
        outcomes = []
        try? FileManager.default.removeItem(at: outcomesURL)
    }

    static func todayStr() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        return f.string(from: Date())
    }

    func daysAgo(_ dateStr: String) -> Int {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let then = f.date(from: dateStr), let now = f.date(from: Store.todayStr()) else { return 999 }
        return Calendar.current.dateComponents([.day], from: then, to: now).day ?? 999
    }

    func todaysEntries() -> [OutcomeEntry] {
        outcomes.filter { $0.date == Store.todayStr() }
    }

    func dayIsClosed() -> Bool {
        todaysEntries().contains { ["filmed", "smaller_accepted", "declined_final"].contains($0.outcome) }
    }

    @discardableResult
    func logEntry(assignment: Assignment, whereCtx: String, energy: String, minutes: Int, outcome: String, tier: String, tapAt: String, capturedAt: String? = nil) -> OutcomeEntry {
        let entry = OutcomeEntry(
            id: UUID().uuidString, date: Store.todayStr(), tapAt: tapAt,
            assignmentId: assignment.id, assignmentText: assignment.text,
            whereCtx: whereCtx, energy: energy, minutes: minutes,
            outcome: outcome, tier: tier, capturedAt: capturedAt
        )
        outcomes.append(entry)
        saveOutcomes()
        return entry
    }

    func pickAssignment(whereCtx: String, energy: String, tier: String) -> Assignment {
        let energyCap = ["low": 1, "ok": 2, "good": 3][energy] ?? 1
        let wantEffort: Int? = tier == "smaller" ? 1 : nil

        var pool = BANK.filter {
            $0.whereTags.contains(whereCtx) && $0.effort <= energyCap && (wantEffort == nil || $0.effort == wantEffort!)
        }

        let refusedRecently = Set(
            outcomes.filter { ($0.outcome == "not_now" || $0.outcome == "declined_final") && daysAgo($0.date) < 14 }
                .map { $0.assignmentId }
        )
        let filtered = pool.filter { !refusedRecently.contains($0.id) }
        if !filtered.isEmpty { pool = filtered }

        let recent = outcomes.sorted { ($0.date + $0.tapAt) > ($1.date + $1.tapAt) }.prefix(2)
        let bothRefused = recent.count == 2 && recent.allSatisfy { $0.outcome == "not_now" || $0.outcome == "declined_final" }
        if bothRefused && tier != "smaller" {
            let smallest = pool.filter { $0.effort == 1 }
            if !smallest.isEmpty { pool = smallest }
        }

        if pool.isEmpty { pool = BANK.filter { $0.whereTags.contains(whereCtx) } }
        if pool.isEmpty { pool = BANK }

        var lastShown: [String: String] = [:]
        for o in outcomes { lastShown[o.assignmentId] = o.date }
        pool.sort { (lastShown[$0.id] ?? "0000-00-00") < (lastShown[$1.id] ?? "0000-00-00") }

        return pool.first ?? BANK[0]
    }

    func bankNumber(_ a: Assignment) -> String {
        let idx = (BANK.firstIndex { $0.id == a.id } ?? 0) + 1
        return "No. " + String(format: "%03d", idx)
    }

    // month stats — used by the (optional) history sheet
    func filmedDaysThisMonth() -> Int {
        let cal = Calendar.current
        let now = Date()
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        let filmedDates = Set(
            outcomes.filter { ["filmed", "smaller_accepted"].contains($0.outcome) }
                .compactMap { df.date(from: $0.date) }
                .filter { cal.isDate($0, equalTo: now, toGranularity: .month) }
                .map { df.string(from: $0) }
        )
        return filmedDates.count
    }
}

import SwiftUI

// MARK: - Care Plan Preferences Model

struct CarePlanPreferences: Codable {
    var comfortPreference: ComfortType
    var topHelps: [String]
    var topAvoids: [String]
    var redFlags: [String]
    
    enum ComfortType: String, Codable, CaseIterable {
        case hug = "A warm hug"
        case space = "Some quiet space"
        case distraction = "A gentle distraction"
        case talk = "Someone to talk to"
        
        var icon: String {
            switch self {
            case .hug: return "heart.circle.fill"
            case .space: return "figure.walk"
            case .distraction: return "gamecontroller.fill"
            case .talk: return "bubble.left.and.bubble.right.fill"
            }
        }
    }
    
    init() {
        self.comfortPreference = .hug
        self.topHelps = []
        self.topAvoids = []
        self.redFlags = []
    }
}

// MARK: - Care Plan ViewModel

class CarePlanViewModel: ObservableObject {
    @Published var preferences: CarePlanPreferences?
    @Published var checklistItems: [(String, Bool)] = []
    
    private let preferencesKey = "carePlanPreferences"
    private let lastResetKey = "lastResetDate"
    
    init() {
        loadPreferences()
        generateChecklistItems()
        resetIfNeeded()
    }
    
    // MARK: - Preferences Management
    
    func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(CarePlanPreferences.self, from: data) {
            preferences = decoded
        }
    }
    
    func savePreferences(_ newPreferences: CarePlanPreferences) {
        preferences = newPreferences
        if let encoded = try? JSONEncoder().encode(newPreferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
        generateChecklistItems()
    }
    
    // MARK: - Checklist Generation
    
    private func generateChecklistItems() {
        guard let prefs = preferences else {
            checklistItems = []
            return
        }
        
        var items: [(String, Bool)] = []
        
        // Comfort preference item
        items.append(("Remember: \(prefs.comfortPreference.rawValue)", false))
        
        // Top helps
        for help in prefs.topHelps.prefix(3) where !help.isEmpty {
            items.append((help, false))
        }
        
        // Red flags (marked differently, not checkable in the same way)
        for flag in prefs.redFlags.prefix(3) where !flag.isEmpty {
            items.append(("⚠️ Watch for: \(flag)", false))
        }
        
        checklistItems = items
    }
    
    // MARK: - Reset Logic (reuses existing monthly reset mechanism)
    
    func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetKey) as? Date {
            if !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month) {
                resetChecklist()
            }
        } else {
            resetChecklist()
        }
    }
    
    private func resetChecklist() {
        // Uncheck all items
        checklistItems = checklistItems.map { ($0.0, false) }
        UserDefaults.standard.set(Date(), forKey: lastResetKey)
    }
    
    // MARK: - Item Management
    
    func toggleItem(at index: Int) {
        guard index < checklistItems.count else { return }
        checklistItems[index].1.toggle()
    }
}

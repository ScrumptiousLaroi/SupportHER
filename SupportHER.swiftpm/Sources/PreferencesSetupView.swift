import SwiftUI

struct PreferencesSetupView: View {
    @ObservedObject var viewModel: CarePlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var comfortPreference: CarePlanPreferences.ComfortType
    @State private var topHelps: [String]
    @State private var topAvoids: [String]
    @State private var redFlags: [String]
    
    init(viewModel: CarePlanViewModel) {
        self.viewModel = viewModel
        
        let prefs = viewModel.preferences ?? CarePlanPreferences()
        _comfortPreference = State(initialValue: prefs.comfortPreference)
        
        // Ensure exactly 3 items for each array
        var helps = prefs.topHelps
        while helps.count < 3 { helps.append("") }
        _topHelps = State(initialValue: Array(helps.prefix(3)))
        
        var avoids = prefs.topAvoids
        while avoids.count < 3 { avoids.append("") }
        _topAvoids = State(initialValue: Array(avoids.prefix(3)))
        
        var flags = prefs.redFlags
        while flags.count < 3 { flags.append("") }
        _redFlags = State(initialValue: Array(flags.prefix(3)))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Comfort Preference Section
                Section {
                    Picker("When she wants comfort", selection: $comfortPreference) {
                        ForEach(CarePlanPreferences.ComfortType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Comfort Preference")
                } footer: {
                    Text("What helps her feel better when she's struggling?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Top 3 Helps Section
                Section {
                    ForEach(0..<3, id: \.self) { index in
                        TextField("E.g., warm tea, heating pad, back rub", text: $topHelps[index])
                    }
                } header: {
                    Text("Top 3 Things That Help")
                } footer: {
                    Text("What specific things make her feel cared for?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Top 3 Avoids Section
                Section {
                    ForEach(0..<3, id: \.self) { index in
                        TextField("E.g., don't minimize pain, don't offer solutions", text: $topAvoids[index])
                    }
                } header: {
                    Text("Top 3 Things NOT to Do")
                } footer: {
                    Text("What should you avoid saying or doing?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Red Flags Section
                Section {
                    ForEach(0..<3, id: \.self) { index in
                        TextField("E.g., severe cramps, heavy bleeding", text: $redFlags[index])
                    }
                } header: {
                    Text("Red Flags to Take Seriously")
                } footer: {
                    Text("Warning signs that might need medical attention")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Care Plan Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePreferences()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func savePreferences() {
        var prefs = CarePlanPreferences()
        prefs.comfortPreference = comfortPreference
        prefs.topHelps = topHelps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        prefs.topAvoids = topAvoids.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        prefs.redFlags = redFlags.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        viewModel.savePreferences(prefs)
    }
}

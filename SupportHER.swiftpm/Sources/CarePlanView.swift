import SwiftUI

struct CarePlanView: View {
    @StateObject private var viewModel = CarePlanViewModel()
    @State private var showingPreferencesSetup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Edit button
            HStack {
                Text("Care Plan for Her Preferences")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingPreferencesSetup = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14))
                        Text("Edit")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#F2A1A1").opacity(0.1))
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Content area
            if viewModel.preferences == nil || viewModel.checklistItems.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Checklist
                checklistView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingPreferencesSetup) {
            PreferencesSetupView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.resetIfNeeded()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "#F2A1A1").opacity(0.6))
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Personalize Your Care Plan")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap 'Edit' to set up preferences together.\nRemember what matters most to her.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Checklist View
    
    private var checklistView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.checklistItems.indices, id: \.self) { index in
                    let item = viewModel.checklistItems[index]
                    CarePlanChecklistItem(
                        text: item.0,
                        isChecked: item.1,
                        isRedFlag: item.0.hasPrefix("⚠️")
                    ) {
                        withAnimation(.spring()) {
                            viewModel.toggleItem(at: index)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.leading)
        }
    }
}

// MARK: - Checklist Item Component

struct CarePlanChecklistItem: View {
    let text: String
    let isChecked: Bool
    let isRedFlag: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .green : .gray)
                .font(.system(size: 20))
                .onTapGesture {
                    onToggle()
                }
            
            if isRedFlag {
                // Red flag items get special styling
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
                    .fontWeight(.medium)
            } else {
                // Regular items
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.system(size: 14))
                    
                    Text(text)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

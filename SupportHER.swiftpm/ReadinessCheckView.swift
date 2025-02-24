import SwiftUI

class ReadinessViewModel: ObservableObject {
    @Published var items: [(String, String, Bool)] = [
        ("Pills", "cross.case.fill", false),
        ("Heating Bag", "flame.fill", false),
        ("Warm Water", "drop.fill", false),
        ("Sanitary Products", "heart.circle.fill", false),
        ("Disposable Bags", "bag.fill", false),
        ("Comfort Snacks", "heart.fill", false),
        ("Warm Drinks", "cup.and.saucer.fill", false)
    ]
    
    init() {
        resetIfNeeded()
    }
    
    func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date {
            if !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month) {
                resetChecklist()
            }
        } else {
            resetChecklist()
        }
    }
    
    private func resetChecklist() {
        items = items.map { ($0.0, $0.1, false) }
        UserDefaults.standard.set(Date(), forKey: "lastResetDate")
    }
}

struct ReadinessCheckView: View { // for loading items from the model to reduce redundancy
    @StateObject private var viewModel = ReadinessViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Check your readiness")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.top)
                
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.items.indices, id: \.self) { index in
                        let item = viewModel.items[index]
                        ChecklistItem(icon: item.1, text: item.0, isChecked: $viewModel.items[index].2)
                    }
                }
                .padding(.horizontal)
                .padding(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .onAppear {
            viewModel.resetIfNeeded()
        }
    }
}

struct ChecklistItem: View {
    let icon: String
    let text: String
    @Binding var isChecked: Bool
    
    var body: some View { // logic for checking items
        HStack(spacing: 12) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .green : .gray)
                .font(.system(size: 20))
                .onTapGesture {
                    withAnimation(.spring()) {
                        isChecked.toggle()
                    }
                }
            
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


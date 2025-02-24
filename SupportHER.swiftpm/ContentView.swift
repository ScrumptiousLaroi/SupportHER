import SwiftUI


struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var calendarViewModel = CycleCalendarViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab - Dashboard
            NavigationStack {
                mainDashboardView
                    .navigationTitle("Dashboard")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbarBackground(Color(hex: "#f0a89e"), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            .tag(0)
            
            // Second Tab - Info
            NavigationStack {
                View2()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                selectedTab = 0
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Dashboard")
                                }
                            }
                        }
                    }
                    .toolbarBackground(Color(hex: "#f0a89e"), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
            .tabItem {
                Label("Info", systemImage: "star.fill")
            }
            .tag(1)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    // Dashboard View
    private var mainDashboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                CycleCalendarView()
                    .padding(.horizontal)
                    .environmentObject(calendarViewModel)
                
                HStack(spacing: 15) {
                    GeometryReader { geometry in
                        MoodCardView(calendarViewModel: calendarViewModel)
                            .frame(height: geometry.size.width)
                    }
                    GeometryReader { geometry in
                        PainCardView(calendarViewModel: calendarViewModel)
                            .frame(height: geometry.size.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.width / 2 - 25)
                .padding(.horizontal)
                
                if calendarViewModel.cycleStartDate != nil {
                    
                    if calendarViewModel.currentPhase == .menstruating {
                        ThingsToDoView()
                    }
                    else {
                        ReadinessCheckView()
                            .frame(height: 350)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(hex: "#FDEDEB"))
    }
}

// Mood Card View
struct MoodCardView: View {
    @ObservedObject var calendarViewModel: CycleCalendarViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
            Text("Mood")
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(Color.black)
                .padding(.bottom, 140)
                .padding(.trailing, 110)
            
            if calendarViewModel.cycleStartDate == nil {
                Text("Please select your period dates first")
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            } else if calendarViewModel.currentPhase == .follicular {
                Text("😁")
                    .font(.system(size : 120))
                    .padding(.top, 10)
                Text("Happy")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .padding(.top, 150)
            }
            else if calendarViewModel.currentPhase == .luteal{
                Text("😒")
                    .font(.system(size : 120))
                    .padding(.top, 10)
                Text("Cranky")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .padding(.top, 150)
            }
            else if calendarViewModel.currentPhase == .menstruating{
                Text("😩")
                    .font(.system(size : 120))
                    .padding(.top, 10)
                Text("Painful")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                    .padding(.top, 150)
            }
            else if calendarViewModel.currentPhase == .ovulatory{
                Text("😜")
                    .font(.system(size : 120))
                    .padding(.top, 10)
                    Text("Playful")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                        .padding(.top, 150)
                
            }
        }
    }
}

// Pain Card View
struct PainCardView: View {
    @ObservedObject var calendarViewModel: CycleCalendarViewModel
    @State private var painLevel: Double = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Pain Level")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.black)
                Spacer()
                
                if calendarViewModel.cycleStartDate == nil {
                    Text("Please select your period dates first")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                } else {
                    PainLevelSlider(value: .constant(calculatePainLevel()))
                        .padding(.horizontal, 8)
                    
                    Text(getPainLevelText())
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(painLevelColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
    }
    
    private func calculatePainLevel() -> Double {
        guard let cycleStartDate = calendarViewModel.cycleStartDate else { return 0 }
        
        let calendar = Calendar.current
        let today = Date()
        let daysSinceCycleStart = calendar.dateComponents([.day], from: cycleStartDate, to: today).day ?? 0
        
       
        if daysSinceCycleStart >= 0 && daysSinceCycleStart <= 1 {
            return 0.9
        }
        
       
        if daysSinceCycleStart >= -3 && daysSinceCycleStart <= -1 {
            return 0.7
        }
        
  
        if daysSinceCycleStart >= 2 && daysSinceCycleStart <= 5 {
            return 0.4
        }
        
        return 0.1
    }
    
    private func getPainLevelText() -> String {
        guard let cycleStartDate = calendarViewModel.cycleStartDate else { return "No Data" }
        
        let calendar = Calendar.current
        let today = Date()
        let daysSinceCycleStart = calendar.dateComponents([.day], from: cycleStartDate, to: today).day ?? 0
        
        
        if daysSinceCycleStart >= 0 && daysSinceCycleStart <= 1 {
            return "Severe Pain"
        }
        

        if daysSinceCycleStart >= -3 && daysSinceCycleStart <= -1 {
            return "Mild Pain"
        }
        

        if daysSinceCycleStart >= 2 && daysSinceCycleStart <= 5 {
            return "Normal Pain"
        }
        
        return "Normal Pain"
    }
    
    private var painLevelColor: Color {
        let level = calculatePainLevel()
        switch level {
        case 0..<0.25:
            return .green
        case 0.25..<0.5:
            return .yellow
        case 0.5..<0.75:
            return .orange
        default:
            return .red
        }
    }
}

// Custom Pain Level Slider
struct PainLevelSlider: View {
    @Binding var value: Double
    private let gradientColors = [Color.green, Color.yellow, Color.orange, Color.red]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
          
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 8)
                    .cornerRadius(4)
                
         
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .overlay(
                        Circle()
                            .stroke(currentThumbColor, lineWidth: 2)
                    )
                    .offset(x: (geometry.size.width - 24) * value)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                updateSliderValue(geometry: geometry, gesture: gesture)
                            }
                    )
            }
        }
        .frame(height: 24)
        .accessibilityValue(painLevelText)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                value = min(1, value + 0.1)
            case .decrement:
                value = max(0, value - 0.1)
            @unknown default:
                break
            }
        }
    }
    
    private func updateSliderValue(geometry: GeometryProxy, gesture: DragGesture.Value) {
        let width = geometry.size.width - 24
        let dragLocation = gesture.location.x - 12 
        let normalizedValue = dragLocation / width
        value = max(0, min(1, normalizedValue))
    }
    
    private var currentThumbColor: Color {
        switch value {
        case 0..<0.25:
            return .green
        case 0.25..<0.5:
            return .yellow
        case 0.5..<0.75:
            return .orange
        default:
            return .red
        }
    }
    
    private var painLevelText: String {
        switch value {
        case 0..<0.25:
            return "No Pain"
        case 0.25..<0.5:
            return "Mild Pain"
        case 0.5..<0.75:
            return "Moderate Pain"
        default:
            return "Severe Pain"
        }
    }
}

// Things To Do View
struct ThingsToDoView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(height: 400)
                .padding(.horizontal)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Things to do")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 12) {
                    ThingsToDo(icon: "heart.fill", text: "Reassure her with a warm hug")
                    ThingsToDo(icon: "hand.raised.fill", text: "Validate Her Feelings")
                    ThingsToDo(icon: "bubble.left.fill", text: "Encourage her to express herself")
                    ThingsToDo(icon: "checklist", text: "Offer to help with daily tasks")
                    ThingsToDo(icon: "house.fill", text: "Create a relaxing environment")
                    ThingsToDo(icon: "ear.fill", text: "Listen to her concerns")
                    ThingsToDo(icon: "heart.circle.fill", text: "Support her emotionally")
                    ThingsToDo(icon: "person.fill", text: "Encourage self-care")
                    ThingsToDo(icon: "star.fill", text: "Provide positive reinforcement")
                    ThingsToDo(icon: "text.bubble.fill", text: "Offer words of encouragement")
                    ThingsToDo(icon: "calendar", text: "Help her stay organized")
                }
                .padding(.horizontal)
                .padding(.leading)
            }
        }
    }
}

// Things To Do Item
struct ThingsToDo: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

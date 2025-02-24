//
//  CycleCalendarView.swift
//  SupportHER
//
//  Created by Puru Thakur on 10/02/25.
//

import SwiftUI

enum CyclePhase: String, CaseIterable {
    case menstruating = "MENSTRUATING"
    case follicular = "FOLLICULAR"
    case ovulatory = "OVULATORY"
    case luteal = "LUTEAL"
    
    var color: Color {
        switch self {
        case .menstruating: return .red
        case .follicular: return .purple
        case .ovulatory: return .blue
        case .luteal: return .yellow
        }
    }
}

class CycleCalendarViewModel: ObservableObject {
    @Published var currentPhase: CyclePhase = .follicular
    @Published var cycleStartDate: Date? {
        didSet {
            if let date = cycleStartDate {
                UserDefaults.standard.set(date, forKey: "cycleStartDate")
            }
        }
    }
    @Published var periodEndDate: Date? {
        didSet {
            if let date = periodEndDate {
                UserDefaults.standard.set(date, forKey: "periodEndDate")
            }
        }
    }
    @Published var selectedDate = Date()
    @Published var showingDatePicker = false
    @Published var isSelectingEndDate = false
    @Published var futurePeriodRanges: [(start: Date, end: Date)] = []
    
    private let calendar = Calendar.current
    internal let daysInWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    init() {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        
        // Load saved dates from UserDefaults
        if let savedStartDate = UserDefaults.standard.object(forKey: "cycleStartDate") as? Date {
            self.cycleStartDate = savedStartDate
        }
        
        if let savedEndDate = UserDefaults.standard.object(forKey: "periodEndDate") as? Date {
            self.periodEndDate = savedEndDate
            calculateFuturePeriodDates()
        }
        
        updateCurrentPhase()
    }
    
    internal func getPhaseFor(date: Date) -> CyclePhase? {
        if isDateInPeriod(date) {
            return .menstruating
        }
        
        guard let cycleStart = cycleStartDate else { return nil }
        
        let daysSinceStart = calendar.dateComponents([.day], from: cycleStart, to: date).day ?? 0
        
        let daysInCycle = 28
        let normalizedDay = ((daysSinceStart % daysInCycle) + daysInCycle) % daysInCycle
        
        let follicularLength = 13
        let ovulatoryLength = 1
        let lutealLength = 14
        
        if normalizedDay < follicularLength {
            return .follicular
        } else if normalizedDay < follicularLength + ovulatoryLength {
            return .ovulatory
        } else if normalizedDay < follicularLength + ovulatoryLength + lutealLength {
            return .luteal
        }
        
        return nil
    }
    
    internal func updateCurrentPhase() {
        if let phase = getPhaseFor(date: Date()) {
            currentPhase = phase
        }
    }
    
    internal var periodRangeText: String {
        if let start = cycleStartDate {
            if let end = periodEndDate {
                return "\(start.formatted(.dateTime.day().month())) - \(end.formatted(.dateTime.day().month()))"
            }
            return "Started \(start.formatted(.dateTime.day().month()))"
        }
        return "Set Period"
    }
    
    private var periodLength: Int {
        guard let startDate = cycleStartDate,
              let endDate = periodEndDate else { return 5 }
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 5
    }
    
    internal func isDateInPeriod(_ date: Date) -> Bool {
        // Check if it's in the initial period
        if let startDate = cycleStartDate,
           let endDate = periodEndDate {
            // Ensure the range is valid
            if startDate <= endDate {
                if calendar.isDate(date, inSameDayAs: startDate) ||
                   calendar.isDate(date, inSameDayAs: endDate) ||
                   (startDate...endDate).contains(date) {
                    return true
                }
            }
        }
        
        // Check if it's in any future period
        for periodRange in futurePeriodRanges {
            // Ensure the range is valid
            if periodRange.start <= periodRange.end {
                if calendar.isDate(date, inSameDayAs: periodRange.start) ||
                   calendar.isDate(date, inSameDayAs: periodRange.end) ||
                   (periodRange.start...periodRange.end).contains(date) {
                    return true
                }
            }
        }
        
        return false
    }
    
    internal func isFuturePeriodStart(_ date: Date) -> Bool {
        return futurePeriodRanges.contains { calendar.isDate($0.start, inSameDayAs: date) }
    }
    
    internal func calculateFuturePeriodDates() {
        guard let startDate = cycleStartDate else { return }
        
        futurePeriodRanges.removeAll()
        
        // calculate future dates for 12 months in advance
        for i in 1...12 {
            if let futureStart = calendar.date(byAdding: .day, value: 28 * i, to: startDate) {
                if let futureEnd = calendar.date(byAdding: .day, value: periodLength - 1, to: futureStart) {
                    futurePeriodRanges.append((start: futureStart, end: futureEnd))
                }
            }
        }
    }
    
    internal func isFuturePeriodDate(_ date: Date) -> Bool {
        for futureStart in futurePeriodRanges {
            if (futureStart.start...futureStart.end).contains(date) {
                return true
            }
        }
        return false
    }
    
    internal func getCurrentPhaseDisplay() -> String {
        guard cycleStartDate != nil else {
            return "Select period dates"
        }
        
        if isCurrentlyMenstruating() {
            return CyclePhase.menstruating.rawValue
        }
        return currentPhase.rawValue
    }
    
    internal func getCurrentPhaseColor() -> Color {
        guard cycleStartDate != nil else {
            return .black
        }
        
        if isCurrentlyMenstruating() {
            return CyclePhase.menstruating.color
        }
        return currentPhase.color
    }
    
    internal func isCurrentlyMenstruating() -> Bool {
        isDateInPeriod(Date())
    }
    
    internal func datesInMonth() -> [(date: Date, isCurrentMonth: Bool)] {
        var dates: [(date: Date, isCurrentMonth: Bool)] = []
        
        let monthInterval = calendar.dateInterval(of: .month, for: selectedDate)!
        let monthFirstDate = monthInterval.start
        let monthLastDate = monthInterval.end
        
        
        let weekdayOfFirst = calendar.component(.weekday, from: monthFirstDate)
        let daysToSubtract = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthFirstDate) else {
            return []
        }
        
        let weekdayOfLast = calendar.component(.weekday, from: monthLastDate)
        let daysToAdd = (7 - weekdayOfLast + calendar.firstWeekday - 1) % 7
        
        guard let endDate = calendar.date(byAdding: .day, value: daysToAdd, to: monthLastDate) else {
            return []
        }
        
        var currentDate = startDate
        
        while currentDate <= endDate {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: selectedDate, toGranularity: .month)
            dates.append((date: currentDate, isCurrentMonth: isCurrentMonth))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    func isWithinDaysBeforePeriod(startDays: Int, endDays: Int) -> Bool {
        guard let cycleStart = cycleStartDate else { return false }
        
        let today = Date()
        let calendar = Calendar.current
        
        
        var nextPeriod = cycleStart
        while nextPeriod <= today {
            nextPeriod = calendar.date(byAdding: .day, value: 28, to: nextPeriod)!
        }
        
     
        let daysUntilPeriod = calendar.dateComponents([.day], from: today, to: nextPeriod).day ?? 0
        
        return daysUntilPeriod <= startDays && daysUntilPeriod >= endDays
    }

    func isWithin24HoursAfterPeriodStart() -> Bool {
        guard let cycleStart = cycleStartDate else { return false }
        
        let today = Date()
        let calendar = Calendar.current
        
        let hoursSincePeriodStart = calendar.dateComponents([.hour], from: cycleStart, to: today).hour ?? 0
        
        return hoursSincePeriodStart <= 24 && hoursSincePeriodStart >= 0
    }

    func isWithinDaysAfterPeriodStart(days: Int) -> Bool {
        guard let cycleStart = cycleStartDate else { return false }
        
        let today = Date()
        let calendar = Calendar.current
        
        let daysSincePeriodStart = calendar.dateComponents([.day], from: cycleStart, to: today).day ?? 0

        for periodRange in futurePeriodRanges {
            let daysSinceFuturePeriod = calendar.dateComponents([.day], from: periodRange.start, to: today).day ?? 0
            if daysSinceFuturePeriod >= 0 && daysSinceFuturePeriod < days {
                return true
            }
        }
        
        return daysSincePeriodStart >= 0 && daysSincePeriodStart < days
    }

}

struct CycleCalendarView: View {
    @EnvironmentObject private var viewModel: CycleCalendarViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(viewModel.selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    viewModel.isSelectingEndDate = false
                    viewModel.showingDatePicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                        Text(viewModel.cycleStartDate == nil ? "Set Period" : viewModel.periodRangeText)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            viewModel.selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.selectedDate)!
                        }
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Button(action: {
                        withAnimation {
                            viewModel.selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.selectedDate)!
                        }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            
            HStack {
                ForEach(viewModel.daysInWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(viewModel.datesInMonth(), id: \.date) { dateInfo in
                    let day = Calendar.current.component(.day, from: dateInfo.date)
                    let isToday = Calendar.current.isDateInToday(dateInfo.date)
                    let isCycleStart = viewModel.cycleStartDate.map { Calendar.current.isDate(dateInfo.date, inSameDayAs: $0) } ?? false
                    let isInPeriod = viewModel.isDateInPeriod(dateInfo.date)
                    let isFuturePeriodStart = viewModel.isFuturePeriodStart(dateInfo.date)
                    
                    ZStack {
                        Group {
                            if isInPeriod {
                                Rectangle()
                                    .fill(Color.red.opacity(dateInfo.isCurrentMonth ? 0.2 : 0.1))
                                    .animation(.easeInOut, value: isInPeriod)
                            } else if let phase = viewModel.getPhaseFor(date: dateInfo.date) {
                                switch phase {
                                case .follicular:
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(phase.color.opacity(dateInfo.isCurrentMonth ? 0.2 : 0.1))
                                case .ovulatory:
                                    Circle()
                                        .fill(phase.color.opacity(dateInfo.isCurrentMonth ? 0.2 : 0.1))
                                case .luteal:
                                    RegularPolygon(sides: 6)
                                        .fill(phase.color.opacity(dateInfo.isCurrentMonth ? 0.2 : 0.1))
                                        .frame(width: 32, height: 32)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: isInPeriod)
                        
                        if isToday {
                            Circle()
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                        
                        if isCycleStart || isFuturePeriodStart {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                        
                        Text("\(day)")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(
                                isToday ? .black :
                                    (isCycleStart || isFuturePeriodStart) ? .black :
                                    dateInfo.isCurrentMonth ? .primary : .gray
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 8) {
                Text("Current Phase")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(viewModel.getCurrentPhaseDisplay())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.getCurrentPhaseColor())
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPhase)
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    LegendItem(phase: .menstruating)
                    LegendItem(phase: .follicular)
                }
                HStack(spacing: 16) {
                    LegendItem(phase: .ovulatory)
                    LegendItem(phase: .luteal)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPhase)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .sheet(isPresented: $viewModel.showingDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        viewModel.isSelectingEndDate ? "Select Period End Date" : "Select Period Start Date",
                        selection: Binding(
                            get: { viewModel.isSelectingEndDate ? (viewModel.periodEndDate ?? Date()) : (viewModel.cycleStartDate ?? Date()) },
                            set: { date in
                                if viewModel.isSelectingEndDate {
                                    viewModel.periodEndDate = date
                                    viewModel.calculateFuturePeriodDates()
                                } else {
                                    viewModel.cycleStartDate = date
                                    // Set default end date 5 days after start date
                                    if let startDate = viewModel.cycleStartDate {
                                        viewModel.periodEndDate = Calendar.current.date(byAdding: .day, value: 5, to: startDate)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        viewModel.isSelectingEndDate = true
                                    }
                                }
                            }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .onChange(of: viewModel.cycleStartDate) { _ in
                        viewModel.updateCurrentPhase()
                    }
                }
                .navigationTitle(viewModel.isSelectingEndDate ? "Select End Date" : "Select Start Date")
                .navigationBarItems(
                    trailing: Button("Done") {
                        if !viewModel.isSelectingEndDate || viewModel.periodEndDate != nil {
                            viewModel.showingDatePicker = false
                            viewModel.isSelectingEndDate = false
                        }
                    }
                )
            }
        }
        .onChange(of: viewModel.periodEndDate) { _ in
            viewModel.calculateFuturePeriodDates()
        }
        .onAppear {
            if viewModel.cycleStartDate == nil {
                viewModel.showingDatePicker = true
                viewModel.isSelectingEndDate = false
            }
        }
    }
    
    private struct LegendItem: View {
        let phase: CyclePhase
        
        var body: some View {
            HStack {
                // Phase shape based on the type
                Group {
                    switch phase {
                    case .menstruating:
                        Rectangle()
                            .fill(phase.color.opacity(0.5))
                            .frame(width: 12, height: 12)
                    case .follicular:
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(phase.color.opacity(0.5))
                    case .ovulatory:
                        Circle()
                            .fill(phase.color.opacity(0.5))
                            .frame(width: 12, height: 12)
                    case .luteal:
                        RegularPolygon(sides: 6)
                            .stroke(phase.color, lineWidth: 2)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(phase.rawValue)
                    .font(.system(size: 12))
            }
        }
    }
    
    private struct RegularPolygon: Shape {
        let sides: Int
        
        func path(in rect: CGRect) -> Path {
            let h = Double(min(rect.size.width, rect.size.height)) / 2.0
            let c = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
            var path = Path()
            
            for i in 0..<sides {
                let angle = (Double(i) * (360.0 / Double(sides))) * Double.pi / 180
                let pt = CGPoint(x: c.x + CGFloat(cos(angle) * h), y: c.y + CGFloat(sin(angle) * h))
                if i == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()
            return path
        }
    }

    var currentPhase: CyclePhase {
        viewModel.currentPhase
    }
}

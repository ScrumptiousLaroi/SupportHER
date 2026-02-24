import SwiftUI

struct QuestHomeView: View {
    @StateObject private var questManager = QuestManager()
    @State private var selectedDay: QuestDay?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header card
                headerCard

                // Day list
                VStack(spacing: 12) {
                    ForEach(questManager.days) { day in
                        QuestDayRow(
                            day: day,
                            isCompleted: questManager.isDayCompleted(day.id)
                        )
                        .onTapGesture {
                            selectedDay = day
                        }
                    }
                }
                .padding(.horizontal)

                // Support Score link
                if questManager.completedDays.count > 0 {
                    NavigationLink(destination: SupportScoreView(questManager: questManager)) {
                        HStack {
                            Image(systemName: "heart.text.square")
                                .font(.system(size: 18))
                            Text("View Your Reflection")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "#F2A1A1"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                        )
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 30)
            }
            .padding(.top)
        }
        .background(Color(hex: "#FDEDEB"))
        .navigationTitle("Support Quest")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedDay) { day in
            NavigationStack {
                QuestDayDetailView(day: day, questManager: questManager)
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Support Quest")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text("Small, guided actions to help you show up with empathy — one day at a time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Progress indicator
            HStack(spacing: 6) {
                ForEach(1...7, id: \.self) { dayNum in
                    Circle()
                        .fill(questManager.isDayCompleted(dayNum)
                              ? Color(hex: "#F2A1A1")
                              : Color(hex: "#F2A1A1").opacity(0.2))
                        .frame(width: 10, height: 10)
                        .animation(.easeInOut(duration: 0.3), value: questManager.isDayCompleted(dayNum))
                }
                Spacer()
                Text("\(questManager.completedDays.count) of 7")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Quest Day Row

struct QuestDayRow: View {
    let day: QuestDay
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Day circle
            ZStack {
                Circle()
                    .fill(isCompleted
                          ? Color(hex: "#F2A1A1")
                          : Color(hex: "#F2A1A1").opacity(0.15))
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Text("\(day.id)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#F2A1A1"))
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(day.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(day.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
        )
    }
}

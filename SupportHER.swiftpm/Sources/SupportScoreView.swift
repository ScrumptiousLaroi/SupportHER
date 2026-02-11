import SwiftUI

struct SupportScoreView: View {
    @ObservedObject var questManager: QuestManager
    @State private var showResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Reflective score circle
                scoreCircle
                    .padding(.top, 20)

                // Reflection text
                reflectionCard

                // Days summary
                daysSummaryCard

                // Reset option
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                        Text("Start a New Quest")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#F2A1A1").opacity(0.4), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                Spacer(minLength: 30)
            }
        }
        .background(Color(hex: "#FDEDEB"))
        .navigationTitle("Your Reflection")
        .navigationBarTitleDisplayMode(.large)
        .alert("Start Over?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                withAnimation {
                    questManager.resetQuest()
                }
            }
        } message: {
            Text("This will clear your current progress so you can begin a fresh quest.")
        }
    }

    // MARK: - Score Circle

    private var scoreCircle: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color(hex: "#F2A1A1").opacity(0.15), lineWidth: 8)
                    .frame(width: 120, height: 120)

                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(questManager.supportScore) / 7.0)
                    .stroke(
                        Color(hex: "#F2A1A1"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: questManager.supportScore)

                VStack(spacing: 2) {
                    Text("\(questManager.supportScore)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "#F2A1A1"))
                    Text("of 7")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text("Days Completed")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Reflection Card

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .font(.system(size: 16))
                Text("Reflection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            Text(questManager.supportReflection)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }

    // MARK: - Days Summary

    private var daysSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Journey")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            ForEach(questManager.days) { day in
                HStack(spacing: 12) {
                    Image(systemName: questManager.isDayCompleted(day.id)
                          ? "checkmark.circle.fill"
                          : "circle")
                        .foregroundColor(questManager.isDayCompleted(day.id)
                                         ? Color(hex: "#F2A1A1")
                                         : .gray.opacity(0.4))
                        .font(.system(size: 18))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Day \(day.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(day.title)
                            .font(.system(size: 15))
                            .foregroundColor(questManager.isDayCompleted(day.id)
                                             ? .primary
                                             : .secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }
}

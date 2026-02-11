import SwiftUI

struct QuestDayDetailView: View {
    let day: QuestDay
    @ObservedObject var questManager: QuestManager
    @Environment(\.dismiss) private var dismiss

    private var isCompleted: Bool {
        questManager.isDayCompleted(day.id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Day header
                VStack(spacing: 6) {
                    Text("Day \(day.id)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#F2A1A1"))
                        .fontWeight(.semibold)
                    Text(day.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Action card
                actionCard

                // Conversation starter card
                conversationCard

                // Myth-buster card
                QuestMythCardView(myth: day.myth, fact: day.fact)
                    .padding(.horizontal)

                // Completion button
                completionButton
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }
        .background(Color(hex: "#FDEDEB"))
        .navigationTitle("Day \(day.id)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(Color(hex: "#F2A1A1"))
            }
        }
    }

    // MARK: - Action Card

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .font(.system(size: 16))
                Text("Today's Action")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            Text(day.action)
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

    // MARK: - Conversation Card

    private var conversationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bubble.left.fill")
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .font(.system(size: 16))
                Text("Conversation Starter")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            Text(day.conversationStarter)
                .font(.body)
                .italic()
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

    // MARK: - Completion Button

    private var completionButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                if isCompleted {
                    questManager.undoDayCompletion(day.id)
                } else {
                    questManager.markDayCompleted(day.id)
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                Text(isCompleted ? "Completed" : "I did this today")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(isCompleted ? .white : Color(hex: "#F2A1A1"))
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted
                          ? Color(hex: "#F2A1A1")
                          : Color(hex: "#F2A1A1").opacity(0.1))
            )
        }
    }
}

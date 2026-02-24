import SwiftUI

struct QuestMythCardView: View {
    let myth: String
    let fact: String
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .font(.system(size: 16))
                Text("Myth vs. Fact")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            // Myth
            VStack(alignment: .leading, spacing: 6) {
                Text("Myth")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red.opacity(0.7))
                Text(myth)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Fact (tap to reveal)
            if isRevealed {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fact")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green.opacity(0.8))
                    Text(fact)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isRevealed = true
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                            .font(.system(size: 14))
                        Text("Tap to reveal the fact")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color(hex: "#F2A1A1"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#F2A1A1").opacity(0.1))
                    )
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
    }
}

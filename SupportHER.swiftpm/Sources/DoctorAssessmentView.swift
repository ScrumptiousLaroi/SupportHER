import SwiftUI

// MARK: - Data Models

struct AssessmentQuestion: Identifiable {
    let id = UUID()
    let question: String
    let riskScore: Int // Weight when answered "Yes"
}

enum RiskLevel {
    case low
    case moderate
    case high
    
    var title: String {
        switch self {
        case .low: return "Symptoms Seem Normal"
        case .moderate: return "Consider a Doctor Visit"
        case .high: return "Consult a Doctor Soon"
        }
    }
    
    var message: String {
        switch self {
        case .low:
            return "Based on your responses, symptoms appear to be within normal range. Continue monitoring and refer to the Care Plan for support strategies."
        case .moderate:
            return "Some symptoms may warrant attention. Consider scheduling a routine doctor visit to discuss these changes with a healthcare provider."
        case .high:
            return "It would be wise to consult a doctor soon to discuss these symptoms. Professional medical evaluation can help ensure everything is okay."
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "cross.case.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

// MARK: - ViewModel

class DoctorAssessmentViewModel: ObservableObject {
    @Published var hasStarted = false
    @Published var currentQuestionIndex = 0
    @Published var answers: [UUID: Bool] = [:] // questionId : answered Yes
    @Published var showingResult = false
    
    let questions: [AssessmentQuestion] = [
        AssessmentQuestion(question: "Has she experienced extremely heavy bleeding (soaking through a pad or tampon in under 2 hours)?", riskScore: 3),
        AssessmentQuestion(question: "Is she experiencing severe pain that doesn't improve with over-the-counter medication?", riskScore: 3),
        AssessmentQuestion(question: "Has she fainted or felt extremely dizzy during her period?", riskScore: 3),
        AssessmentQuestion(question: "Does she have a fever alongside period symptoms?", riskScore: 3),
        AssessmentQuestion(question: "Has her period lasted more than 8 days?", riskScore: 2),
        AssessmentQuestion(question: "Are her periods coming less than 21 days apart?", riskScore: 2),
        AssessmentQuestion(question: "Has there been any bleeding after sexual intercourse?", riskScore: 3),
        AssessmentQuestion(question: "Have her period patterns suddenly changed significantly?", riskScore: 2)
    ]
    
    var totalScore: Int {
        var score = 0
        for question in questions {
            if answers[question.id] == true {
                score += question.riskScore
            }
        }
        return score
    }
    
    var riskLevel: RiskLevel {
        let score = totalScore
        if score >= 7 {
            return .high
        } else if score >= 4 {
            return .moderate
        } else {
            return .low
        }
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    func answerQuestion(answer: Bool) {
        answers[questions[currentQuestionIndex].id] = answer
        
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            withAnimation {
                showingResult = true
            }
        }
    }
    
    func reset() {
        withAnimation {
            hasStarted = false
            currentQuestionIndex = 0
            answers.removeAll()
            showingResult = false
        }
    }
}

// MARK: - Main View

struct DoctorAssessmentView: View {
    @StateObject private var viewModel = DoctorAssessmentViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.white)
                .shadow(radius: 5)
            
            VStack(spacing: 0) {
                // Header
                Text("When to See a Doctor")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !viewModel.hasStarted {
                    StartScreen(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                } else if !viewModel.showingResult {
                    QuestionView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    ResultView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .frame(minHeight: 400)
    }
}

// MARK: - Start Screen

struct StartScreen: View {
    @ObservedObject var viewModel: DoctorAssessmentViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Image(systemName: "stethoscope")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#F2A1A1"))
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            
            // Description
            VStack(spacing: 12) {
                Text("Symptom Assessment")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Answer a few questions to help determine if medical consultation may be needed.\n\nThis is not a diagnostic tool.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 30)
            
            // Start button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    viewModel.hasStarted = true
                }
            }) {
                HStack {
                    Text("Start Assessment")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#F2A1A1"),
                            Color(hex: "#F2A1A1").opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color(hex: "#F2A1A1").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .padding(.horizontal, 30)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Question View

struct QuestionView: View {
    @ObservedObject var viewModel: DoctorAssessmentViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color(hex: "#F2A1A1"))
                            .frame(width: geometry.size.width * viewModel.progress, height: 4)
                            .animation(.easeInOut, value: viewModel.progress)
                    }
                    .cornerRadius(2)
                }
                .frame(height: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Question
            Text(viewModel.questions[viewModel.currentQuestionIndex].question)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            
            // Answer buttons
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.answerQuestion(answer: false)
                }) {
                    Text("No")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    viewModel.answerQuestion(answer: true)
                }) {
                    Text("Yes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#F2A1A1"))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Result View

struct ResultView: View {
    @ObservedObject var viewModel: DoctorAssessmentViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Risk level icon and title
            VStack(spacing: 12) {
                Image(systemName: viewModel.riskLevel.icon)
                    .font(.system(size: 50))
                    .foregroundColor(viewModel.riskLevel.color)
                    .padding(.top, 20)
                
                Text(viewModel.riskLevel.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Message
            Text(viewModel.riskLevel.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Disclaimer
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    
                    Text("Important Disclaimer")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Text("This assessment tool does not provide medical diagnosis and should not replace professional medical advice, diagnosis, or treatment. If you have concerns about symptoms, please consult a qualified healthcare provider.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 20)
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.reset()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Retake Assessment")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#F2A1A1"))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Spacer()
        }
    }
}

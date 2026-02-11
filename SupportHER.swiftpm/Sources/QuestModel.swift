import SwiftUI

// MARK: - Quest Day Data Model

struct QuestDay: Identifiable {
    let id: Int // Day number 1–7
    let title: String
    let action: String
    let conversationStarter: String
    let myth: String
    let fact: String
    var isCompleted: Bool = false
}

// MARK: - Quest Manager (State Persistence)

@MainActor
class QuestManager: ObservableObject {
    @AppStorage("questCompletedDaysData") private var completedDaysData: Data = Data()
    @AppStorage("questStartDate") private var questStartTimestamp: Double = 0

    @Published var completedDays: Set<Int> = [] {
        didSet { persistCompletedDays() }
    }

    var questStartDate: Date? {
        questStartTimestamp > 0 ? Date(timeIntervalSince1970: questStartTimestamp) : nil
    }

    // Static content — 7 curated days
    let days: [QuestDay] = [
        QuestDay(
            id: 1,
            title: "A Warm Beginning",
            action: "Offer a warm drink — tea, cocoa, or warm water — without being asked. Pair it with one gentle question: \"How are you feeling today?\"",
            conversationStarter: "\"Is there anything that would make today a little easier for you?\"",
            myth: "People on their period are always in a bad mood.",
            fact: "Mood changes vary widely. Many people feel fine, and emotional shifts are a normal hormonal response — not a personality flaw."
        ),
        QuestDay(
            id: 2,
            title: "The Power of Listening",
            action: "Set aside 10 quiet minutes today. Sit nearby, put your phone away, and simply listen if she wants to talk. No fixing, no advice — just presence.",
            conversationStarter: "\"I'm here if you want to talk, and it's also okay if you don't.\"",
            myth: "You should avoid talking about periods — it's too private.",
            fact: "Open, respectful conversation reduces stigma and builds trust. Most people appreciate a partner who is comfortable discussing it."
        ),
        QuestDay(
            id: 3,
            title: "Small Acts, Big Impact",
            action: "Take one daily task off her plate today — dishes, cooking, laundry, or tidying up. Don't announce it; just do it quietly.",
            conversationStarter: "\"What's one thing on your to-do list I can take care of today?\"",
            myth: "Period pain isn't that serious — she's exaggerating.",
            fact: "Menstrual cramps (dysmenorrhea) can range from mild to debilitating. Studies compare severe cramps to the pain of a heart attack."
        ),
        QuestDay(
            id: 4,
            title: "Comfort Without Words",
            action: "Prepare a simple comfort kit: a heating pad or warm towel, a favorite snack, and a cozy blanket. Leave it where she can find it.",
            conversationStarter: "\"I put a little something together for you — no need to say anything, just enjoy it.\"",
            myth: "Exercise during periods is harmful and should be avoided.",
            fact: "Gentle exercise like walking or stretching can actually reduce cramps and improve mood through natural endorphin release."
        ),
        QuestDay(
            id: 5,
            title: "Understanding the Rhythm",
            action: "Spend a few minutes today learning about the four phases of the menstrual cycle. Understanding the rhythm helps you anticipate needs, not react to them.",
            conversationStarter: "\"I've been reading about cycle phases — I had no idea how much changes throughout the month. Can you tell me what it's like for you?\"",
            myth: "The menstrual cycle is just the period — the bleeding days.",
            fact: "The period is only one of four phases. The full cycle includes follicular, ovulatory, and luteal phases — each with distinct physical and emotional changes."
        ),
        QuestDay(
            id: 6,
            title: "Emotional Check-In",
            action: "Ask one thoughtful question today — and then wait. Give space for the answer without rushing or filling the silence.",
            conversationStarter: "\"On a scale of 1 to 10, how supported do you feel this week? I want to do better.\"",
            myth: "Hormonal changes only affect women during their period.",
            fact: "Hormonal fluctuations happen throughout the entire cycle, influencing energy, sleep, appetite, and mood — not just during menstruation."
        ),
        QuestDay(
            id: 7,
            title: "Reflecting Together",
            action: "Write a short note — on paper or in a message — sharing one thing you've learned this week and one thing you appreciate about her strength.",
            conversationStarter: "\"This week taught me something. I wanted to share it with you.\"",
            myth: "Being supportive during periods means treating her like she's sick.",
            fact: "Support means being present, respectful, and attentive — not treating someone as fragile. Empathy and partnership go much further than pity."
        )
    ]

    // MARK: - Computed Properties

    var supportScore: Int {
        completedDays.count
    }

    var supportReflection: String {
        switch completedDays.count {
        case 0:
            return "Your quest hasn't started yet. Take your time — every small step matters."
        case 1...2:
            return "You've taken your first steps. Showing up is what counts most."
        case 3...4:
            return "You're building a meaningful habit of care. That takes real intention."
        case 5...6:
            return "Your commitment to understanding and supporting is making a difference."
        case 7:
            return "You completed the full quest. This kind of empathy and effort is rare and deeply valued."
        default:
            return ""
        }
    }

    var isQuestComplete: Bool {
        completedDays.count == 7
    }

    // MARK: - Init

    init() {
        loadCompletedDays()
    }

    // MARK: - Actions

    func markDayCompleted(_ dayId: Int) {
        if questStartTimestamp == 0 {
            questStartTimestamp = Date().timeIntervalSince1970
        }
        completedDays.insert(dayId)
    }

    func undoDayCompletion(_ dayId: Int) {
        completedDays.remove(dayId)
    }

    func isDayCompleted(_ dayId: Int) -> Bool {
        completedDays.contains(dayId)
    }

    func resetQuest() {
        completedDays.removeAll()
        questStartTimestamp = 0
    }

    // MARK: - Persistence Helpers

    private func persistCompletedDays() {
        if let data = try? JSONEncoder().encode(Array(completedDays)) {
            completedDaysData = data
        }
    }

    private func loadCompletedDays() {
        if let decoded = try? JSONDecoder().decode([Int].self, from: completedDaysData) {
            completedDays = Set(decoded)
        }
    }
}

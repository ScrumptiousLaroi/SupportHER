//
//  File.swift
//  SupportHER
//
//  Created by Puru Thakur on 09/02/25.
//

import SwiftUI

// structure for card data
struct Card: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct MythFact: Identifiable {
    let id = UUID()
    let myth: String
    let fact: String
}


struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct DoctorVisitIndicator: Identifiable {
    let id = UUID()
    let condition: String
}

struct View2: View {
    // feeding in the data in cards structure variable and setting and index to track the slideshow
    @State private var currentIndex = 0
    private let cards = [
        Card(image: "image1", title: "Overview", description: "You’ll learn what the menstrual cycle is, how it works, and why its length varies among individuals."),
        Card(image: "image2", title: "What is menstrual Cycle?", description: "The menstrual cycle is a natural process that happens every month to prepare a woman’s body for pregnancy."),
        Card(image: "image3", title: "How does it work?", description: "It starts on the first day of a woman’s period (bleeding). It ends the day before the next period begins."),
        Card(image: "image4", title: "How long does it last, and why does its duration vary?", description: "The menstrual cycle averages 28 days but can vary—teenagers may have cycles up to 45 days, while adults in their 20s-30s typically range from 21-38 days. These differences depend on age, health, and lifestyle, making each cycle unique and natural."),
        Card(image: "image5", title: "Phases of menstrual cycle", description: "Now you will learn about phases of menstrual cycle"),
        Card(image: "image6", title: "Your period (menstruation)", description: "During a period, the lining of the uterus sheds and exits the body through the vagina. The menstrual flow consists of blood, mucus, and cells from the uterine lining. On average, a period lasts between 3 to 7 days."),
        Card(image: "image7", title: "Follicular Phase", description: "The follicular phase begins on the first day of a period and lasts for 13 to 14 days. During this phase, changing hormone levels cause the uterine lining to thicken and follicles to develop on the surface of the ovaries. Typically, only one follicle matures into an egg."),
        Card(image: "image8", title: "Ovulation", description: "Ovulation occurs when a mature egg is released from an ovary, typically happening once a month about two weeks before the next period. Pregnancy is most likely to occur if unprotected sex takes place around the time of ovulation."),
        Card(image: "image9", title: "Luteal Phase", description: "After ovulation, the egg travels through the fallopian tubes to the uterus. During this time, the uterine lining continues to thicken in preparation for a possible pregnancy.If pregnancy occurs, the menstrual cycle pauses, and a period does not happen. If pregnancy does not occur, the lining is shed during a period, and the menstrual cycle begins again.")
        
    ]
    
    //myths and facts data
    private let mythsAndFacts = [
        MythFact(myth: "Only teenage girls get periods",
                fact: "Menstruation typically begins between ages 10-15 and continues until menopause around age 45-55"),
        MythFact(myth: "Exercise during periods is harmful",
                fact: "Exercise can actually help reduce period pain and improve mood through endorphin release"),
        MythFact(myth: "Women shouldn't shower during periods",
                fact: "Regular bathing during periods is essential for hygiene and can help with cramps"),
        MythFact(myth: "Women shouldn't visit sacred places",
                 fact: "There is nothing impure about periods, It is a natural process"),
        MythFact(myth: "They should sleep in a seperate room", fact: "Menstruation is not contagious and causes no harm to people in same room")

    ]
    
    // FAQ data
    private let faqs = [
        FAQ(question: "How often should someone change their pad/tampon?",
            answer: "They should change their pad every 4-6 hours and tampon every 4-8 hours to maintain hygiene and prevent infections."),
        FAQ(question: "Is it normal to have irregular periods?",
            answer: "Yes, it's normal to have irregular periods, especially during the first few years after starting menstruation or approaching menopause."),
        FAQ(question: "Can someone get pregnant during their period?",
            answer: "Yes, while it's less likely, they can still get pregnant during their period, especially if they have irregular cycles."),
        FAQ(question: "Why do you get cramps during periods?",
            answer: "Cramps occur because your uterus contracts to help shed its lining. This is a normal part of the menstrual process."),
        FAQ(question: "What helps with period pain?",
            answer: "Exercise, heat therapy, over-the-counter pain medication, and staying hydrated can help manage period pain.")
    ]
    
    // when to see your doctor data
    private let doctorVisitIndicators = [
        DoctorVisitIndicator(condition: "Their period patterns change"),
        DoctorVisitIndicator(condition: "Their periods are getting heavier (i.e. they needs to change their pad or tampon more often than every 2 hours)"),
        DoctorVisitIndicator(condition: "Periods last more than 8 days"),
        DoctorVisitIndicator(condition: "Periods come less than 21 days apart"),
        DoctorVisitIndicator(condition: "Periods come more than 2 to 3 months apart"),
        DoctorVisitIndicator(condition: "Your partner bled after sexual intercourse")
    ]
    
    //expanded states tracking
    @State private var expandedId: UUID?
    @State private var expandedMythId: UUID?
    @State private var expandedFaqId: UUID?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack { // menstruation in slides
                    CardView(card: cards[currentIndex])
                        .transition(.asymmetric(insertion: .move(edge: .trailing),
                                               removal: .move(edge: .leading)))
                    
                    HStack {
                        Button(action: previousCard) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .opacity(currentIndex > 0 ? 1 : 0.3)
                        .disabled(currentIndex == 0)
                        
                        Spacer()
                        
                        Button(action: nextCard) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .opacity(currentIndex < cards.count - 1 ? 1 : 0.3)
                        .disabled(currentIndex == cards.count - 1)
                    }
                    .padding(.horizontal)
                }
                .padding()
                
                ZStack(alignment: .top) { // Myths and Facts Box
                   
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                  
                        Text("Myths and Facts")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 16)
                            .padding(.leading, 20)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(mythsAndFacts) { item in
                                    MythFactItemView(
                                        myth: item.myth,
                                        fact: item.fact,
                                        isExpanded: expandedMythId == item.id
                                    ) {
                                        withAnimation(.spring()) {
                                            expandedMythId = expandedMythId == item.id ? nil : item.id
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .frame(minHeight: 200) // Minimum height when collapsed
                .padding()
                
                ZStack(alignment: .top) { // FAQ Box
                  
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                      
                        Text("Frequently Asked Questions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 16)
                            .padding(.leading, 20)
                        
                      
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(faqs) { item in
                                    FAQItemView(
                                        question: item.question,
                                        answer: item.answer,
                                        isExpanded: expandedFaqId == item.id
                                    ) {
                                        withAnimation(.spring()) {
                                            expandedFaqId = expandedFaqId == item.id ? nil : item.id
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .frame(minHeight: 310) // min height in collapsed state
                .padding()
                
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When to see your doctor")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 16)
                            .padding(.leading, 20)
                        
                        Text("Talk to a doctor if you are worried about their periods. For example, if:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(doctorVisitIndicators) { indicator in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.primary)
                                        Text(indicator.condition)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .frame(minHeight: 310)
                .padding()
            }
        }
        .background(Color(hex: "#FDEDEB"))
    }
    

    private func nextCard() {
        withAnimation {
            currentIndex = min(currentIndex + 1, cards.count - 1)
        }
    }
    
    private func previousCard() {
        withAnimation {
            currentIndex = max(currentIndex - 1, 0)
        }
    }
}


struct CardView: View { // for menstruation in slides card
    let card: Card
    
    var body: some View {
        VStack(spacing: 12) {
            Image(card.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
            
            Text(card.title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.trailing)
            
            Text(card.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}


struct MythFactItemView: View { // myths and facts car
    let myth: String
    let fact: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onTap) {
                HStack {
                    Text(myth)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(fact)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
        .padding(8)
        .background(Color(hex: "#FDEDEB").opacity(0.3))
        .cornerRadius(8)
    }
}

//FAQItemView
struct FAQItemView: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onTap) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            }
        }
        .padding(8)
        .background(Color(hex: "#FDEDEB").opacity(0.3))
        .cornerRadius(8)
    }
}

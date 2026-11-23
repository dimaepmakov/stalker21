import SwiftUI
import SwiftData

struct TodayView: View {
    @Bindable var profile: PlayerProfile
    @Query private var completed: [CompletedQuest]

    var body: some View {
        let today = Planner.dayKey(Date())
        // План не должен «прыгать» в течение дня, поэтому сегодняшние выполнения не учитываем
        let doneBefore = Set(completed.filter { $0.dayKey != today }.map(\.questID))
        let doneToday = Set(completed.filter { $0.dayKey == today }.map(\.questID))
        let plan = Planner.plan(date: Date(), grade: profile.grade,
                                scheduleText: profile.scheduleText,
                                doneIDs: doneBefore, lastActiveKey: profile.lastActiveKey)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    Text(plan.note)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))

                    ForEach(plan.quests) { q in
                        let isDone = doneToday.contains(q.id)
                        NavigationLink(value: q) {
                            QuestCard(quest: q,
                                      badge: isDone ? "✓" : (q.id == plan.mainID ? "ГЛАВНЫЙ" : "БОНУС"),
                                      done: isDone)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDone)
                    }

                    if !plan.quests.isEmpty && plan.quests.allSatisfy({ doneToday.contains($0.id) }) {
                        Text("🔥 На сегодня всё. Можно отдыхать без чувства вины.")
                            .foregroundStyle(Neon.green)
                            .neonCard(Neon.green)
                    }
                }
                .padding()
            }
            .background(Neon.bg.ignoresSafeArea())
            .navigationTitle("Сегодня")
            .navigationDestination(for: Quest.self) { q in
                QuestView(quest: q, profile: profile)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(profile.name) · \(profile.rank)")
                    .font(.headline).foregroundStyle(.white)
                Spacer()
                Text("🔥 \(profile.streakDays)").foregroundStyle(Neon.yellow)
                Text("🪙 \(profile.coins)").foregroundStyle(Neon.yellow)
            }
            ProgressView(value: Double(profile.xpInLevel), total: 100)
                .tint(Neon.green)
            Text("Уровень \(profile.level) · \(profile.xpInLevel)/100 XP")
                .font(.caption).foregroundStyle(.white.opacity(0.7))
        }
        .neonCard(Neon.green)
    }
}

struct QuestCard: View {
    let quest: Quest
    let badge: String
    let done: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(quest.subject.emoji).font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.subject.location)
                    .font(.caption).foregroundStyle(quest.subject.color)
                Text(quest.title)
                    .font(.headline).foregroundStyle(.white)
                Text("\(quest.kind == .notebook ? "📓 В тетради" : "⚡️ Быстрый тест") · \(quest.minutes) мин · \(quest.xp) XP")
                    .font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Text(badge)
                .font(.caption.bold())
                .foregroundStyle(done ? Neon.green : Neon.yellow)
        }
        .neonCard(done ? Neon.green : quest.subject.color)
        .opacity(done ? 0.55 : 1)
    }
}

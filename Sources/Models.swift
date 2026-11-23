import Foundation
import SwiftData

@Model
final class PlayerProfile {
    var name: String
    var grade: Int
    var xp: Int
    var coins: Int
    var streakDays: Int
    var wrongStreak: Int
    var lastActiveKey: String
    var scheduleText: String

    init(name: String, grade: Int, scheduleText: String) {
        self.name = name
        self.grade = grade
        self.xp = 0
        self.coins = 0
        self.streakDays = 0
        self.wrongStreak = 0
        self.lastActiveKey = ""
        self.scheduleText = scheduleText
    }

    var level: Int { xp / 100 + 1 }
    var xpInLevel: Int { xp % 100 }

    var rank: String {
        let ranks = ["Новичок", "Бродяга", "Следопыт", "Сталкер", "Проводник", "Легенда Зоны"]
        return ranks[min((level - 1) / 2, ranks.count - 1)]
    }
}

@Model
final class CompletedQuest {
    var questID: String
    var subjectRaw: String
    var dayKey: String
    var xpEarned: Int

    init(questID: String, subjectRaw: String, dayKey: String, xpEarned: Int) {
        self.questID = questID
        self.subjectRaw = subjectRaw
        self.dayKey = dayKey
        self.xpEarned = xpEarned
    }
}

enum Game {
    /// Начисляет награду сразу. Возвращает полученный XP.
    static func complete(_ q: Quest, profile: PlayerProfile, ctx: ModelContext, hinted: Bool) -> Int {
        let qid = q.id
        let repeated = ((try? ctx.fetchCount(
            FetchDescriptor<CompletedQuest>(predicate: #Predicate { $0.questID == qid })
        )) ?? 0) > 0

        var xp = q.xp
        if hinted { xp = max(xp / 2, 5) }
        if repeated { xp = max(xp / 4, 5) }

        let now = Date()
        let today = Planner.dayKey(now)
        let yesterday = Planner.dayKey(Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now)

        profile.xp += xp
        profile.coins += xp / 2
        profile.wrongStreak = 0

        if profile.lastActiveKey == today {
            // уже играл сегодня
        } else if profile.lastActiveKey == yesterday {
            profile.streakDays += 1
        } else {
            profile.streakDays = 1
        }
        profile.lastActiveKey = today

        ctx.insert(CompletedQuest(questID: q.id, subjectRaw: q.subject.rawValue, dayKey: today, xpEarned: xp))
        try? ctx.save()
        return xp
    }
}

import Foundation

enum ScheduleParser {
    static let defaultText = """
    ПН: Разговоры о важном, ин.яз. (41/38), история (37), физ-ра, алгебра (210), физика (211), рус.яз (27)
    ВТ: инф.Дев./труд Мальч., труд Дев./инф.Мальч., химия (212), география (33), геометрия (210), биология (33), лит-ра (27)
    СР: ин.яз. (41/38), алгебра (210), физика (211), рус.яз (27), география (33), литература (27)
    ЧТ: история (37), физика (211), рус.яз. (27), лит-ра (27), химия (212), геометрия (210), вер. и стат. (210)
    ПТ: обзр (38), ин.яз. (23/36), физ-ра, обществ. (26), рус.яз. (27), биология (33), алгебра (210)
    СБ: Выходной
    ВС: Выходной
    """

    private static let dayPrefixes: [(String, Int)] = [
        ("пн", 1), ("вт", 2), ("ср", 3), ("чт", 4), ("пт", 5), ("сб", 6), ("вс", 7)
    ]

    /// Пн = 1 ... Вс = 7
    static func weekdayNumber(_ date: Date) -> Int {
        let w = Calendar.current.component(.weekday, from: date) // 1 = воскресенье
        return (w + 5) % 7 + 1
    }

    static func parse(_ text: String) -> [Int: [Subject]] {
        var result: [Int: [Subject]] = [:]
        for line in text.split(separator: "\n") {
            guard let colon = line.firstIndex(of: ":") else { continue }
            let head = line[..<colon].trimmingCharacters(in: .whitespaces).lowercased()
            guard let num = dayPrefixes.first(where: { head.hasPrefix($0.0) })?.1 else { continue }
            let body = line[line.index(after: colon)...]
            var subjects: [Subject] = []
            for raw in body.split(separator: ",") {
                if let s = subject(from: String(raw)), !subjects.contains(s) {
                    subjects.append(s)
                }
            }
            result[num] = subjects
        }
        return result
    }

    /// nil — предмет без квестов (физ-ра, труд, информатика, ОБЗР, разговоры)
    static func subject(from raw: String) -> Subject? {
        let t = raw.lowercased()
        if t.contains("труд") || t.contains("инф") { return nil }
        if t.contains("физ-ра") || t.contains("физкульт") { return nil }
        if t.contains("обзр") || t.contains("обж") || t.contains("разговор") || t.contains("выходн") { return nil }
        if t.contains("алгебр") { return .algebra }
        if t.contains("геометр") { return .geometry }
        if t.contains("физик") { return .physics }
        if t.contains("рус") { return .russian }
        if t.contains("лит") { return .literature }
        if t.contains("истор") { return .history }
        if t.contains("ин.яз") || t.contains("англ") || t.contains("иностр") { return .english }
        if t.contains("хим") { return .chemistry }
        if t.contains("географ") { return .geography }
        if t.contains("биолог") { return .biology }
        if t.contains("обществ") { return .social }
        if t.contains("вер.") || t.contains("вероят") || t.contains("стат") { return .probability }
        return nil
    }
}

struct DayPlan {
    var quests: [Quest]
    var mainID: String?
    var note: String
    var isWeekend: Bool
}

enum Planner {
    static func dayKey(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    static func plan(date: Date, grade: Int, scheduleText: String,
                     doneIDs: Set<String>, lastActiveKey: String) -> DayPlan {
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .year, for: date) ?? 1
        let wd = ScheduleParser.weekdayNumber(date)
        let table = ScheduleParser.parse(scheduleText)
        let subjects = table[wd] ?? []

        func pick(_ pool: [Quest], _ shift: Int) -> Quest? {
            guard !pool.isEmpty else { return nil }
            let fresh = pool.filter { !doneIDs.contains($0.id) }
            let src = fresh.isEmpty ? pool : fresh
            return src[(day + shift) % src.count]
        }

        func rot(_ a: [Subject]) -> [Subject] {
            guard !a.isEmpty else { return a }
            let r = day % a.count
            return Array(a[r...] + a[..<r])
        }

        // Выходной — один лёгкий квест по желанию
        if wd >= 6 {
            let easy = QuestBank.all.filter { $0.kind == .test }
            let q = pick(easy, 0)
            return DayPlan(quests: q.map { [$0] } ?? [], mainID: nil,
                           note: "Выходной. Один лёгкий квест — только если хочется.",
                           isWeekend: true)
        }

        var quests: [Quest] = []

        let ordered = rot(subjects.filter { $0.isDemo }) + rot(subjects.filter { !$0.isDemo })
        for s in ordered.prefix(2) {
            var pool = QuestBank.all.filter { $0.subject == s && $0.grade == grade }
            if pool.isEmpty { pool = QuestBank.all.filter { $0.subject == s && $0.grade == 9 } }
            if pool.isEmpty { pool = QuestBank.quests(for: s) }
            if let q = pick(pool, 0), !quests.contains(where: { $0.id == q.id }) {
                quests.append(q)
            }
        }

        // Квест на пробел из прошлых классов
        var gap = QuestBank.all.filter { $0.grade < grade }
        if gap.isEmpty { gap = QuestBank.all.filter { $0.grade < 9 } }
        if let q = pick(gap, day * 3 + 1), !quests.contains(where: { $0.id == q.id }) {
            quests.append(q)
        }

        // Без чувства вины: пропуск не удваивает план
        let yesterday = dayKey(cal.date(byAdding: .day, value: -1, to: date) ?? date)
        let missed = !lastActiveKey.isEmpty && lastActiveKey < yesterday
        let note = missed
            ? "С возвращением! Ничего не накопилось. Сегодня важен только главный квест, остальное — бонус."
            : "План на сегодня. Один квест — уже победа."

        return DayPlan(quests: quests, mainID: quests.first?.id, note: note, isWeekend: false)
    }
}

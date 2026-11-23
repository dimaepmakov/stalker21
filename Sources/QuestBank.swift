import SwiftUI

enum Subject: String, CaseIterable, Hashable, Identifiable {
    case algebra, geometry, physics, russian, literature, history, english
    case chemistry, geography, biology, social, probability, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .algebra: return "Алгебра"
        case .geometry: return "Геометрия"
        case .physics: return "Физика"
        case .russian: return "Русский язык"
        case .literature: return "Литература"
        case .history: return "История"
        case .english: return "Английский"
        case .chemistry: return "Химия"
        case .geography: return "География"
        case .biology: return "Биология"
        case .social: return "Обществознание"
        case .probability: return "Вероятность и статистика"
        case .other: return "Прочее"
        }
    }

    var location: String {
        switch self {
        case .algebra: return "Руины Уравнений"
        case .geometry: return "Угловой Бункер"
        case .physics: return "Аномальное Поле"
        case .russian: return "Город Запятых"
        case .literature: return "Библиотека Теней"
        case .history: return "Курган Времён"
        case .english: return "Радиовышка"
        case .chemistry: return "Токсичная Лаборатория"
        case .geography: return "Картографы Пустоши"
        case .biology: return "Мутантный Сад"
        case .social: return "Площадь Совета"
        case .probability: return "Казино Случая"
        case .other: return "—"
        }
    }

    var emoji: String {
        switch self {
        case .algebra: return "🧮"
        case .geometry: return "📐"
        case .physics: return "⚡️"
        case .russian: return "✍️"
        case .literature: return "📚"
        case .history: return "🏛️"
        case .english: return "🌐"
        case .chemistry: return "🧪"
        case .geography: return "🗺️"
        case .biology: return "🧬"
        case .social: return "⚖️"
        case .probability: return "🎲"
        case .other: return "•"
        }
    }

    var color: Color {
        switch self {
        case .algebra, .english, .geography: return Neon.cyan
        case .geometry, .biology, .social: return Neon.pink
        case .physics, .history, .probability: return Neon.yellow
        default: return Neon.green
        }
    }

    /// Предметы с полноценными демо-квестами
    var isDemo: Bool {
        [.algebra, .geometry, .physics, .russian].contains(self)
    }
}

enum QuestKind: String, Hashable {
    case test, notebook
}

struct Quest: Identifiable, Hashable {
    let id: String
    let subject: Subject
    let grade: Int
    let kind: QuestKind
    let title: String
    let text: String
    let options: [String]
    let correct: Int
    let hint: String
    let minutes: Int
    let xp: Int

    static func test(_ id: String, _ s: Subject, _ grade: Int, _ title: String,
                     _ text: String, _ options: [String], _ correct: Int, _ hint: String) -> Quest {
        Quest(id: id, subject: s, grade: grade, kind: .test, title: title, text: text,
              options: options, correct: correct, hint: hint, minutes: 5, xp: 20)
    }

    static func note(_ id: String, _ s: Subject, _ grade: Int, _ title: String,
                     _ text: String, minutes: Int = 10, xp: Int = 40) -> Quest {
        Quest(id: id, subject: s, grade: grade, kind: .notebook, title: title, text: text,
              options: [], correct: 0, hint: "", minutes: minutes, xp: xp)
    }
}

enum QuestBank {
    static let all: [Quest] = demo + stubs

    static func quests(for subject: Subject) -> [Quest] {
        all.filter { $0.subject == subject }
    }

    // MARK: - Демо-контент (алгебра, геометрия, физика, русский)

    static let demo: [Quest] = [
        // АЛГЕБРА
        .test("alg-1", .algebra, 9, "Квадратное уравнение", "Решите: x² − 5x + 6 = 0",
              ["2 и 3", "−2 и −3", "1 и 6", "5 и 6"], 0, "Подбери два числа: сумма 5, произведение 6."),
        .test("alg-2", .algebra, 9, "Дискриминант", "Чему равен дискриминант уравнения x² + 4x + 1 = 0?",
              ["12", "20", "8", "0"], 0, "D = b² − 4ac = 16 − 4·1·1."),
        .test("alg-3", .algebra, 9, "Теорема Виета", "Чему равна сумма корней уравнения x² − 7x + 10 = 0?",
              ["7", "−7", "10", "3"], 0, "По Виета сумма корней = −b/a, то есть противоположна коэффициенту при x."),
        .note("alg-n1", .algebra, 9, "Реши в тетради", "Реши в тетради уравнение 3x² − 12 = 0 и найди оба корня. Запиши решение по шагам."),
        .test("alg-4", .algebra, 8, "Корни", "Сколько будет √144 + √25?",
              ["17", "13", "169", "7"], 0, "√144 = 12, √25 = 5."),
        .test("alg-5", .algebra, 7, "Квадрат суммы", "Раскройте скобки: (a + b)²",
              ["a² + 2ab + b²", "a² + b²", "a² − 2ab + b²", "2a + 2b"], 0, "Не забудь удвоенное произведение."),
        .test("alg-6", .algebra, 6, "Числа со знаком", "Чему равно −7 + 12?",
              ["5", "−5", "19", "−19"], 0, "Из большего модуля вычти меньший и возьми знак большего."),
        .note("alg-n2", .algebra, 8, "Формулы в тетрадь", "Запиши в тетради три формулы сокращённого умножения и для каждой придумай свой числовой пример."),

        // ГЕОМЕТРИЯ
        .test("geo-1", .geometry, 9, "Теорема косинусов", "Какая формула — теорема косинусов?",
              ["c² = a² + b² − 2ab·cos C", "c² = a² + b²", "c = a + b − cos C", "c² = a·b·sin C"], 0,
              "Это Пифагор с поправкой на угол между сторонами."),
        .test("geo-2", .geometry, 9, "Синус", "Чему равен sin 30°?",
              ["1/2", "√3/2", "1", "0"], 0, "Катет напротив 30° равен половине гипотенузы."),
        .test("geo-3", .geometry, 9, "Окружность", "Радиус окружности равен 5. Какова длина окружности?",
              ["10π", "25π", "5π", "20π"], 0, "C = 2πr."),
        .note("geo-n1", .geometry, 9, "Чертёж в тетради", "Начерти в тетради прямоугольный треугольник с катетами 6 и 8. Найди гипотенузу и площадь."),
        .test("geo-4", .geometry, 8, "Пифагор", "Катеты прямоугольного треугольника 3 и 4. Чему равна гипотенуза?",
              ["5", "7", "6", "25"], 0, "c² = 9 + 16."),
        .test("geo-5", .geometry, 7, "Углы треугольника", "Чему равна сумма углов любого треугольника?",
              ["180°", "90°", "360°", "270°"], 0, "Развёрнутый угол."),
        .test("geo-6", .geometry, 6, "Площадь", "Площадь прямоугольника 6 × 7 равна…",
              ["42", "13", "26", "36"], 0, "S = a·b."),

        // ФИЗИКА
        .test("phy-1", .physics, 9, "Второй закон Ньютона", "Какая формула выражает второй закон Ньютона?",
              ["F = ma", "F = mv", "F = m/a", "F = a/m"], 0, "Сила равна массе на ускорение."),
        .test("phy-2", .physics, 9, "Ускорение", "Скорость выросла с 0 до 20 м/с за 4 с. Чему равно ускорение?",
              ["5 м/с²", "80 м/с²", "16 м/с²", "0,2 м/с²"], 0, "a = Δv / t = 20 / 4."),
        .test("phy-3", .physics, 9, "Импульс", "Как вычисляется импульс тела?",
              ["p = mv", "p = m/v", "p = ma", "p = v/t"], 0, "Масса умножить на скорость."),
        .note("phy-n1", .physics, 9, "Таблица в тетради", "В тетради составь таблицу из 5 физических величин: название, обозначение, единица в СИ."),
        .test("phy-4", .physics, 7, "Скорость", "Формула скорости при равномерном движении:",
              ["v = s / t", "v = s · t", "v = t / s", "v = s + t"], 0, "Путь делим на время."),
        .test("phy-5", .physics, 7, "Единицы", "В каких единицах измеряется сила?",
              ["Ньютон", "Джоуль", "Ватт", "Паскаль"], 0, "Назван в честь автора трёх законов механики."),
        .test("phy-6", .physics, 7, "Плотность", "Формула плотности вещества:",
              ["ρ = m / V", "ρ = m · V", "ρ = V / m", "ρ = m + V"], 0, "Масса, делённая на объём."),

        // РУССКИЙ ЯЗЫК
        .test("rus-1", .russian, 9, "Запятая в ССП", "Где правильно поставлена запятая?",
              ["Солнце село, и стало темно.", "Солнце село и, стало темно.",
               "Солнце, село и стало темно.", "Солнце село и стало, темно."], 0,
              "Два простых предложения в одном: перед «и» между ними нужна запятая."),
        .test("rus-2", .russian, 9, "Грамматические основы", "Сколько грамматических основ в предложении: «Когда стемнело, мы пошли домой, и город затих»?",
              ["3", "1", "2", "4"], 0, "Стемнело; мы пошли; город затих."),
        .test("rus-3", .russian, 9, "НЕ с прилагательными", "Как пишется: (не)высокий, а низкий?",
              ["Раздельно", "Слитно"], 0, "Есть противопоставление с «а» — пишем раздельно."),
        .note("rus-n1", .russian, 9, "Спиши и разбери", "Спиши в тетрадь три сложных предложения из любого текста, расставь запятые и подчеркни грамматические основы."),
        .test("rus-4", .russian, 8, "Проверяемая гласная", "Какая буква пропущена: з_лёный?",
              ["Е", "А", "И"], 0, "Проверочное слово: зелень."),
        .test("rus-5", .russian, 7, "Причастие", "Какая часть речи слово «бегущий»?",
              ["Причастие", "Прилагательное", "Глагол", "Деепричастие"], 0,
              "Отвечает на вопрос «какой?» и обозначает признак по действию.")
    ]

    // MARK: - Заглушки для остальных предметов (тетрадные квесты)

    static let stubSubjects: [Subject] = [
        .literature, .history, .english, .chemistry, .geography, .biology, .social, .probability
    ]

    static var stubs: [Quest] {
        stubSubjects.flatMap { s in
            [
                Quest.note("\(s.rawValue)-stub-9", s, 9, "Конспект за 5 минут",
                           "Открой тетрадь. Вспомни тему последнего урока по предмету «\(s.title)» и запиши 3 главных тезиса своими словами. Полноценные квесты по этому предмету скоро появятся.",
                           minutes: 5, xp: 30),
                Quest.note("\(s.rawValue)-stub-7", s, 7, "Заделать пробел",
                           "Открой учебник за 7 класс по предмету «\(s.title)», выбери любой параграф и выпиши в тетрадь 3 термина с определениями.",
                           minutes: 10, xp: 40)
            ]
        }
    }
}

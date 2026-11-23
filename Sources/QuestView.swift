import SwiftUI
import SwiftData

struct QuestView: View {
    let quest: Quest
    @Bindable var profile: PlayerProfile
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var wrongPicked: Set<Int> = []
    @State private var hidden: Set<Int> = []
    @State private var usedHint = false
    @State private var earned: Int? = nil
    @State private var praise = ""

    var body: some View {
        ZStack {
            Neon.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    Text(quest.text)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    if quest.kind == .test {
                        optionsView
                    } else {
                        notebookView
                    }
                    if usedHint && quest.kind == .test {
                        Text("💡 Подсказка: \(quest.hint)")
                            .foregroundStyle(Neon.yellow)
                            .neonCard(Neon.yellow)
                    }
                }
                .padding()
            }
            if let xp = earned {
                rewardOverlay(xp)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: earned)
        .sensoryFeedback(.error, trigger: wrongPicked.count)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(quest.subject.emoji).font(.system(size: 40))
            VStack(alignment: .leading, spacing: 2) {
                Text(quest.subject.location)
                    .font(.caption).foregroundStyle(quest.subject.color)
                Text(quest.title)
                    .font(.headline).foregroundStyle(.white)
            }
            Spacer()
            Text("\(quest.minutes) мин\n\(quest.xp) XP")
                .font(.caption).multilineTextAlignment(.trailing)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var optionsView: some View {
        VStack(spacing: 10) {
            ForEach(quest.options.indices, id: \.self) { i in
                if !hidden.contains(i) {
                    Button { choose(i) } label: {
                        Text(quest.options[i])
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .neonCard(wrongPicked.contains(i) ? Neon.pink : Neon.cyan)
                    .opacity(wrongPicked.contains(i) ? 0.45 : 1)
                    .disabled(wrongPicked.contains(i) || earned != nil)
                }
            }
            if !wrongPicked.isEmpty && earned == nil {
                Text("Мимо. Ничего страшного — пробуй ещё.")
                    .foregroundStyle(Neon.pink)
            }
            if !usedHint && earned == nil {
                Button("Нужна подсказка? (награда ÷ 2)") { usedHint = true }
                    .font(.footnote)
                    .foregroundStyle(Neon.yellow)
            }
        }
    }

    private var notebookView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Возьми тетрадь и ручку. ~\(quest.minutes) мин.", systemImage: "pencil")
                .foregroundStyle(Neon.yellow)
            Text("Сделай задание на бумаге, потом жми кнопку. Мы верим тебе на слово 🤝")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
            Button("Готово — сделал(а) в тетради ✅") { finishNotebook() }
                .buttonStyle(NeonButtonStyle(color: Neon.green))
                .disabled(earned != nil)
        }
    }

    private func rewardOverlay(_ xp: Int) -> some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("🏆").font(.system(size: 64))
                Text("+\(xp) XP")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Neon.green)
                Text("+\(xp / 2) 🪙")
                    .font(.title2.bold())
                    .foregroundStyle(Neon.yellow)
                Text(praise).foregroundStyle(.white.opacity(0.8))
                Button("Дальше") { dismiss() }
                    .buttonStyle(NeonButtonStyle(color: Neon.green))
            }
            .neonCard(Neon.green)
            .padding()
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func choose(_ i: Int) {
        guard earned == nil else { return }
        if i == quest.correct {
            reward()
        } else {
            wrongPicked.insert(i)
            profile.wrongStreak += 1
            // Адаптивность: 2 ошибки подряд — подсказка и меньше вариантов
            if profile.wrongStreak >= 2 {
                usedHint = true
                let wrongs = quest.options.indices.filter {
                    $0 != quest.correct && !wrongPicked.contains($0) && !hidden.contains($0)
                }
                if wrongs.count > 1, let r = wrongs.first {
                    hidden.insert(r)
                }
            }
        }
    }

    private func finishNotebook() {
        guard earned == nil else { return }
        reward()
    }

    private func reward() {
        let xp = Game.complete(quest, profile: profile, ctx: ctx, hinted: usedHint)
        praise = ["Чисто сработано, сталкер!", "Так держать!", "Ещё один шаг по Пустоши.", "Лут твой!"]
            .randomElement() ?? "Отлично!"
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            earned = xp
        }
    }
}

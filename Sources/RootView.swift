import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [PlayerProfile]

    var body: some View {
        if let p = profiles.first {
            TabView {
                TodayView(profile: p)
                    .tabItem { Label("Сегодня", systemImage: "bolt.fill") }
                MapView(profile: p)
                    .tabItem { Label("Карта", systemImage: "map.fill") }
                ProfileView(profile: p)
                    .tabItem { Label("Профиль", systemImage: "person.fill") }
            }
            .tint(Neon.green)
        } else {
            OnboardingView()
        }
    }
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var ctx
    @State private var name = ""
    @State private var grade = 9
    @State private var schedule = ScheduleParser.defaultText

    var body: some View {
        ZStack {
            Neon.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("СТАЛКЕР ЗНАНИЙ")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Neon.green)
                        .shadow(color: Neon.green.opacity(0.7), radius: 10)
                    Text("Пустошь незнания ждёт. Квесты по 5–15 минут, награда сразу.")
                        .foregroundStyle(.white.opacity(0.8))

                    TextField("Позывной (имя)", text: $name)
                        .foregroundStyle(.white)
                        .neonCard(Neon.pink)

                    Text("Класс").foregroundStyle(Neon.cyan)
                    Picker("Класс", selection: $grade) {
                        ForEach(6...9, id: \.self) { g in
                            Text("\(g)").tag(g)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Расписание (можно поправить)").foregroundStyle(Neon.cyan)
                    TextEditor(text: $schedule)
                        .scrollContentBackground(.hidden)
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .frame(minHeight: 300)
                        .neonCard(Neon.cyan)

                    Button("Войти в Зону") { start() }
                        .buttonStyle(NeonButtonStyle(color: Neon.green))
                }
                .padding()
            }
        }
    }

    private func start() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let p = PlayerProfile(name: trimmed.isEmpty ? "Сталкер" : trimmed,
                              grade: grade, scheduleText: schedule)
        ctx.insert(p)
        try? ctx.save()
    }
}

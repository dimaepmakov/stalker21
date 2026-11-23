import SwiftUI
import SwiftData

struct MapView: View {
    @Bindable var profile: PlayerProfile
    @Query private var completed: [CompletedQuest]

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    private var subjects: [Subject] { Subject.allCases.filter { $0 != .other } }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(subjects) { s in
                        let count = completed.filter { $0.subjectRaw == s.rawValue }.count
                        NavigationLink(value: s) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(s.emoji).font(.system(size: 34))
                                Text(s.location)
                                    .font(.subheadline.bold()).foregroundStyle(.white)
                                Text(s.title)
                                    .font(.caption).foregroundStyle(s.color)
                                Text("Ур. \(count / 3 + 1) · квестов: \(count)")
                                    .font(.caption2).foregroundStyle(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .neonCard(s.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Neon.bg.ignoresSafeArea())
            .navigationTitle("Карта Зоны")
            .navigationDestination(for: Subject.self) { s in
                SubjectQuestsView(subject: s)
            }
            .navigationDestination(for: Quest.self) { q in
                QuestView(quest: q, profile: profile)
            }
        }
    }
}

struct SubjectQuestsView: View {
    let subject: Subject

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(QuestBank.quests(for: subject)) { q in
                    NavigationLink(value: q) {
                        QuestCard(quest: q, badge: "\(q.grade) кл.", done: false)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Neon.bg.ignoresSafeArea())
        .navigationTitle(subject.location)
    }
}

struct ProfileView: View {
    @Bindable var profile: PlayerProfile
    @Query private var completed: [CompletedQuest]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(profile.name)
                            .font(.title.bold()).foregroundStyle(.white)
                        Text("\(profile.rank) · уровень \(profile.level)")
                            .foregroundStyle(Neon.green)
                        ProgressView(value: Double(profile.xpInLevel), total: 100)
                            .tint(Neon.green)
                        Text("\(profile.xpInLevel)/100 XP до следующего уровня")
                            .font(.caption).foregroundStyle(.white.opacity(0.7))
                    }
                    .neonCard(Neon.green)

                    HStack(spacing: 12) {
                        stat("🪙", "\(profile.coins)", "монеты")
                        stat("🔥", "\(profile.streakDays)", "дней подряд")
                        stat("✅", "\(completed.count)", "квестов")
                    }

                    NavigationLink {
                        ScheduleEditor(profile: profile)
                    } label: {
                        HStack {
                            Text("📅 Расписание").foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Neon.cyan)
                        }
                        .neonCard(Neon.cyan)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background(Neon.bg.ignoresSafeArea())
            .navigationTitle("Профиль")
        }
    }

    private func stat(_ emoji: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.title2)
            Text(value).font(.title3.bold()).foregroundStyle(.white)
            Text(label).font(.caption2).foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .neonCard(Neon.yellow)
    }
}

struct ScheduleEditor: View {
    @Bindable var profile: PlayerProfile

    var body: some View {
        VStack(spacing: 12) {
            Text("Формат: «ПН: предмет, предмет». План строится по этому тексту.")
                .font(.footnote).foregroundStyle(.white.opacity(0.7))
            TextEditor(text: $profile.scheduleText)
                .scrollContentBackground(.hidden)
                .font(.footnote)
                .foregroundStyle(.white)
                .neonCard(Neon.cyan)
            Button("Вернуть расписание по умолчанию") {
                profile.scheduleText = ScheduleParser.defaultText
            }
            .buttonStyle(NeonButtonStyle(color: Neon.cyan))
        }
        .padding()
        .background(Neon.bg.ignoresSafeArea())
        .navigationTitle("Расписание")
    }
}

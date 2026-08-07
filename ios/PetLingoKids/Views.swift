import SwiftUI

enum Screen: Hashable {
    case categories
    case levels
    case learn(String)
    case quiz(Int)
    case daily
    case growth
    case parent
    case achievements
}

struct RootView: View {
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .categories: CategoryView(path: $path)
                    case .levels: LevelMapView(path: $path)
                    case .learn(let category): LearningView(category: category)
                    case .quiz(let level): QuizView(level: level, path: $path)
                    case .daily: DailyTaskView(path: $path)
                    case .growth: PetGrowthView()
                    case .parent: ParentView()
                    case .achievements: AchievementsView()
                    }
                }
        }
        .tint(.pink)
    }
}

struct HomeView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var heroScale = 1.0
    @State private var message = "點點黑糖、偶貴或熊熊，看看牠們會說什麼！"

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 8) {
                    Text("PetLingo Kids")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.blue)
                    Text("一起開心學英文！")
                        .font(.title3.bold())

                    ZStack {
                        Image("home_hero")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .scaleEffect(heroScale)

                        HStack(spacing: 0) {
                            petTapArea("黑糖說，你真棒，繼續加油", visual: "黑糖送你一顆勇氣星星！⭐")
                            petTapArea("偶貴說，一起開始闖關吧", visual: "偶貴想和你一起挑戰下一關！🎮")
                            petTapArea("熊熊說，今天也要開心學英文", visual: "熊熊說：今天也要開心學英文！🌈")
                        }
                    }

                    Button {
                        speech.speak(message, chinese: true)
                    } label: {
                        Text(message)
                            .font(.subheadline.bold())
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    HStack {
                        Label("\(progress.stars)", systemImage: "star.fill")
                        Spacer()
                        Text("第 \(min(progress.unlockedLevel, 20)) 關").bold()
                        Spacer()
                        Text("今日 \(min(progress.todayCount, 5))/5").bold()
                    }
                    .foregroundStyle(.orange)
                }
                .padding()
                .background(Color.cyan.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 30))

                ProgressCard(path: $path)

                homeButton("🎮", "開始闖關", "20 個關卡，答對就有星星", .orange) { path.append(.levels) }
                homeButton("📖", "單字學習", "大圖片、英文、中文與發音", .green) { path.append(.categories) }
                homeButton("✅", "每日任務", "每天完成 5 個單字", .pink) { path.append(.daily) }
                homeButton("🐾", "寵物成長", "配件、背景與成長階段", .purple) { path.append(.growth) }
                homeButton("📊", "家長模式", "學習時間與答對率", .yellow) { path.append(.parent) }
                homeButton("🏆", "我的成就", "20 關與星星成就", .indigo) { path.append(.achievements) }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .background(Color(red: 1, green: 0.985, blue: 0.94))
    }

    private func petTapArea(_ spoken: String, visual: String) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                message = visual
                speech.speak(spoken, chinese: true)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { heroScale = 1.035 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation { heroScale = 1.0 }
                }
            }
    }

    private func homeButton(_ icon: String, _ title: String, _ subtitle: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button {
            speech.speak(title, chinese: true)
            action()
        } label: {
            HStack(spacing: 15) {
                Text(icon).font(.system(size: 42))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.title3.bold())
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.title2.bold())
            }
            .padding(17)
            .background(color.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
    }
}

struct ProgressCard: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        Button {
            speech.speak("闖關進度", chinese: true)
            path.append(.levels)
        } label: {
            VStack(spacing: 10) {
                HStack {
                    Text("🌿 闖關進度").font(.title3.bold())
                    Spacer()
                    Text("第 \(min(progress.unlockedLevel, 20)) 關").bold()
                }
                ProgressView(value: Double(max(0, progress.unlockedLevel - 1)), total: 20)
                    .tint(.green)
                HStack {
                    milestone(5); Spacer(); milestone(10); Spacer(); milestone(15); Spacer(); milestone(20)
                }
            }
            .padding()
            .background(Color.orange.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .buttonStyle(.plain)
    }

    private func milestone(_ level: Int) -> some View {
        VStack {
            Text(progress.unlockedLevel > level ? "🎁" : "🧰").font(.system(size: 32))
            Text("\(level) 關").font(.caption.bold())
            Text(progress.unlockedLevel > level ? "⭐⭐⭐" : "☆☆☆").font(.caption2)
        }
    }
}

struct CategoryView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(PetLingoData.categories, id: \.0) { item in
                    Button {
                        speech.speak(item.0, chinese: true)
                        path.append(.learn(item.0))
                    } label: {
                        VStack(spacing: 8) {
                            Text(item.1).font(.system(size: 62))
                            Text(item.0).font(.title3.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: 135)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("單字學習")
    }
}

struct LearningView: View {
    let category: String
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var index = 0

    private var words: [KidsWord] {
        PetLingoData.words.filter { $0.category == category }
    }

    var body: some View {
        let word = words[index]
        VStack(spacing: 18) {
            ProgressView(value: Double(index + 1), total: Double(words.count))
                .padding(.horizontal)

            Spacer()
            Button {
                speech.speak(word.english)
            } label: {
                VStack(spacing: 10) {
                    if category == "數字" {
                        Text(word.chinese)
                            .font(.system(size: 145, weight: .black, design: .rounded))
                            .foregroundStyle(.blue)
                    } else {
                        Text(word.symbol).font(.system(size: 155))
                    }
                    Text(word.english)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(word.chinese)
                        .font(.title.bold())
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Button {
                speech.speak(word.english)
            } label: {
                Label("聽發音", systemImage: "speaker.wave.3.fill")
                    .font(.title3.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Button {
                speech.speak("Great job")
                speech.success()
                progress.learnedWord()
                index = (index + 1) % words.count
            } label: {
                Text("會了 ⭐").font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.pink)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            HStack {
                Button {
                    speech.speak("Previous")
                    index = index == 0 ? words.count - 1 : index - 1
                } label: { Label("上一個", systemImage: "arrow.left") }
                Spacer()
                Button {
                    speech.speak("Next")
                    index = (index + 1) % words.count
                } label: { Label("下一個", systemImage: "arrow.right") }
            }
            .font(.headline)
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .navigationTitle(category)
    }
}

struct LevelMapView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(1...20, id: \.self) { level in
                    let unlocked = level <= progress.unlockedLevel
                    Button {
                        guard unlocked else { return }
                        speech.speak("Level \(level)")
                        path.append(.quiz(level))
                    } label: {
                        HStack {
                            ZStack {
                                Circle().fill(unlocked ? Color.orange.opacity(0.35) : Color.gray.opacity(0.25))
                                    .frame(width: 58, height: 58)
                                Text(unlocked ? "\(level)" : "🔒").font(.title2.bold())
                            }
                            VStack(alignment: .leading) {
                                Text("第 \(level) 關").font(.title3.bold())
                                Text(level < progress.unlockedLevel ? "完成！⭐⭐⭐" : unlocked ? "5 題聽音選圖" : "尚未解鎖")
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(unlocked ? Color.orange.opacity(0.12) : Color.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }.padding()
        }
        .navigationTitle("20 關闖關")
    }
}

struct QuizView: View {
    let level: Int
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var question = 0
    @State private var options: [KidsWord] = []
    @State private var message = "請聽題目，選出正確圖片"
    @State private var answered = false

    private var levelWords: [KidsWord] {
        let pool = PetLingoData.everyday
        let start = ((level - 1) * 5) % pool.count
        return (0..<5).map { pool[(start + $0) % pool.count] }
    }

    private var target: KidsWord { levelWords[question] }

    var body: some View {
        VStack(spacing: 14) {
            Text("第 \(level) 關").font(.title.bold())
            ProgressView(value: Double(question + 1), total: 5)

            Text(message).font(.headline).multilineTextAlignment(.center)

            Button {
                speech.speak(target.english)
            } label: {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 36))
                    .frame(width: 78, height: 70)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options) { item in
                    Button {
                        select(item)
                    } label: {
                        VStack {
                            Text(item.symbol).font(.system(size: 70))
                            Text(item.chinese).font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.05), radius: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(answered)
                }
            }

            if answered {
                Button {
                    speech.speak(question == 4 ? "Level complete" : "Next")
                    if question == 4 {
                        if progress.unlockedLevel == level && level < 20 {
                            progress.unlockedLevel += 1
                        }
                        progress.stars += 3
                        path.removeLast()
                    } else {
                        question += 1
                        prepare()
                    }
                } label: {
                    Text(question == 4 ? "完成關卡 🎉" : "下一題")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.pink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 1, green: 0.985, blue: 0.94))
        .task(id: question) {
            prepare()
            try? await Task.sleep(for: .milliseconds(500))
            speech.speak(target.english)
        }
    }

    private func prepare() {
        answered = false
        message = "請聽題目，選出正確圖片；可按喇叭重播"
        let distractors = PetLingoData.everyday.filter { $0 != target }.shuffled().prefix(3)
        options = (Array(distractors) + [target]).shuffled()
    }

    private func select(_ item: KidsWord) {
        if item == target {
            answered = true
            message = "答對了！Good job! ⭐"
            progress.answer(correct: true)
            speech.success()
            speech.speak("Correct")
        } else {
            message = "再想一想，加油！"
            progress.answer(correct: false)
            speech.fail()
            speech.speak("Try again")
        }
    }
}

struct DailyTaskView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        VStack(spacing: 22) {
            Text("✅").font(.system(size: 90))
            Text("每日任務").font(.largeTitle.bold())
            Text("\(min(progress.todayCount, 5)) / 5").font(.system(size: 48, weight: .black))
            ProgressView(value: Double(min(progress.todayCount, 5)), total: 5)
            Text(progress.todayCount >= 5 ? "今天的任務完成了！🎁" : "再學 \(5 - min(progress.todayCount, 5)) 個單字就完成")
                .font(.title3.bold())
            Button("去學單字") {
                speech.speak("去學單字", chinese: true)
                path.append(.categories)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }.padding()
    }
}

struct PetGrowthView: View {
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    private var stage: Int {
        switch progress.unlockedLevel {
        case 15...: 3
        case 10...: 2
        case 5...: 1
        default: 0
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("寵物成長").font(.largeTitle.bold())
                HStack {
                    pet("tortoiseshell")
                    pet("tabby")
                    pet("chihuahua")
                }
                .padding()
                .background(Color.cyan.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                Text(["新朋友 ✨", "開心夥伴 🎀", "冒險小隊 🎒", "闖關高手 👑"][stage])
                    .font(.title2.bold())
                Text("目前解鎖第 \(progress.unlockedLevel) 關，累積 \(progress.stars) 顆星")
                Text(stage < 3 ? "繼續闖關可解鎖新的配件與背景。" : "已解鎖目前第一版最高成長階段！")
                    .foregroundStyle(.secondary)
            }.padding()
        }
        .navigationTitle("寵物成長")
    }

    private func pet(_ name: String) -> some View {
        Image(name).resizable().scaledToFit()
            .frame(maxWidth: .infinity)
            .onTapGesture { speech.speak("Good job") }
    }
}

struct ParentView: View {
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        List {
            Section("學習摘要") {
                stat("⏱️", "累積學習時間", "\(progress.minutes) 分鐘")
                stat("✅", "答對率", "\(progress.accuracy)%")
                stat("🗺️", "闖關進度", "\(max(0, progress.unlockedLevel - 1)) / 20")
                stat("⭐", "累積星星", "\(progress.stars)")
                stat("🎯", "今日單字", "\(progress.todayCount) 個")
            }
        }
        .navigationTitle("家長模式")
    }

    private func stat(_ icon: String, _ title: String, _ value: String) -> some View {
        HStack {
            Text(icon).font(.title)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(value).font(.title3.bold())
            }
        }.padding(.vertical, 6)
    }
}

struct AchievementsView: View {
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        List {
            achievement("🥉", "完成 5 關", progress.unlockedLevel > 5)
            achievement("🥈", "完成 10 關", progress.unlockedLevel > 10)
            achievement("🥇", "完成 15 關", progress.unlockedLevel > 15)
            achievement("👑", "完成 20 關", progress.unlockedLevel >= 20)
            achievement("⭐", "100 顆星", progress.stars >= 100)
        }
        .navigationTitle("我的成就")
    }

    private func achievement(_ icon: String, _ title: String, _ done: Bool) -> some View {
        HStack {
            Text(icon).font(.title)
            Text(title).font(.headline)
            Spacer()
            Text(done ? "完成！" : "繼續加油")
                .foregroundStyle(done ? .green : .secondary)
        }.padding(.vertical, 5)
    }
}

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

private enum PetPalette {
    static let background = Color(red: 1.00, green: 0.985, blue: 0.949)
    static let hero = Color(red: 0.875, green: 0.961, blue: 1.00)
    static let progress = Color(red: 1.00, green: 0.957, blue: 0.843)
    static let pink = Color(red: 1.00, green: 0.42, blue: 0.54)
    static let green = Color(red: 0.53, green: 0.84, blue: 0.36)
    static let blue = Color(red: 0.40, green: 0.81, blue: 0.96)
    static let orange = Color(red: 1.00, green: 0.76, blue: 0.30)
    static let purple = Color(red: 0.78, green: 0.64, blue: 0.96)
    static let yellow = Color(red: 1.00, green: 0.83, blue: 0.48)
    static let indigo = Color(red: 0.88, green: 0.70, blue: 0.95)
    static let titleBlue = Color(red: 0.19, green: 0.36, blue: 0.54)
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
        .tint(PetPalette.pink)
    }
}

struct HomeView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var message = "點點三隻毛孩，看看牠們會說什麼！"
    @State private var heroScale: CGFloat = 1

    var body: some View {
        ZStack {
            PetPalette.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    heroCard
                    progressCard

                    menuButton("🎮", "開始闖關", "20 個關卡，答對就有星星", PetPalette.orange) {
                        path.append(.levels)
                    }
                    menuButton("📖", "單字學習", "大圖、英文、中文與語音", PetPalette.green) {
                        path.append(.categories)
                    }
                    menuButton("🎤", "AI 發音模式", "孩子跟讀，系統比對發音", PetPalette.blue) {
                        speech.speak("AI 發音模式", chinese: true)
                    }
                    menuButton("✅", "每日任務", "每天完成 5 個單字可獲得獎勵", PetPalette.pink) {
                        path.append(.daily)
                    }
                    menuButton("🐾", "寵物成長", "解鎖表情、配件與背景", PetPalette.purple) {
                        path.append(.growth)
                    }
                    menuButton("📊", "家長模式", "查看時間、完成主題與答對率", PetPalette.yellow) {
                        path.append(.parent)
                    }
                    menuButton("🏆", "我的成就", "查看星星與 20 關進度", PetPalette.indigo) {
                        path.append(.achievements)
                    }
                }
                .padding(14)
            }
        }
        .navigationTitle("PetLingo Kids 6.0")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(spacing: 8) {
            Text("一起開心學英文！")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(PetPalette.titleBlue)
            Text("點擊三隻毛孩會有不同語音與互動")
                .font(.subheadline)

            ZStack {
                Image("home_hero")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(heroScale)
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                HStack(spacing: 0) {
                    petHit("黑糖送你一顆勇氣星星！⭐", speechText: "黑糖說，你真棒，繼續加油")
                    petHit("偶貴想和你一起挑戰下一關！🎮", speechText: "偶貴說，一起開始闖關吧")
                    petHit("熊熊說：今天也要開心學英文！🌈", speechText: "熊熊說，今天也要開心學英文")
                }
            }

            Button {
                speech.speak(message, chinese: true)
            } label: {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(PetPalette.titleBlue)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(.white.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)

            HStack {
                Text("⭐ \(progress.stars)").bold()
                Spacer()
                Text("第 \(min(progress.unlockedLevel, 20)) 關").bold()
                Spacer()
                Text("今日 \(min(progress.todayCount, 5))/5").bold()
            }
            .font(.subheadline)
        }
        .padding(12)
        .background(PetPalette.hero)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }

    private var progressCard: some View {
        let completed = min(max(progress.unlockedLevel - 1, 0), 20)
        return Button {
            speech.speak("闖關進度", chinese: true)
            path.append(.levels)
        } label: {
            VStack(spacing: 10) {
                HStack {
                    Text("🌿").font(.title2)
                    Text("闖關進度").font(.title2.bold())
                    Spacer()
                    Text("第 \(min(progress.unlockedLevel, 20)) 關").bold()
                }

                ProgressView(value: Double(completed), total: 20)
                    .tint(.green)
                    .scaleEffect(x: 1, y: 2.1)

                HStack {
                    milestone(5, completed)
                    Spacer()
                    milestone(10, completed)
                    Spacer()
                    milestone(15, completed)
                    Spacer()
                    milestone(20, completed)
                }

                HStack {
                    Text("⭐").font(.title)
                    VStack(alignment: .leading) {
                        Text("累積星星 \(progress.stars)").font(.headline)
                        Text(nextChestText(completed)).font(.caption)
                    }
                    Spacer()
                    Text("🏆").font(.title)
                }
                .padding(11)
                .background(.white.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(16)
            .foregroundStyle(.primary)
            .background(PetPalette.progress)
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
        .buttonStyle(.plain)
    }

    private func milestone(_ level: Int, _ completed: Int) -> some View {
        VStack(spacing: 3) {
            Text(completed >= level ? "🎁" : "🧰").font(.system(size: 38))
            Text("\(level) 關").font(.caption.bold())
            Text(completed >= level ? "⭐⭐⭐" : "☆☆☆").font(.caption2)
        }
    }

    private func nextChestText(_ completed: Int) -> String {
        if completed >= 20 { return "所有寶箱都已解鎖！" }
        if completed < 5 { return "完成第 5 關可開啟第一個寶箱" }
        if completed < 10 { return "下一個寶箱在第 10 關" }
        if completed < 15 { return "下一個寶箱在第 15 關" }
        return "最後寶箱在第 20 關"
    }

    private func petHit(_ visual: String, speechText: String) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                message = visual
                speech.speak(speechText, chinese: true)
                withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) { heroScale = 1.025 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeOut(duration: 0.18)) { heroScale = 1 }
                }
            }
    }

    private func menuButton(
        _ icon: String,
        _ title: String,
        _ subtitle: String,
        _ color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            speech.speak(title, chinese: true)
            action()
        } label: {
            HStack(spacing: 14) {
                Text(icon).font(.system(size: 48))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 22, weight: .black, design: .rounded))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.title2.bold())
            }
            .padding(17)
            .foregroundStyle(.primary)
            .background(color.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }
}

struct CategoryView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService

    var body: some View {
        ZStack {
            PetPalette.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("今天想學什麼？").font(.largeTitle.bold())
                        Text("每張卡片都有大圖片、英文、中文與語音")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(18)
                    .background(PetPalette.hero)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                    ForEach(PetLingoData.categories, id: \.0) { item in
                        Button {
                            speech.speak(item.0, chinese: true)
                            path.append(.learn(item.0))
                        } label: {
                            HStack(spacing: 14) {
                                Text(item.1)
                                    .font(.system(size: 48))
                                    .frame(width: 82, height: 82)
                                    .background(Color.pink.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                Text(item.0)
                                    .font(.system(size: 23, weight: .black, design: .rounded))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title2.bold())
                            }
                            .padding(14)
                            .foregroundStyle(.primary)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
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
        ZStack {
            PetPalette.background.ignoresSafeArea()
            VStack(spacing: 10) {
                ProgressView(value: Double(index + 1), total: Double(words.count))
                    .tint(PetPalette.pink)
                Text("\(index + 1) / \(words.count)").bold()

                Button {
                    speech.speak(word.english)
                } label: {
                    VStack(spacing: 12) {
                        Spacer()
                        if category == "數字" {
                            Text(word.chinese)
                                .font(.system(size: 145, weight: .black, design: .rounded))
                                .foregroundStyle(.blue)
                        } else {
                            Text(word.symbol).font(.system(size: 170))
                        }
                        Text(word.english)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                        Text(word.chinese)
                            .font(.system(size: 29, weight: .bold))
                            .foregroundStyle(.green)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 34))
                }
                .buttonStyle(.plain)

                Button {
                    speech.speak(word.english)
                } label: {
                    Label("聽發音", systemImage: "speaker.wave.3.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.blue.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                HStack {
                    Button {
                        speech.speak("Previous")
                        index = index == 0 ? words.count - 1 : index - 1
                    } label: {
                        Label("上一個", systemImage: "arrow.left")
                    }
                    Spacer()
                    Button {
                        speech.speak("Great job")
                        speech.success()
                        progress.learnedWord()
                        index = (index + 1) % words.count
                    } label: {
                        Text("會了 ⭐").bold()
                    }
                    Spacer()
                    Button {
                        speech.speak("Next")
                        index = (index + 1) % words.count
                    } label: {
                        Label("下一個", systemImage: "arrow.right")
                    }
                }
                .padding(.horizontal)
            }
            .padding(18)
        }
        .navigationTitle(category)
    }
}

struct LevelMapView: View {
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        ZStack {
            PetPalette.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    VStack {
                        Text("20 關闖關地圖").font(.largeTitle.bold())
                        Text("完成每關 5 題，解鎖下一關")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(PetPalette.hero)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                    ForEach(1...20, id: \.self) { level in
                        let unlocked = level <= progress.unlockedLevel
                        let completed = level < progress.unlockedLevel
                        Button {
                            guard unlocked else { return }
                            speech.speak("Level \(level)")
                            path.append(.quiz(level))
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(unlocked ? PetPalette.orange : Color.gray.opacity(0.35))
                                        .frame(width: 58, height: 58)
                                    Text(unlocked ? "\(level)" : "🔒")
                                        .font(.title2.bold())
                                }
                                VStack(alignment: .leading) {
                                    Text("第 \(level) 關").font(.title3.bold())
                                    Text(completed ? "完成！⭐⭐⭐" : unlocked ? "5 題聽音選圖" : "先完成上一關")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: completed ? "star.fill" : "chevron.right")
                                    .font(.title2)
                            }
                            .padding(18)
                            .foregroundStyle(.primary)
                            .background(completed ? Color.green.opacity(0.13) : unlocked ? PetPalette.progress : Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        .buttonStyle(.plain)
                        .disabled(!unlocked)
                    }
                }
                .padding(18)
            }
        }
        .navigationTitle("闖關")
    }
}

struct QuizView: View {
    let level: Int
    @Binding var path: [Screen]
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore
    @State private var question = 0
    @State private var options: [KidsWord] = []
    @State private var message = "請聽題目，選出正確圖片；可按喇叭重播"
    @State private var answered = false

    private var levelWords: [KidsWord] {
        let pool = PetLingoData.everyday
        let start = ((level - 1) * 5) % pool.count
        return (0..<5).map { pool[(start + $0) % pool.count] }
    }

    private var target: KidsWord { levelWords[question] }

    var body: some View {
        ZStack {
            PetPalette.background.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("第 \(level) 關").font(.title.bold())
                ProgressView(value: Double(question + 1), total: 5)
                Text("第 \(question + 1) 題／共 5 題").bold()

                VStack(spacing: 8) {
                    Text(message).font(.headline).multilineTextAlignment(.center)
                    Button {
                        speech.speak(target.english)
                    } label: {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 38))
                            .frame(width: 76, height: 76)
                            .background(PetPalette.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(15)
                .background(PetPalette.progress)
                .clipShape(RoundedRectangle(cornerRadius: 25))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(options) { item in
                        Button {
                            select(item)
                        } label: {
                            VStack(spacing: 6) {
                                Text(item.symbol).font(.system(size: 74))
                                Text(item.chinese).font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 145)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
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
                        }
                    } label: {
                        Text(question == 4 ? "完成關卡 🎉" : "下一題")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(PetPalette.pink)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                }
                Spacer()
            }
            .padding(16)
        }
        .task(id: question) {
            prepare()
            try? await Task.sleep(for: .milliseconds(500))
            speech.speak(target.english)
        }
        .navigationTitle("測驗")
    }

    private func prepare() {
        answered = false
        message = "請聽題目，選出正確圖片；可按喇叭重播"
        let sameCategory = PetLingoData.everyday.filter { $0 != target && $0.category == target.category }
        let pool = sameCategory.count >= 3 ? sameCategory : PetLingoData.everyday.filter { $0 != target }
        options = (Array(pool.shuffled().prefix(3)) + [target]).shuffled()
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
        ZStack {
            PetPalette.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("✅").font(.system(size: 85))
                Text("每日任務").font(.largeTitle.bold())
                Text("今天完成 5 個單字，就能拿到獎勵")
                    .multilineTextAlignment(.center)
                Text("\(min(progress.todayCount, 5)) / 5")
                    .font(.system(size: 44, weight: .black))
                ProgressView(value: Double(min(progress.todayCount, 5)), total: 5)
                    .tint(PetPalette.pink)
                Button {
                    speech.speak("去學單字", chinese: true)
                    path.append(.categories)
                } label: {
                    Text("去學單字")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(PetPalette.pink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                Spacer()
            }
            .padding(18)
        }
        .navigationTitle("每日任務")
    }
}

struct PetGrowthView: View {
    @EnvironmentObject private var speech: SpeechService
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        ZStack {
            PetPalette.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("寵物成長").font(.largeTitle.bold())
                    HStack(spacing: 3) {
                        pet("tortoiseshell")
                        pet("tabby")
                        pet("chihuahua")
                    }
                    .padding(15)
                    .background(PetPalette.hero)
                    .clipShape(RoundedRectangle(cornerRadius: 30))

                    Text("累積 \(progress.stars) 顆星・解鎖第 \(progress.unlockedLevel) 關")
                        .font(.headline)
                }
                .padding(18)
            }
        }
        .navigationTitle("寵物成長")
    }

    private func pet(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
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
        }
        .padding(.vertical, 6)
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
        }
        .padding(.vertical, 5)
    }
}

import SwiftUI
import AVFoundation
import Speech

struct KidsWord: Identifiable, Equatable, Hashable {
    let id = UUID()
    let category: String
    let emoji: String
    let english: String
    let chinese: String
}

enum Page: Hashable { case home, categories, levels, learn, quiz, pronunciation, dailyTask, petGrowth, parent, achievements }

struct LearningStats {
    let todayWords: Int; let correct: Int; let attempts: Int; let unlockedLevel: Int; let stars: Int; let completedThemes: Set<String>; let sessionSeconds: Int
}

@MainActor
final class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var afterSpeech: (() -> Void)?
    @Published var isPreparingMic = false
    @Published var isListening = false
    @Published var heard = ""

    override init() { super.init(); synthesizer.delegate = self; recognizer?.delegate = self }

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioApplication.requestRecordPermission { _ in }
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: text.containsChinese ? "zh-TW" : "en-US")
        u.rate = 0.42
        u.pitchMultiplier = 1.08
        synthesizer.speak(u)
    }

    func speakThen(_ text: String, delay: TimeInterval = 0.5, completion: @escaping () -> Void) {
        stopListening()
        isPreparingMic = true
        synthesizer.stopSpeaking(at: .immediate)
        afterSpeech = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self?.isPreparingMic = false
                completion()
            }
        }
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = 0.42
        u.pitchMultiplier = 1.08
        synthesizer.speak(u)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            let callback = afterSpeech
            afterSpeech = nil
            callback?()
        }
    }

    func startListening(completion: @escaping (String) -> Void) {
        heard = ""
        task?.cancel(); task = nil
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            let req = SFSpeechAudioBufferRecognitionRequest(); request = req
            req.shouldReportPartialResults = true
            let node = audioEngine.inputNode
            let format = node.outputFormat(forBus: 0)
            node.removeTap(onBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in req.append(buffer) }
            audioEngine.prepare(); try audioEngine.start(); isListening = true
            task = recognizer?.recognitionTask(with: req) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }
                    if let text = result?.bestTranscription.formattedString { self.heard = text }
                    if result?.isFinal == true || error != nil {
                        let final = self.heard
                        self.stopListening()
                        completion(final)
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
                guard let self, self.isListening else { return }
                let final = self.heard; self.stopListening(); completion(final)
            }
        } catch { stopListening(); completion("") }
    }

    func stopListening() {
        if audioEngine.isRunning { audioEngine.stop() }
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio(); task?.cancel(); request=nil; task=nil; isListening=false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

private extension String { var containsChinese: Bool { unicodeScalars.contains { (0x4E00...0x9FFF).contains(Int($0.value)) } } }

@MainActor
final class AppModel: ObservableObject {
    @Published var path: [Page] = []
    @Published var selectedCategory = "全部"
    @Published var selectedLevel = 1
    @Published var unlockedLevel: Int
    @Published var stars: Int
    @Published var correctAnswers: Int
    @Published var attempts: Int
    @Published var completedThemes: Set<String>
    @Published var todayWords: Int
    private let defaults = UserDefaults.standard
    private let openedAt = Date()
    private var savedSeconds: Int
    let today: String

    init() {
        let f=DateFormatter(); f.dateFormat="yyyy-MM-dd"; today=f.string(from: Date())
        unlockedLevel=max(1, defaults.integer(forKey:"unlockedLevel"))
        stars=defaults.integer(forKey:"stars"); correctAnswers=defaults.integer(forKey:"correct"); attempts=defaults.integer(forKey:"attempts")
        completedThemes=Set(defaults.stringArray(forKey:"themes") ?? [])
        todayWords = defaults.string(forKey:"dailyDate") == today ? defaults.integer(forKey:"todayWords") : 0
        savedSeconds=defaults.integer(forKey:"sessionSeconds")
    }
    var sessionSeconds: Int { savedSeconds + Int(Date().timeIntervalSince(openedAt)) }
    func persist() { defaults.set(unlockedLevel,forKey:"unlockedLevel"); defaults.set(stars,forKey:"stars"); defaults.set(correctAnswers,forKey:"correct"); defaults.set(attempts,forKey:"attempts"); defaults.set(Array(completedThemes),forKey:"themes"); defaults.set(today,forKey:"dailyDate"); defaults.set(todayWords,forKey:"todayWords"); defaults.set(sessionSeconds,forKey:"sessionSeconds") }
    func go(_ page: Page) { path.append(page) }
    func home() { path.removeAll() }
}

enum WordBank {
    static let everyday: [KidsWord] = [
        KidsWord(category: "生活用品", emoji: "🪥", english: "Toothbrush", chinese: "牙刷"),
        KidsWord(category: "生活用品", emoji: "🧼", english: "Soap", chinese: "肥皂"),
        KidsWord(category: "生活用品", emoji: "🧴", english: "Shampoo", chinese: "洗髮精"),
        KidsWord(category: "生活用品", emoji: "🧻", english: "Tissue", chinese: "衛生紙"),
        KidsWord(category: "生活用品", emoji: "🥄", english: "Spoon", chinese: "湯匙"),
        KidsWord(category: "生活用品", emoji: "🍴", english: "Fork", chinese: "叉子"),
        KidsWord(category: "生活用品", emoji: "🥤", english: "Cup", chinese: "杯子"),
        KidsWord(category: "生活用品", emoji: "🍽️", english: "Plate", chinese: "盤子"),
        KidsWord(category: "生活用品", emoji: "🪑", english: "Chair", chinese: "椅子"),
        KidsWord(category: "生活用品", emoji: "🛏️", english: "Bed", chinese: "床"),
        KidsWord(category: "生活用品", emoji: "🚪", english: "Door", chinese: "門"),
        KidsWord(category: "生活用品", emoji: "🪟", english: "Window", chinese: "窗戶"),
        KidsWord(category: "生活用品", emoji: "💡", english: "Light", chinese: "燈"),
        KidsWord(category: "生活用品", emoji: "📕", english: "Book", chinese: "書"),
        KidsWord(category: "生活用品", emoji: "✏️", english: "Pencil", chinese: "鉛筆"),
        KidsWord(category: "生活用品", emoji: "🎒", english: "Bag", chinese: "書包"),
        KidsWord(category: "生活用品", emoji: "☂️", english: "Umbrella", chinese: "雨傘"),
        KidsWord(category: "生活用品", emoji: "🧸", english: "Toy", chinese: "玩具"),
        KidsWord(category: "交通工具", emoji: "🚗", english: "Car", chinese: "汽車"),
        KidsWord(category: "交通工具", emoji: "🚌", english: "Bus", chinese: "公車"),
        KidsWord(category: "交通工具", emoji: "🚕", english: "Taxi", chinese: "計程車"),
        KidsWord(category: "交通工具", emoji: "🚲", english: "Bicycle", chinese: "腳踏車"),
        KidsWord(category: "交通工具", emoji: "🏍️", english: "Motorcycle", chinese: "機車"),
        KidsWord(category: "交通工具", emoji: "🚆", english: "Train", chinese: "火車"),
        KidsWord(category: "交通工具", emoji: "🚇", english: "Subway", chinese: "捷運"),
        KidsWord(category: "交通工具", emoji: "✈️", english: "Airplane", chinese: "飛機"),
        KidsWord(category: "交通工具", emoji: "🚢", english: "Ship", chinese: "船"),
        KidsWord(category: "交通工具", emoji: "🚑", english: "Ambulance", chinese: "救護車"),
        KidsWord(category: "交通工具", emoji: "🚒", english: "Fire truck", chinese: "消防車"),
        KidsWord(category: "動物", emoji: "🐶", english: "Dog", chinese: "狗"),
        KidsWord(category: "動物", emoji: "🐱", english: "Cat", chinese: "貓"),
        KidsWord(category: "動物", emoji: "🐰", english: "Rabbit", chinese: "兔子"),
        KidsWord(category: "動物", emoji: "🐻", english: "Bear", chinese: "熊"),
        KidsWord(category: "動物", emoji: "🐼", english: "Panda", chinese: "熊貓"),
        KidsWord(category: "動物", emoji: "🦁", english: "Lion", chinese: "獅子"),
        KidsWord(category: "動物", emoji: "🐯", english: "Tiger", chinese: "老虎"),
        KidsWord(category: "動物", emoji: "🐘", english: "Elephant", chinese: "大象"),
        KidsWord(category: "動物", emoji: "🐵", english: "Monkey", chinese: "猴子"),
        KidsWord(category: "動物", emoji: "🐦", english: "Bird", chinese: "鳥"),
        KidsWord(category: "動物", emoji: "🐟", english: "Fish", chinese: "魚"),
        KidsWord(category: "動物", emoji: "🐢", english: "Turtle", chinese: "烏龜"),
        KidsWord(category: "動物", emoji: "🐸", english: "Frog", chinese: "青蛙"),
        KidsWord(category: "動物", emoji: "🦋", english: "Butterfly", chinese: "蝴蝶"),
        KidsWord(category: "植物", emoji: "🌳", english: "Tree", chinese: "樹"),
        KidsWord(category: "植物", emoji: "🌱", english: "Seedling", chinese: "幼苗"),
        KidsWord(category: "植物", emoji: "🌿", english: "Leaf", chinese: "葉子"),
        KidsWord(category: "植物", emoji: "🌹", english: "Rose", chinese: "玫瑰"),
        KidsWord(category: "植物", emoji: "🌻", english: "Sunflower", chinese: "向日葵"),
        KidsWord(category: "植物", emoji: "🌷", english: "Tulip", chinese: "鬱金香"),
        KidsWord(category: "植物", emoji: "🌵", english: "Cactus", chinese: "仙人掌"),
        KidsWord(category: "植物", emoji: "🌾", english: "Grass", chinese: "草"),
        KidsWord(category: "食物", emoji: "🍚", english: "Rice", chinese: "飯"),
        KidsWord(category: "食物", emoji: "🍞", english: "Bread", chinese: "麵包"),
        KidsWord(category: "食物", emoji: "🥚", english: "Egg", chinese: "蛋"),
        KidsWord(category: "食物", emoji: "🥛", english: "Milk", chinese: "牛奶"),
        KidsWord(category: "食物", emoji: "🧀", english: "Cheese", chinese: "起司"),
        KidsWord(category: "食物", emoji: "🍗", english: "Chicken", chinese: "雞肉"),
        KidsWord(category: "食物", emoji: "🍜", english: "Noodles", chinese: "麵"),
        KidsWord(category: "食物", emoji: "🍲", english: "Soup", chinese: "湯"),
        KidsWord(category: "水果", emoji: "🍎", english: "Apple", chinese: "蘋果"),
        KidsWord(category: "水果", emoji: "🍌", english: "Banana", chinese: "香蕉"),
        KidsWord(category: "水果", emoji: "🍊", english: "Orange", chinese: "橘子"),
        KidsWord(category: "水果", emoji: "🍇", english: "Grapes", chinese: "葡萄"),
        KidsWord(category: "水果", emoji: "🍓", english: "Strawberry", chinese: "草莓"),
        KidsWord(category: "水果", emoji: "🍉", english: "Watermelon", chinese: "西瓜"),
        KidsWord(category: "水果", emoji: "🍍", english: "Pineapple", chinese: "鳳梨"),
        KidsWord(category: "水果", emoji: "🥭", english: "Mango", chinese: "芒果"),
        KidsWord(category: "蔬菜", emoji: "🥕", english: "Carrot", chinese: "胡蘿蔔"),
        KidsWord(category: "蔬菜", emoji: "🥦", english: "Broccoli", chinese: "花椰菜"),
        KidsWord(category: "蔬菜", emoji: "🌽", english: "Corn", chinese: "玉米"),
        KidsWord(category: "蔬菜", emoji: "🍅", english: "Tomato", chinese: "番茄"),
        KidsWord(category: "蔬菜", emoji: "🥒", english: "Cucumber", chinese: "小黃瓜"),
        KidsWord(category: "蔬菜", emoji: "🥬", english: "Lettuce", chinese: "生菜"),
        KidsWord(category: "蔬菜", emoji: "🥔", english: "Potato", chinese: "馬鈴薯"),
        KidsWord(category: "蔬菜", emoji: "🍄", english: "Mushroom", chinese: "蘑菇"),
        KidsWord(category: "運動", emoji: "⚽", english: "Soccer", chinese: "足球"),
        KidsWord(category: "運動", emoji: "🏀", english: "Basketball", chinese: "籃球"),
        KidsWord(category: "運動", emoji: "⚾", english: "Baseball", chinese: "棒球"),
        KidsWord(category: "運動", emoji: "🎾", english: "Tennis", chinese: "網球"),
        KidsWord(category: "運動", emoji: "🏸", english: "Badminton", chinese: "羽球"),
        KidsWord(category: "運動", emoji: "🏊", english: "Swimming", chinese: "游泳"),
        KidsWord(category: "運動", emoji: "🏃", english: "Running", chinese: "跑步"),
        KidsWord(category: "動作", emoji: "🚶", english: "Walk", chinese: "走路"),
        KidsWord(category: "動作", emoji: "🏃", english: "Run", chinese: "跑"),
        KidsWord(category: "動作", emoji: "🦘", english: "Jump", chinese: "跳"),
        KidsWord(category: "動作", emoji: "🪑", english: "Sit", chinese: "坐"),
        KidsWord(category: "動作", emoji: "🧍", english: "Stand", chinese: "站"),
        KidsWord(category: "動作", emoji: "🍽️", english: "Eat", chinese: "吃"),
        KidsWord(category: "動作", emoji: "🥤", english: "Drink", chinese: "喝"),
        KidsWord(category: "動作", emoji: "😴", english: "Sleep", chinese: "睡覺"),
        KidsWord(category: "動作", emoji: "👏", english: "Clap", chinese: "拍手"),
        KidsWord(category: "動作", emoji: "👋", english: "Wave", chinese: "揮手"),
        KidsWord(category: "動作", emoji: "😁", english: "Smile", chinese: "微笑"),
        KidsWord(category: "動作", emoji: "🎤", english: "Sing", chinese: "唱歌"),
        KidsWord(category: "身體部位", emoji: "🙂", english: "Head", chinese: "頭"),
        KidsWord(category: "身體部位", emoji: "👀", english: "Eyes", chinese: "眼睛"),
        KidsWord(category: "身體部位", emoji: "👂", english: "Ears", chinese: "耳朵"),
        KidsWord(category: "身體部位", emoji: "👃", english: "Nose", chinese: "鼻子"),
        KidsWord(category: "身體部位", emoji: "👄", english: "Mouth", chinese: "嘴巴"),
        KidsWord(category: "身體部位", emoji: "🦷", english: "Teeth", chinese: "牙齒"),
        KidsWord(category: "身體部位", emoji: "💪", english: "Arm", chinese: "手臂"),
        KidsWord(category: "身體部位", emoji: "✋", english: "Hand", chinese: "手"),
        KidsWord(category: "身體部位", emoji: "🦵", english: "Leg", chinese: "腿"),
        KidsWord(category: "身體部位", emoji: "🦶", english: "Foot", chinese: "腳"),
        KidsWord(category: "顏色", emoji: "🔴", english: "Red", chinese: "紅色"),
        KidsWord(category: "顏色", emoji: "🔵", english: "Blue", chinese: "藍色"),
        KidsWord(category: "顏色", emoji: "🟡", english: "Yellow", chinese: "黃色"),
        KidsWord(category: "顏色", emoji: "🟢", english: "Green", chinese: "綠色"),
        KidsWord(category: "顏色", emoji: "🟠", english: "Orange", chinese: "橘色"),
        KidsWord(category: "顏色", emoji: "🟣", english: "Purple", chinese: "紫色"),
        KidsWord(category: "顏色", emoji: "🩷", english: "Pink", chinese: "粉紅色"),
        KidsWord(category: "顏色", emoji: "⚫", english: "Black", chinese: "黑色"),
        KidsWord(category: "顏色", emoji: "⚪", english: "White", chinese: "白色"),
        KidsWord(category: "形狀", emoji: "●", english: "Circle", chinese: "圓形"),
        KidsWord(category: "形狀", emoji: "▲", english: "Triangle", chinese: "三角形"),
        KidsWord(category: "形狀", emoji: "■", english: "Square", chinese: "正方形"),
        KidsWord(category: "形狀", emoji: "▭", english: "Rectangle", chinese: "長方形"),
        KidsWord(category: "形狀", emoji: "★", english: "Star", chinese: "星形"),
        KidsWord(category: "形狀", emoji: "♥", english: "Heart", chinese: "愛心"),
        KidsWord(category: "形狀", emoji: "⬭", english: "Oval", chinese: "橢圓形"),
        KidsWord(category: "形狀", emoji: "◆", english: "Diamond", chinese: "菱形"),
        KidsWord(category: "形狀", emoji: "⬟", english: "Pentagon", chinese: "五邊形"),
        KidsWord(category: "形狀", emoji: "⬢", english: "Hexagon", chinese: "六邊形"),
    ]
    static let numbers: [KidsWord] = (0...100).map { KidsWord(category:"數字", emoji:"🔢", english:numberEnglish($0), chinese:numberChinese($0)) }
    static let all = everyday + numbers
    static func levelWords(_ level:Int) -> [KidsWord] {
        let allowed = Set(["一","二","三","四","五","六","七","八","九","十"])
        let pool=all.filter { $0.category != "數字" || allowed.contains($0.chinese) }
        let start=((level-1)*5)%pool.count
        return (0..<5).map { pool[(start+$0)%pool.count] }
    }
}

private func numberEnglish(_ n:Int)->String {
    let ones=["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"]
    let teens=[10:"Ten",11:"Eleven",12:"Twelve",13:"Thirteen",14:"Fourteen",15:"Fifteen",16:"Sixteen",17:"Seventeen",18:"Eighteen",19:"Nineteen"]
    let tens=[20:"Twenty",30:"Thirty",40:"Forty",50:"Fifty",60:"Sixty",70:"Seventy",80:"Eighty",90:"Ninety"]
    if n<10{return ones[n]}; if n<20{return teens[n]!}; if n==100{return "One hundred"}; if n%10==0{return tens[n]!}; return "\(tens[(n/10)*10]!)-\(ones[n%10].lowercased())"
}
private func numberChinese(_ n:Int)->String { let d=["零","一","二","三","四","五","六","七","八","九"]; if n<10{return d[n]}; if n==10{return "十"}; if n<20{return "十\(d[n%10])"}; if n<100 && n%10==0{return "\(d[n/10])十"}; if n<100{return "\(d[n/10])十\(d[n%10])"}; return "一百" }

@main
struct PetLingoKidsApp: App {
    @StateObject private var model=AppModel()
    @StateObject private var speech=SpeechManager()
    var body: some Scene { WindowGroup { RootView().environmentObject(model).environmentObject(speech).onAppear { speech.requestPermissions() } } }
}

struct RootView: View {
    @EnvironmentObject var model: AppModel; @EnvironmentObject var speech: SpeechManager
    var body: some View {
        NavigationStack(path:$model.path) {
            HomeView().navigationDestination(for:Page.self) { page in
                destination(page).toolbar { ToolbarItem(placement:.topBarLeading) { Button { speech.speak("Home"); model.home() } label:{ Image(systemName:"house.fill") } }; ToolbarItem(placement:.topBarTrailing){ Text("⭐ \(model.stars)").fontWeight(.black).padding(.horizontal,12).padding(.vertical,7).background(Color(hex:0xFFEFC8)).clipShape(Capsule()) } }
            }
            .toolbar { ToolbarItem(placement:.principal){ VStack(spacing:1){ Text("PetLingo Kids 6.0").fontWeight(.black); Text("和黑糖、偶貴、熊熊一起學英文！").font(.caption) } }; ToolbarItem(placement:.topBarTrailing){ Text("⭐ \(model.stars)").fontWeight(.black) } }
        }.tint(Color(hex:0xFF6B8A))
    }
    @ViewBuilder func destination(_ p:Page)->some View { switch p { case .categories: CategoryView(); case .levels: LevelMapView(); case .learn: LearningView(); case .quiz: LevelQuizView(); case .pronunciation: PronunciationView(); case .dailyTask: DailyTaskView(); case .petGrowth: PetGrowthView(); case .parent: ParentView(); case .achievements: AchievementsView(); case .home: HomeView() } }
}

struct AdaptiveContent<Content:View>: View { @ViewBuilder let content:()->Content; var body:some View { GeometryReader { g in ScrollView { content().frame(maxWidth: min(g.size.width > 700 ? 900 : g.size.width, 900)).frame(maxWidth:.infinity).padding(g.size.width > 700 ? 28 : 14) } }.background(Color(hex:0xFFFBF2)) } }

struct HomeView: View {
    @EnvironmentObject var model:AppModel; @EnvironmentObject var speech:SpeechManager; @State private var message="點點黑糖、偶貴或熊熊，看看牠們會說什麼！"
    var body: some View { AdaptiveContent { VStack(spacing:14) {
        VStack(spacing:8){ Text("一起開心學英文！").font(.system(size:34,weight:.black)).foregroundStyle(Color(hex:0x315B8A)); Text("點擊三隻毛孩會有不同語音與互動"); HStack(spacing:8){ pet("tortoiseshell","黑糖送你一顆勇氣星星！⭐","黑糖說，你真棒，繼續加油"); pet("tabby","偶貴想和你一起挑戰下一關！🎮","偶貴說，一起開始闖關吧"); pet("chihuahua","熊熊說：今天也要開心學英文！🌈","熊熊說，今天也要開心學英文") }.frame(height:190); Button(message){speech.speak(message)}.buttonStyle(.plain).fontWeight(.bold).foregroundStyle(Color(hex:0x315B8A)).padding(10).frame(maxWidth:.infinity).background(.white.opacity(0.9)).clipShape(RoundedRectangle(cornerRadius:20)); HStack{ Spacer(); Text("⭐ \(model.stars)").bold(); Spacer(); Text("第 \(min(model.unlockedLevel,20)) 關").bold(); Spacer(); Text("今日 \(min(model.todayWords,5))/5").bold(); Spacer() } }.padding(14).background(Color(hex:0xDFF5FF)).clipShape(RoundedRectangle(cornerRadius:30))
        ProgressCard()
        MenuButton(icon:"🎮",title:"開始闖關",subtitle:"20 個關卡，答對就有星星",color:0xFFC34D,page:.levels)
        MenuButton(icon:"📖",title:"單字學習",subtitle:"大圖、英文、中文與語音",color:0x86D75D,page:.categories)
        MenuButton(icon:"🎤",title:"AI 發音模式",subtitle:"孩子跟讀，系統比對發音",color:0x66CEF5,page:.pronunciation)
        MenuButton(icon:"✅",title:"每日任務",subtitle:"每天完成 5 個單字可獲得獎勵",color:0xFF9DB3,page:.dailyTask)
        MenuButton(icon:"🐾",title:"寵物成長",subtitle:"解鎖表情與配件",color:0xC8A4F4,page:.petGrowth)
        MenuButton(icon:"📊",title:"家長模式",subtitle:"查看時間、完成主題與答對率",color:0xFFD37A,page:.parent)
        MenuButton(icon:"🏆",title:"我的成就",subtitle:"查看星星與 20 關進度",color:0xE5B3F3,page:.achievements)
    }} }
    func pet(_ img:String,_ msg:String,_ voice:String)->some View { Button{message=msg;speech.speak(voice)}label:{Image(img).resizable().scaledToFit()}.buttonStyle(.plain) }
}

struct ProgressCard:View { @EnvironmentObject var model:AppModel; @EnvironmentObject var speech:SpeechManager; var completed:Int{min(max(model.unlockedLevel-1,0),20)}; var body:some View { Button { speech.speak("闖關進度，目前完成 \(completed) 關，累積 \(model.stars) 顆星"); model.go(.levels) } label:{ VStack(spacing:12){ HStack{Text("🌿").font(.title);Text("闖關進度").font(.title2).bold();Spacer();Text("第 \(min(model.unlockedLevel,20)) 關").bold()}; ProgressView(value:Double(completed),total:20).scaleEffect(y:2); HStack{ForEach([5,10,15,20],id:\.self){n in VStack{Text(completed>=n ? "🎁":"🧰").font(.system(size:38));Text("\(n) 關").bold();Text(completed>=n ? "⭐⭐⭐":"☆☆☆").font(.caption)}}}.frame(maxWidth:.infinity); HStack{Text("⭐").font(.largeTitle);VStack(alignment:.leading){Text("累積星星 \(model.stars)").font(.title3).bold();Text(nextChest)};Spacer();Text("🏆").font(.largeTitle)}.padding(10).background(.white.opacity(0.85)).clipShape(RoundedRectangle(cornerRadius:18)) }.padding(16).background(Color(hex:0xFFF4D7)).clipShape(RoundedRectangle(cornerRadius:28)) }.buttonStyle(.plain).foregroundStyle(.primary) }
    var nextChest:String { if completed>=20{return "所有寶箱都已解鎖！"}; if completed<5{return "完成第 5 關可開啟第一個寶箱"}; if completed<10{return "下一個寶箱在第 10 關"}; if completed<15{return "下一個寶箱在第 15 關"}; return "最後寶箱在第 20 關" }
}

struct MenuButton:View { @EnvironmentObject var model:AppModel; @EnvironmentObject var speech:SpeechManager; let icon,title,subtitle:String;let color:Int;let page:Page; var body:some View { Button{speech.speak(title);model.go(page)}label:{HStack{Text(icon).font(.system(size:48));VStack(alignment:.leading){Text(title).font(.title3).fontWeight(.black);Text(subtitle).font(.subheadline)};Spacer();Image(systemName:"chevron.right").font(.title2)}.padding(18).background(Color(hex:color)).clipShape(RoundedRectangle(cornerRadius:26))}.buttonStyle(.plain).foregroundStyle(.primary) } }

struct CategoryView:View { @EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager
 let categories=[("生活用品","🧸","家裡與幼兒園每天會看到"),("交通工具","🚗","汽車、公車、捷運與飛機"),("動物","🐶","常見寵物與動物園動物"),("植物","🌻","樹、花、葉子與小草"),("食物","🍞","三餐與孩子常吃的食物"),("水果","🍎","生活中常見的水果"),("蔬菜","🥕","餐桌上的常見蔬菜"),("運動","⚽","球類、游泳與戶外活動"),("動作","🏃","走、跑、跳、吃與睡"),("身體部位","👀","眼睛、耳朵、手與腳"),("形狀","🔺","圓形、三角形、正方形與星形"),("數字","🔢","從 0 學到 100"),("顏色","🌈","生活中常見的顏色")]
 var body:some View{AdaptiveContent{VStack(spacing:12){header("今天想學什麼？","點任何按鈕都會讀出上面的字",0xDFF5FF); Button{open("全部")}label:{categoryRow("🌟","全部生活單字","🪥  🚗  🐶  🍎  ⚽  🌈  一次瀏覽所有主題",0xFFE08A)}.buttonStyle(.plain); ForEach(Array(categories.enumerated()),id:\.offset){_,c in Button{open(c.0)}label:{categoryRow(c.1,c.0,c.2,0xFFFFFF)}.buttonStyle(.plain)}}}} 
 func open(_ c:String){speech.speak(c);model.selectedCategory=c;model.go(.learn)}
 func categoryRow(_ emoji:String,_ name:String,_ desc:String,_ color:Int)->some View{HStack{Text(emoji).font(.system(size:46)).frame(width:82,height:82).background(Color(hex:0xFFE3EA)).clipShape(RoundedRectangle(cornerRadius:24));VStack(alignment:.leading){Text(name).font(.title3).bold();Text(desc).font(.subheadline); if name=="數字"{Text("1️⃣  2️⃣  3️⃣  🔟")}else if name=="形狀"{Text("●  ▲  ■  ★  ♥")}else{Text(WordBank.all.filter{$0.category==name}.prefix(4).map{$0.emoji}.joined(separator:"  "))}};Spacer();Image(systemName:"chevron.right")}.padding(16).background(Color(hex:color)).clipShape(RoundedRectangle(cornerRadius:25)).foregroundStyle(.primary)} }

struct LearningView:View { @EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;@State var index=0;@State var showChinese=true;@State var celebrate=false
 var words:[KidsWord]{model.selectedCategory=="全部" ? WordBank.all : WordBank.all.filter{$0.category==model.selectedCategory}}
 var word:KidsWord{words[min(index,words.count-1)]}
 var body:some View{GeometryReader{g in VStack(spacing:10){ProgressView(value:Double(index+1),total:Double(words.count));Text("\(index+1) / \(words.count)").bold(); Button{speech.speak(word.english)}label:{VStack(spacing:12){Spacer(); if word.category=="數字"{Text(word.chinese).font(.system(size:g.size.width>700 ? 180:130,weight:.black)).foregroundStyle(Color(hex:0x4B73C8))}else{Text(word.emoji).font(.system(size:g.size.width>700 ? 190:145))};Text(word.english).font(.system(size:44,weight:.black)).minimumScaleFactor(0.5);if showChinese{Text(word.chinese).font(.system(size:30,weight:.bold)).foregroundStyle(Color(hex:0x33946F))};Button{speech.speak(word.english)}label:{Label("聽發音",systemImage:"speaker.wave.2.fill").font(.title3).bold()}.buttonStyle(.borderedProminent);Spacer()}.frame(maxWidth:.infinity,maxHeight:.infinity).background(.white).clipShape(RoundedRectangle(cornerRadius:34))}.buttonStyle(.plain).foregroundStyle(.primary);HStack{Button{showChinese.toggle();speech.speak(showChinese ? "Show Chinese":"Hide Chinese")}label:{Label(showChinese ? "隱藏中文":"顯示中文",systemImage:"character.bubble")}.buttonStyle(.bordered).frame(maxWidth:.infinity);Button{learned()}label:{Text("會了 🔔").bold()}.buttonStyle(.borderedProminent).frame(maxWidth:.infinity)}.controlSize(.large);HStack{Button{index=(index-1+words.count)%words.count;speech.speak("Previous")}label:{Image(systemName:"arrow.left").font(.title)};Spacer().frame(width:50);Button{index=(index+1)%words.count;speech.speak("Next")}label:{Image(systemName:"arrow.right").font(.title)}}}.padding(g.size.width>700 ? 30:18).background(Color(hex:0xFFFBF2)).overlay{if celebrate{Celebration(text:"太棒了！")}}} }
 func learned(){model.stars+=1;model.todayWords+=1;model.completedThemes.insert(model.selectedCategory);model.persist();celebrate=true;index=(index+1)%words.count;DispatchQueue.main.asyncAfter(deadline:.now()+0.85){celebrate=false}}
}

struct LevelMapView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;var body:some View{AdaptiveContent{VStack(spacing:12){header("20 關闖關地圖","完成每關 5 題，解鎖下一關",0xDDF5FF);ForEach(1...20,id:\.self){level in let unlocked=level<=model.unlockedLevel;let complete=level<model.unlockedLevel;Button{if unlocked{speech.speak("Level \(level)");model.selectedLevel=level;model.go(.quiz)}}label:{HStack{ZStack{Circle().fill(Color(hex:unlocked ? 0xFFB83E:0xAAAAAA)).frame(width:58,height:58);if unlocked{Text("\(level)").font(.title2).bold()}else{Image(systemName:"lock.fill")}};VStack(alignment:.leading){Text("第 \(level) 關").font(.title3).bold();Text(complete ? "完成！⭐⭐⭐":unlocked ? "5 題聽音選圖":"先完成上一關")};Spacer();Image(systemName:complete ? "star.fill":"chevron.right")}.padding(18).background(Color(hex:complete ? 0xDDF8EB:unlocked ? 0xFFEFC8:0xE7E7E7)).clipShape(RoundedRectangle(cornerRadius:25)).foregroundStyle(.primary)}.buttonStyle(.plain).disabled(!unlocked)}}}}}

struct LevelQuizView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;@State var q=0;@State var options:[KidsWord]=[];@State var message="請聽題目，選出正確圖片；可按喇叭重播";@State var answered=false;@State var celebrate=false
 var words:[KidsWord]{WordBank.levelWords(model.selectedLevel)};var target:KidsWord{words[q]}
 var body:some View{GeometryReader{g in VStack(spacing:10){Text("第 \(model.selectedLevel) 關").font(.title).bold();ProgressView(value:Double(q+1),total:5);Text("第 \(q+1) 題／共 5 題").bold();VStack{Text(message).font(.title3).bold().multilineTextAlignment(.center);Button{speech.speak(target.english)}label:{Image(systemName:"speaker.wave.2.fill").font(.system(size:40)).frame(width:76,height:76)}.buttonStyle(.borderedProminent)}.padding().frame(maxWidth:.infinity).background(Color(hex:0xFFEFC8)).clipShape(RoundedRectangle(cornerRadius:25));LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:10){ForEach(options){item in Button{choose(item)}label:{VStack{Text(item.category=="數字" ? item.chinese:item.emoji).font(.system(size:g.size.width>700 ? 88:68));Text(item.chinese).font(.title3).bold()}.frame(maxWidth:.infinity,minHeight:g.size.width>700 ? 190:145).background(.white).clipShape(RoundedRectangle(cornerRadius:25))}.buttonStyle(.plain).foregroundStyle(.primary).disabled(answered)}};if answered{Button{next()}label:{Label(q==4 ? "完成關卡 🎉":"下一題",systemImage:"arrow.right")}.buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth:.infinity)}}.padding(g.size.width>700 ? 30:16).background(Color(hex:0xFFFBF2)).overlay{if celebrate{Celebration(text:"答對了！")}}.onAppear{setup();DispatchQueue.main.asyncAfter(deadline:.now()+0.5){speech.speak(target.english)}}} }
 func setup(){let same=WordBank.all.filter{$0 != target && $0.category==target.category}.shuffled();let others=(same.isEmpty ? WordBank.all.filter{$0 != target}.shuffled():same);options=Array(others.prefix(3))+[target];options.shuffle()}
 func choose(_ item:KidsWord){model.attempts+=1;if item==target{message="答對了！Good job! ⭐";answered=true;celebrate=true;model.correctAnswers+=1;model.stars+=1;speech.speak("Correct");DispatchQueue.main.asyncAfter(deadline:.now()+0.85){celebrate=false}}else{message="再想一想，加油！";speech.speak("Try again")};model.persist()}
 func next(){speech.speak(q==4 ? "Level complete":"Next");if q==4{if model.selectedLevel==model.unlockedLevel && model.unlockedLevel<20{model.unlockedLevel+=1};model.stars+=3;model.persist();model.path.removeLast()}else{q+=1;answered=false;message="請聽題目，選出正確圖片；可按喇叭重播";setup();DispatchQueue.main.asyncAfter(deadline:.now()+0.5){speech.speak(target.english)}}}
}

struct PronunciationView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;@State var practice=WordBank.all.filter{$0.category != "數字"}.shuffled().prefix(20).map{$0};@State var index=0;@State var score=0
 var target:KidsWord{practice[index]};var body:some View{GeometryReader{g in VStack(spacing:14){header("AI 發音模式","先聽，再按麥克風跟讀",0xDFF5FF);VStack{Spacer();Text(target.emoji).font(.system(size:g.size.width>700 ? 180:135));Text(target.english).font(.system(size:44,weight:.black));Text(target.chinese).font(.system(size:28,weight:.bold)).foregroundStyle(Color(hex:0x33946F));Button{speech.speak(target.english)}label:{Label("聽標準發音",systemImage:"speaker.wave.2.fill")}.buttonStyle(.bordered);Spacer()}.frame(maxWidth:.infinity,maxHeight:.infinity).background(.white).clipShape(RoundedRectangle(cornerRadius:32));if !speech.heard.isEmpty{VStack{Text("系統聽到：\(speech.heard)").bold();Text("相似度：\(score) 分").font(.title2).bold()}.padding(14).frame(maxWidth:.infinity).background(Color(hex:score>=70 ? 0xDDF8EB:0xFFE3EA)).clipShape(RoundedRectangle(cornerRadius:22))};Button{start()}label:{Label(speech.isPreparingMic ? "示範中…唸完 0.5 秒後開始收音":speech.isListening ? "收音中…":"按下跟讀",systemImage:speech.isPreparingMic ? "speaker.wave.2.fill":"mic.fill").font(.title3).bold()}.buttonStyle(.borderedProminent).controlSize(.large).disabled(speech.isPreparingMic||speech.isListening);Button{speech.speak("Next word");index=(index+1)%practice.count;score=0;speech.heard=""}label:{Text("下一個單字")}.buttonStyle(.bordered).controlSize(.large).disabled(speech.isPreparingMic||speech.isListening)}.padding(g.size.width>700 ? 30:18).background(Color(hex:0xFFFBF2))}}
 func start(){speech.speakThen("Please say \(target.english)",delay:0.5){speech.startListening{heard in score=pronunciationScore(target.english,heard);model.attempts+=1;if score>=70{model.correctAnswers+=1;model.stars+=2};model.persist();speech.speak(score>=70 ? "Great pronunciation":"Try again")}}}
}

struct DailyTaskView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;var complete:Bool{model.todayWords>=5};var body:some View{AdaptiveContent{VStack(spacing:18){header("每日任務","今天完成 5 個單字，就能拿到獎勵",0xFFEFC8);VStack{Text(complete ? "🎁":"⭐").font(.system(size:100));Text("\(min(model.todayWords,5)) / 5").font(.system(size:42,weight:.black));ProgressView(value:Double(min(model.todayWords,5)),total:5);Text(complete ? "今天的任務完成了！":"再學 \(5-min(model.todayWords,5)) 個就完成").font(.title3).bold()}.padding(22).frame(maxWidth:.infinity).background(.white).clipShape(RoundedRectangle(cornerRadius:28));Button{speech.speak(complete ? "Daily mission complete":"Go learn words");model.go(.categories)}label:{Text(complete ? "再學一些單字":"去學單字").bold()}.buttonStyle(.borderedProminent).controlSize(.large)}}}}

struct PetGrowthView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;var stage:Int{model.unlockedLevel>=20 ? 4:model.unlockedLevel>=15 ? 3:model.unlockedLevel>=10 ? 2:model.unlockedLevel>=5 ? 1:0};let titles=["新朋友","開心夥伴","冒險小隊","學習高手","闖關王者"];let accessories=["✨","🎀","🎒","👑","🏆"];var body:some View{AdaptiveContent{VStack(spacing:16){header("寵物成長","\(titles[stage])・三隻毛孩一起成長",0xE8D8FF);VStack{HStack{growth("tortoiseshell");growth("tabby");growth("chihuahua")};Text("累積 \(model.stars) 顆星・解鎖第 \(model.unlockedLevel) 關").font(.title3).bold()}.padding(18).background(Color(hex:0xDFF5FF)).clipShape(RoundedRectangle(cornerRadius:30));VStack(alignment:.leading){Text("下一階段").font(.title2).bold();Text(model.unlockedLevel>=20 ? "全部成長階段已解鎖！":"完成第 \(next) 關，可獲得新的表情與配件。")}.padding(18).frame(maxWidth:.infinity,alignment:.leading).background(.white).clipShape(RoundedRectangle(cornerRadius:26));Button{speech.speak("Pet growth stage \(titles[stage])")}label:{Text("聽成長介紹")}.buttonStyle(.borderedProminent).controlSize(.large)}}}}
 var next:Int{model.unlockedLevel<5 ? 5:model.unlockedLevel<10 ? 10:model.unlockedLevel<15 ? 15:20};func growth(_ name:String)->some View{ZStack(alignment:.topTrailing){Image(name).resizable().scaledToFit();Text(accessories[stage]).font(.title)}.frame(maxWidth:180,maxHeight:160)} }

struct ParentView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;var accuracy:Int{model.attempts==0 ? 0:model.correctAnswers*100/model.attempts};var body:some View{AdaptiveContent{VStack(spacing:14){header("家長模式","本機學習紀錄，不需登入",0xDFF5FF);stat("⏱️","累積學習時間","\(model.sessionSeconds/60) 分鐘");stat("📚","已完成主題","\(model.completedThemes.count) 個");stat("✅","答對率","\(accuracy)%");stat("🗺️","闖關進度","\(model.unlockedLevel-1) / 20");stat("⭐","累積星星","\(model.stars)");stat("🎯","今日單字","\(model.todayWords) 個");VStack(alignment:.leading){Text("完成主題").font(.title2).bold();Text(model.completedThemes.isEmpty ? "尚未完成主題":model.completedThemes.sorted().joined(separator:"、"))}.padding(18).frame(maxWidth:.infinity,alignment:.leading).background(.white).clipShape(RoundedRectangle(cornerRadius:24))}}}
 func stat(_ icon:String,_ title:String,_ value:String)->some View{Button{speech.speak(value)}label:{HStack{Text(icon).font(.system(size:42));VStack(alignment:.leading){Text(title).font(.headline);Text(value).font(.title).bold()};Spacer();Image(systemName:"speaker.wave.2.fill")}.padding(18).background(.white).clipShape(RoundedRectangle(cornerRadius:24))}.buttonStyle(.plain).foregroundStyle(.primary)} }

struct AchievementsView:View{@EnvironmentObject var model:AppModel;@EnvironmentObject var speech:SpeechManager;var body:some View{AdaptiveContent{VStack(spacing:16){header("我的成就","總星星數 ⭐ \(model.stars)",0xE8D8FF);badge("🐾","學習小高手","\(model.correctAnswers) / 10",model.correctAnswers>=10);badge("📖","單字達人","\(model.correctAnswers) / 50",model.correctAnswers>=50);badge("🥉","完成 5 關","\(model.unlockedLevel-1) / 5",model.unlockedLevel>5);badge("🥈","完成 10 關","\(model.unlockedLevel-1) / 10",model.unlockedLevel>10);badge("🥇","完成 15 關","\(model.unlockedLevel-1) / 15",model.unlockedLevel>15);badge("👑","完成 20 關","\(model.unlockedLevel-1) / 20",model.unlockedLevel>20);badge("⭐","星星收藏家","\(model.stars) / 100",model.stars>=100)}}}
 func badge(_ icon:String,_ title:String,_ progress:String,_ achieved:Bool)->some View{Button{speech.speak(title)}label:{HStack{Text(icon).font(.system(size:50));VStack(alignment:.leading){Text(title).font(.title3).bold();Text(progress)};Spacer();Text(achieved ? "完成！":"繼續加油").bold()}.padding(18).background(Color(hex:achieved ? 0xFFEFC8:0xFFFFFF)).clipShape(RoundedRectangle(cornerRadius:24))}.buttonStyle(.plain).foregroundStyle(.primary)} }

struct Celebration:View{let text:String;var body:some View{ZStack{Color.black.opacity(0.5).ignoresSafeArea();VStack{Text("🎉 ⭐ 🎊").font(.system(size:48));Text(text).font(.system(size:36,weight:.black)).foregroundStyle(Color(hex:0xE45272));Text("繼續加油喔！").font(.title3).bold();HStack{Image("tortoiseshell").resizable().scaledToFit();Image("tabby").resizable().scaledToFit();Image("chihuahua").resizable().scaledToFit()}.frame(height:100)}.padding(30).background(Color(hex:0xFFF2B8)).clipShape(RoundedRectangle(cornerRadius:36)).padding(28)}}

func header(_ title:String,_ subtitle:String,_ color:Int)->some View{VStack(spacing:6){Text(title).font(.system(size:32,weight:.black));Text(subtitle).multilineTextAlignment(.center)}.padding(20).frame(maxWidth:.infinity).background(Color(hex:color)).clipShape(RoundedRectangle(cornerRadius:30))}

func pronunciationScore(_ target:String,_ heard:String)->Int{let a=target.lowercased().filter{$0.isLetter};let b=heard.lowercased().filter{$0.isLetter};guard !a.isEmpty,!b.isEmpty else{return 0};let aa=Array(a),bb=Array(b);var costs=Array(0...bb.count);for i in aa.indices{var last=i;costs[0]=i+1;for j in bb.indices{let old=costs[j+1];costs[j+1]=min(costs[j+1]+1,costs[j]+1,last+(aa[i]==bb[j] ? 0:1));last=old}};return max(0,Int(100*(1-Double(costs[bb.count])/Double(max(aa.count,bb.count)))))}

extension Color{init(hex:Int){let r=Double((hex>>16)&0xff)/255,g=Double((hex>>8)&0xff)/255,b=Double(hex&0xff)/255;self.init(red:r,green:g,blue:b)}}

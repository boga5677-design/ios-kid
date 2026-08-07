import Foundation

struct KidsWord: Identifiable, Equatable, Hashable {
    let id = UUID()
    let category: String
    let symbol: String
    let english: String
    let chinese: String
}

enum PetLingoData {
    static let everyday: [KidsWord] = [
        .init(category: "生活用品", symbol: "🪥", english: "Toothbrush", chinese: "牙刷"),
        .init(category: "生活用品", symbol: "🧼", english: "Soap", chinese: "肥皂"),
        .init(category: "生活用品", symbol: "🥄", english: "Spoon", chinese: "湯匙"),
        .init(category: "生活用品", symbol: "🥤", english: "Cup", chinese: "杯子"),
        .init(category: "生活用品", symbol: "🪑", english: "Chair", chinese: "椅子"),
        .init(category: "生活用品", symbol: "🛏️", english: "Bed", chinese: "床"),
        .init(category: "生活用品", symbol: "📕", english: "Book", chinese: "書"),
        .init(category: "生活用品", symbol: "✏️", english: "Pencil", chinese: "鉛筆"),
        .init(category: "交通工具", symbol: "🚗", english: "Car", chinese: "汽車"),
        .init(category: "交通工具", symbol: "🚌", english: "Bus", chinese: "公車"),
        .init(category: "交通工具", symbol: "🚲", english: "Bicycle", chinese: "腳踏車"),
        .init(category: "交通工具", symbol: "🚆", english: "Train", chinese: "火車"),
        .init(category: "交通工具", symbol: "✈️", english: "Airplane", chinese: "飛機"),
        .init(category: "交通工具", symbol: "🚒", english: "Fire truck", chinese: "消防車"),
        .init(category: "動物", symbol: "🐶", english: "Dog", chinese: "狗"),
        .init(category: "動物", symbol: "🐱", english: "Cat", chinese: "貓"),
        .init(category: "動物", symbol: "🐰", english: "Rabbit", chinese: "兔子"),
        .init(category: "動物", symbol: "🐻", english: "Bear", chinese: "熊"),
        .init(category: "動物", symbol: "🐼", english: "Panda", chinese: "熊貓"),
        .init(category: "動物", symbol: "🦁", english: "Lion", chinese: "獅子"),
        .init(category: "動物", symbol: "🐯", english: "Tiger", chinese: "老虎"),
        .init(category: "動物", symbol: "🐘", english: "Elephant", chinese: "大象"),
        .init(category: "植物", symbol: "🌳", english: "Tree", chinese: "樹"),
        .init(category: "植物", symbol: "🌿", english: "Leaf", chinese: "葉子"),
        .init(category: "植物", symbol: "🌻", english: "Sunflower", chinese: "向日葵"),
        .init(category: "植物", symbol: "🌷", english: "Tulip", chinese: "鬱金香"),
        .init(category: "植物", symbol: "🌵", english: "Cactus", chinese: "仙人掌"),
        .init(category: "食物", symbol: "🍚", english: "Rice", chinese: "飯"),
        .init(category: "食物", symbol: "🍞", english: "Bread", chinese: "麵包"),
        .init(category: "食物", symbol: "🥚", english: "Egg", chinese: "蛋"),
        .init(category: "食物", symbol: "🥛", english: "Milk", chinese: "牛奶"),
        .init(category: "食物", symbol: "🍜", english: "Noodles", chinese: "麵"),
        .init(category: "水果", symbol: "🍎", english: "Apple", chinese: "蘋果"),
        .init(category: "水果", symbol: "🍌", english: "Banana", chinese: "香蕉"),
        .init(category: "水果", symbol: "🍊", english: "Orange", chinese: "橘子"),
        .init(category: "水果", symbol: "🍇", english: "Grapes", chinese: "葡萄"),
        .init(category: "水果", symbol: "🍓", english: "Strawberry", chinese: "草莓"),
        .init(category: "水果", symbol: "🍉", english: "Watermelon", chinese: "西瓜"),
        .init(category: "蔬菜", symbol: "🥕", english: "Carrot", chinese: "胡蘿蔔"),
        .init(category: "蔬菜", symbol: "🥦", english: "Broccoli", chinese: "花椰菜"),
        .init(category: "蔬菜", symbol: "🌽", english: "Corn", chinese: "玉米"),
        .init(category: "蔬菜", symbol: "🍅", english: "Tomato", chinese: "番茄"),
        .init(category: "蔬菜", symbol: "🥔", english: "Potato", chinese: "馬鈴薯"),
        .init(category: "運動", symbol: "⚽", english: "Soccer", chinese: "足球"),
        .init(category: "運動", symbol: "🏀", english: "Basketball", chinese: "籃球"),
        .init(category: "運動", symbol: "⚾", english: "Baseball", chinese: "棒球"),
        .init(category: "運動", symbol: "🏊", english: "Swimming", chinese: "游泳"),
        .init(category: "動作", symbol: "🚶", english: "Walk", chinese: "走路"),
        .init(category: "動作", symbol: "🏃", english: "Run", chinese: "跑"),
        .init(category: "動作", symbol: "👏", english: "Clap", chinese: "拍手"),
        .init(category: "動作", symbol: "👋", english: "Wave", chinese: "揮手"),
        .init(category: "動作", symbol: "😴", english: "Sleep", chinese: "睡覺"),
        .init(category: "身體部位", symbol: "👀", english: "Eyes", chinese: "眼睛"),
        .init(category: "身體部位", symbol: "👂", english: "Ears", chinese: "耳朵"),
        .init(category: "身體部位", symbol: "👃", english: "Nose", chinese: "鼻子"),
        .init(category: "身體部位", symbol: "👄", english: "Mouth", chinese: "嘴巴"),
        .init(category: "身體部位", symbol: "✋", english: "Hand", chinese: "手"),
        .init(category: "身體部位", symbol: "🦶", english: "Foot", chinese: "腳"),
        .init(category: "顏色", symbol: "🔴", english: "Red", chinese: "紅色"),
        .init(category: "顏色", symbol: "🔵", english: "Blue", chinese: "藍色"),
        .init(category: "顏色", symbol: "🟡", english: "Yellow", chinese: "黃色"),
        .init(category: "顏色", symbol: "🟢", english: "Green", chinese: "綠色"),
        .init(category: "顏色", symbol: "🟣", english: "Purple", chinese: "紫色")
    ]

    static let numbers: [KidsWord] = (0...100).map {
        KidsWord(category: "數字", symbol: "🔢", english: numberEnglish($0), chinese: "\($0)")
    }

    static let words = everyday + numbers

    static let categories = [
        ("生活用品", "🧸"), ("交通工具", "🚗"), ("動物", "🐶"), ("植物", "🌻"),
        ("食物", "🍞"), ("水果", "🍎"), ("蔬菜", "🥕"), ("運動", "⚽"),
        ("動作", "🏃"), ("身體部位", "👀"), ("數字", "🔢"), ("顏色", "🌈")
    ]

    private static func numberEnglish(_ n: Int) -> String {
        let ones = ["Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"]
        let teens = [10:"Ten",11:"Eleven",12:"Twelve",13:"Thirteen",14:"Fourteen",15:"Fifteen",
                     16:"Sixteen",17:"Seventeen",18:"Eighteen",19:"Nineteen"]
        let tens = [20:"Twenty",30:"Thirty",40:"Forty",50:"Fifty",60:"Sixty",70:"Seventy",80:"Eighty",90:"Ninety"]
        if n < 10 { return ones[n] }
        if let teen = teens[n] { return teen }
        if n == 100 { return "One hundred" }
        if n % 10 == 0 { return tens[n]! }
        return "\(tens[n / 10 * 10]!)-\(ones[n % 10].lowercased())"
    }
}

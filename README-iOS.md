# PetLingo iOS 2.2 — Android Matched

這版不是單純繼續修改舊 iOS UI，而是以你上傳的 Android 6.0 APK 當成視覺基準重新對齊。

## 已對齊

- iOS 使用 Android APK 內同一份 `home_hero.png`
- iOS 使用 Android APK 內同一份：
  - `tortoiseshell.png`
  - `tabby.png`
  - `chihuahua.png`
- 首頁背景、Hero 卡、按鈕顏色、圓角、排列改為 Android Compose 版本結構
- 首頁順序：
  1. Hero 主視覺
  2. 星星／關卡／每日進度
  3. 寶箱＋星星闖關進度
  4. 開始闖關
  5. 單字學習
  6. AI 發音
  7. 每日任務
  8. 寵物成長
  9. 家長模式
  10. 我的成就
- 單字分類從原本 iOS 的兩欄 Grid 改成 Android 版的大型直式卡片
- 學習頁改成大型白色單字卡
- 測驗頁改為 Android 版的 2×2 大圖片選項
- 測驗進入與換題後 0.5 秒自動朗讀，喇叭重播保留
- 20 關直式關卡列表對齊 Android
- GitHub Actions 保留 generic iOS Simulator 修正版

版本：2.2

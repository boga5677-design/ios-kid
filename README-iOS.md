# PetLingo Kids iOS 第一版

這是與 Android PetLingo Kids 並存的原生 SwiftUI iOS 第一版。

## 第一版已包含

- 使用 Android 6.0.1 的完整 `home_hero.png` 主視覺，不再拆切三隻寵物
- 黑糖、偶貴、熊熊三區點擊互動
- 5 歲兒童生活化英文分類
- 數字 0–100
- 大字／大圖單字卡
- 英文 TTS 發音
- 20 關闖關
- 進入題目後約 0.5 秒自動朗讀
- 喇叭按鈕保留
- 星星與寶箱進度
- 每日 5 字任務
- 家長模式
- 寵物成長
- 成就頁

## GitHub Actions

本專案使用 `XcodeGen`，所以不需要手動維護 `.xcodeproj`。

上傳 `ios/` 與 `.github/workflows/ios.yml` 後：

1. 到 GitHub → Actions。
2. 執行 `Build PetLingo iOS v1`。
3. macOS runner 會安裝 XcodeGen。
4. 自動產生 Xcode project。
5. 編譯 iOS Simulator App。
6. 成功後在 Artifacts 下載 `PetLingo-iOS-v1-Simulator`。

> Simulator 版本不是可直接安裝到實體 iPhone 的 IPA。實體 iPhone / TestFlight 需要 Apple Developer 簽章，後續再加入。

## GitHub 分支

建議建立：

`petlingo-ios-v1`

再把此 ZIP 的 `ios` 目錄及 `.github/workflows/ios.yml` 上傳到該分支。

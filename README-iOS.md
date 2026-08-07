# PetLingo-ios-2.0

這版是直接用目前 `ios-kid` 專案重整，不需要建立新的 GitHub Repository。

## 你要怎麼用

最簡單的方法：

1. 下載本 ZIP。
2. 解壓縮。
3. 把解壓後的全部內容直接上傳到目前的 `ios-kid` Repository 根目錄。
4. 遇到同名檔案時全部覆蓋。
5. 特別確認 `.github/workflows/` 內只剩 `ios.yml`。
6. Commit 後到 GitHub Actions 執行：
   `Build PetLingo iOS 2.0`

## 本版重要修正

- 已刪除 GitHub 預設 `iOS starter workflow`
- `.github/workflows/` 只保留一個 `ios.yml`
- 不再使用 `xcrun xctrace`
- 不再使用 `build-for-testing`
- 不再指定 `iPhone 16e`
- 不再使用 `OS:latest`
- 改用：
  `-destination 'generic/platform=iOS Simulator'`
- 成功後會產生 Artifact：
  `PetLingo-ios-2.0-Simulator`

## 正確 Repository 根目錄

應該直接看到：

- `.github/`
- `PetLingoKids.xcodeproj/`
- `ios/`
- `README-iOS.md`

不要再多包一層資料夾。

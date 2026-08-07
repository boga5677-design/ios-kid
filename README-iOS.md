# PetLingo-ios-1.1.1

這版專門處理 GitHub 仍在執行舊版「iOS starter workflow」的問題。

你貼出的錯誤中還在執行：

`xcodebuild build-for-testing ... -destination "platform=iOS Simulator,name=iPhone 16e"`

這不是 PetLingo 1.1 的新版 Workflow；它是 GitHub 預設 iOS starter workflow 的舊 Build/Test 流程。

## 1.1.1 做的修正

- `.github/workflows/ios.yml`
  - 唯一正式自動建置 Workflow
  - 使用 `generic/platform=iOS Simulator`
  - 不指定 iPhone 16e
  - 不使用 OS:latest
  - 不執行 build-for-testing
  - 直接 `clean build`
- 額外放入並覆蓋常見舊 Workflow 名稱：
  - `swift.yml`
  - `xcode.yml`
  - `build.yml`
- 上述三個檔案改成「只能手動執行」的停用 Workflow，因此不會再在 push 時跑舊的 iPhone 16e 流程。

## 上傳

ZIP 解壓後，請直接把所有內容上傳到 Repository 根目錄，並確認 GitHub 詢問是否取代既有檔案時選擇取代。

正確自動執行的 Action 名稱應為：

`Build PetLingo iOS 1.1.1`

建置 Log 應看到：

`-destination generic/platform=iOS Simulator`

如果仍看到：

`build-for-testing`
或
`name=iPhone 16e`

代表 Repository 還有另一個舊 `.github/workflows/*.yml` 沒有被覆蓋，需要刪除該舊 Workflow。

# PetLingo-ios-2.0.1

這份 ZIP 是直接從你剛上傳的 `ios-kid-main (2).zip` 修正。

我已確認你上傳的 Repository ZIP 裡的 `.github/workflows/ios.yml`
仍是 GitHub 預設的 iOS starter workflow，所以才會一直跑舊的模擬器選擇流程。

## 這版處理方式

- 刪除 `.github/workflows/` 內所有既有 workflow
- 只保留一個新的 `.github/workflows/ios.yml`
- Action 名稱固定為 `Build PetLingo iOS 2.0.1`
- 使用 `generic/platform=iOS Simulator`
- 成功後產生 `PetLingo-ios-2.0.1-Simulator`
- 新增 `WORKFLOW-FIX-2.0.1.txt` 作為上傳成功標記

## 上傳後請確認

GitHub Repository 根目錄必須看到：

`WORKFLOW-FIX-2.0.1.txt`

並且 `.github/workflows/ios.yml` 開頭必須是：

`name: Build PetLingo iOS 2.0.1`

# PetLingo-ios-1.0.1

這版修正 GitHub Actions 錯誤：

`The directory ... does not contain an Xcode project, workspace or package.`

## 修正方式

上一版只有 `project.yml`，必須先用 XcodeGen 產生 `.xcodeproj`；但 GitHub 的 scheme 掃描步驟在 XcodeGen 之前就執行，因此失敗。

1.0.1 已直接把真正的 `PetLingoKids.xcodeproj` 放在 Repository 根目錄，所以：

```bash
xcodebuild -list -json
```

在 repo 根目錄即可找到 Xcode project。

### 上傳 GitHub 時

ZIP 解壓後，必須讓 GitHub Repository 根目錄直接看到：

- `PetLingoKids.xcodeproj/`
- `ios/`
- `.github/`
- `README-iOS.md`

不要再多包一層 `PetLingo-ios-1.0.1/` 資料夾。

Workflow 會直接使用：

```bash
xcodebuild -project PetLingoKids.xcodeproj -scheme PetLingoKids ...
```

不再依賴 XcodeGen。

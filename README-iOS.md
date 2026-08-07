# PetLingo-ios-1.1

這版修正 GitHub Actions 找不到指定 iOS Simulator 的問題。

原錯誤：
`Unable to find a device matching the provided destination specifier`

修正方式：
- 不再指定 `iPhone 16e`
- 不再依賴 `OS:latest`
- 改用：
  `-destination 'generic/platform=iOS Simulator'`

GitHub Actions 會先列出可用 Simulator，再直接以 generic iOS Simulator 建置，因此不會因 GitHub runner 的機型或 OS 版本不同而失敗。

版本：
- CFBundleShortVersionString = 1.1
- CFBundleVersion = 2

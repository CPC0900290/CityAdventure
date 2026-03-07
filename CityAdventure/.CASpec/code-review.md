# CityAdventure Code Review

> 產生日期：2026-03-07
> 審查範圍：CityAdventure/CityAdventure/ 所有 Swift 原始碼

---

## 修復進度總覽

| # | 嚴重程度 | 問題描述 | 狀態 |
|---|----------|----------|------|
| 1 | 🔴 嚴重 | Force Unwrap — `view.window!` | ⬜ 待修復 |
| 2 | 🔴 嚴重 | Force Unwrap — `error!.localizedDescription` | ⬜ 待修復 |
| 3 | 🔴 嚴重 | Force Unwrap — `videoPreviewLayer!` | ⬜ 待修復 |
| 4 | 🔴 嚴重 | Force Unwrap — `taskRouteOverlay!` / `originalCoordinate!` | ⬜ 待修復 |
| 5 | 🔴 嚴重 | Force Unwrap — `availableDevices!` / `pixelBuffer!` | ⬜ 待修復 |
| 6 | 🔴 嚴重 | fatalError — 登入流程 nonce / callback 失敗 | ⬜ 待修復 |
| 7 | 🔴 嚴重 | fatalError — 語音授權失敗 (`SpeechViewModel`) | ⬜ 待修復 |
| 8 | 🔴 嚴重 | 陣列無邊界檢查 `tasks[0/1/2]` — IndexOutOfRange Crash | ⬜ 待修復 |
| 9 | 🟠 高 | Memory Leak — Capture Session 未在 deinit 釋放 | ⬜ 待修復 |
| 10 | 🟠 高 | Memory Leak — `viewModel.setupLocationManager(self)` 循環參考風險 | ⬜ 待修復 |
| 11 | 🟠 高 | Empty catch block — 錯誤被完全吞掉 (`AuthenticationViewModel` L287) | ⬜ 待修復 |
| 12 | 🟡 中 | `UserDefaults()` 應改為 `UserDefaults.standard` | ⬜ 待修復 |
| 13 | 🟡 中 | `finishedEpisodes` 未初始化，`.append()` 靜默失敗 | ⬜ 待修復 |
| 14 | 🟡 中 | `getFilteredDocumentRef()` 函式主體為空，未實作 | ⬜ 待修復 |

---

## 詳細說明

### #1 Force Unwrap — `view.window!`
**檔案：** `View/Login/LoginViewController.swift:151`
```swift
// 問題
return view.window!

// 建議
guard let window = view.window else { return nil }
return window
```

---

### #2 Force Unwrap — `error!.localizedDescription`
**檔案：** `View/Login/LoginViewController.swift:160`
```swift
// 問題
"\(String(describing: error!.localizedDescription))"

// 建議
error?.localizedDescription ?? "未知錯誤"
```

---

### #3 Force Unwrap — `videoPreviewLayer!`
**檔案：** `View/FirstTask/ScannerViewController.swift:94`
```swift
// 問題
self.view.layer.addSublayer(videoPreviewLayer!)

// 建議
guard let layer = videoPreviewLayer else { return }
self.view.layer.addSublayer(layer)
```

---

### #4 Force Unwrap — `taskRouteOverlay!` / `originalCoordinate!`
**檔案：** `View/SecondTask/SecondTaskViewController.swift:136, 173`
```swift
// 問題
self.mapView.addOverlay(self.taskRouteOverlay!, level: .aboveRoads)
var area = [originalCoordinate!, currentLocation.coordinate]

// 建議
guard let overlay = taskRouteOverlay else { return }
self.mapView.addOverlay(overlay, level: .aboveRoads)

guard let coord = originalCoordinate else { return }
var area = [coord, currentLocation.coordinate]
```

---

### #5 Force Unwrap — `availableDevices!` / `pixelBuffer!`
**檔案：** `View/ThirdTask/RecognizerViewController.swift:40, 82`
```swift
// 問題
let input = try AVCaptureDeviceInput(device: availableDevices!)
let input = FoodFromTaiwanInput(image: pixelBuffer!)

// 建議
guard let devices = availableDevices else { return }
let input = try AVCaptureDeviceInput(device: devices)

guard let buffer = pixelBuffer else { return }
let input = FoodFromTaiwanInput(image: buffer)
```

---

### #6 fatalError — 登入流程
**檔案：**
- `View/Login/LoginViewController.swift:120, 194`
- `ViewModel/ProfileViewModel.swift:95`
- `ViewModel/AuthenticationViewModel.swift:246, 315`

```swift
// 問題
fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
fatalError("Invalid state: A login callback was received, but no login request was sent.")

// 建議：改用 throw 或顯示錯誤 Alert，避免 app crash
```

---

### #7 fatalError — 語音授權失敗
**檔案：** `ViewModel/SpeechViewModel.swift:38`
```swift
// 問題
fatalError("Unknown Fail to get authorization from user")

// 建議
print("Speech recognition authorization failed with unknown status")
// 或顯示 Alert 提示用戶
```

---

### #8 陣列無邊界檢查
**檔案：** `View/Task/MapViewController.swift:35-40`
```swift
// 問題
let firstTaskAddress = tasks[0].locationAddress
let secondTaskAddress = tasks[1].locationAddress
let thirdTaskAddress = tasks[2].locationAddress

// 建議
guard tasks.count >= 3 else { return }
let firstTaskAddress = tasks[0].locationAddress
let secondTaskAddress = tasks[1].locationAddress
let thirdTaskAddress = tasks[2].locationAddress
```

---

### #9 Memory Leak — Capture Session 未釋放
**檔案：** `View/FirstTask/ScannerViewController.swift`
```swift
// 建議：新增 deinit 或 viewWillDisappear
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    captureSession.stopRunning()
}
```

---

### #10 Memory Leak — Location Manager 循環參考
**檔案：** `View/EpisodeDetail/EpisodeDetailViewController.swift:58`
```swift
// 建議：確認 setupLocationManager 中使用 [weak self]
viewModel.setupLocationManager(self)
```

---

### #11 Empty catch block
**檔案：** `ViewModel/AuthenticationViewModel.swift:287`
```swift
// 問題
} catch { }

// 建議
} catch {
    print("Authentication error: \(error.localizedDescription)")
}
```

---

### #12 `UserDefaults()` 應改為 `UserDefaults.standard`
**檔案：**
- `View/Login/LoginViewController.swift:17`
- `View/Home/HomeViewController.swift:16`

```swift
// 問題
private let userDefault = UserDefaults()

// 建議
private let userDefault = UserDefaults.standard
```

---

### #13 `finishedEpisodes` 未初始化
**檔案：** `View/Profile/ProfileViewController.swift:20`
```swift
// 問題
var finishedEpisodes: [Episode]?
// ... 之後 self.finishedEpisodes?.append(episode) 靜默失敗

// 建議
var finishedEpisodes: [Episode] = []
```

---

### #14 `getFilteredDocumentRef()` 未實作
**檔案：** `Manager/FireStoreManager.swift:127`
```swift
// 問題：函式主體為空
func getFilteredDocumentRef() {
    // 完全未實作
}

// 建議：實作或移除此函式
```

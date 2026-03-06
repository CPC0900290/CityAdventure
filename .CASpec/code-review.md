# CityAdventure 程式碼審查報告

> 審查日期：2026-03-06
> 審查分支：`master` / `claude/review-branch-changes-hEtzU`

---

## 🔴 嚴重問題

### 1. 測試中硬寫真實 Firebase 資料
**檔案**：`CityAdventureTests/EpisodeViewControllerTests.swift:24`

真實的 Firebase user UID 與 episode ID 被直接寫入測試並 commit 進 git。

```swift
// 問題程式碼
mockUserDefaults.set("EKTfK9RUZaRjSNN13PhUJPmfYJx1", forKey: "uid")
// episode ID: "84HPfQwsnCEjg56oMvXd"
```

**已修復**：改為 `"mock-user-id-for-testing"` / `"mock-episode-id-for-testing"`

---

### 2. Unit Test 直接呼叫真實 Firebase
**檔案**：`CityAdventureTests/EpisodeViewControllerTests.swift:59-70`

`testConfigureTaskStatus()` 對 Firebase 發出實際網路請求，測試結果依賴網路狀態和 Firebase 資料，不穩定且無法隔離。

**已修復**：
- 新增 `FireStoreManaging` protocol
- `EpisodeViewModel` 改為注入 `fireStoreManager`
- 抽出 `configureTaskStatus(with profile: Profile)` helper
- 測試改為直接傳入 mock Profile，不打網路、同步執行

---

## 🟠 記憶體洩漏

### 3. SpeechViewModel installTap 強引用 self
**檔案**：`CityAdventure/ViewModel/SpeechViewModel.swift`

`inputNode.installTap` 的 closure 中直接用 `self`，沒有使用 `[weak self]`，可能造成 retain cycle。

```swift
// 問題程式碼
inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
  self.recognitionRequest?.append(buffer)
}

// 建議修正
inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
  self?.recognitionRequest?.append(buffer)
}
```

---

### 4. SuccessViewModel Firebase callback 強引用 self
**檔案**：`CityAdventure/ViewModel/SuccessViewModel.swift:30, 42, 69`

多處 Firebase 非同步 callback 中使用 `self.xxx` 而未標記 `[weak self]`。若 ViewController 被 dismiss 但 Firebase 回呼尚未完成，會導致 ViewModel 被 retain 住無法釋放。

```swift
// 建議修正（以 fetchProfile 為例）
FireStoreManager.shared.filterDocument(...) { [weak self] document in
  guard let self = self else { return }
  // ...
}
```

---

## 🟡 未完成 / 無用程式碼

### 5. getFilteredDocumentRef 為空函式
**檔案**：`CityAdventure/Manager/FireStoreManager.swift:127-132`

```swift
func getFilteredDocumentRef(collection: String,
                            id: String,
                            field: String,
                            sendDocRef: @escaping (DocumentReference) -> Void) {
  // 完全沒有實作
}
```

應實作或移除。

---

### 6. TaskStatus enum 定義但從未使用
**檔案**：`CityAdventure/Model/Profile.swift:25-29`

```swift
enum TaskStatus: String, Hashable, Codable {
  case completed
  case inProgress = "in-progress"
  case notStarted = "not-started"
}
```

`AdventuringEpisode.taskStatus` 實際使用 `[Bool]`，此 enum 沒有任何地方引用，應移除或統一資料型別。

---

### 7. SuccessViewModel.profile 空的 didSet
**檔案**：`CityAdventure/ViewModel/SuccessViewModel.swift:12-14`

```swift
var profile: Profile? {
  didSet { }  // 無意義的空 observer
}
```

應移除 `didSet`，或補上實際邏輯。

---

### 8. 多處 Commented-out 程式碼
**檔案**：
- `CityAdventure/View/Task/EpisodeViewController.swift:208-209, 231, 309`
- `CityAdventure/ViewModel/SecondTaskViewModel.swift:32`

遺留的 commented-out 程式碼應整理移除，避免混淆維護者。

---

## 🟡 邏輯問題

### 9. Task B 完成判斷可被無限刷（去重缺失）
**檔案**：`CityAdventure/ViewModel/SecondTaskViewModel.swift:49-63`

每次 location update 時，若用戶在某地點 20 公尺內，就會執行 `configIsFinishedRoute()` 累加 `arrivedTaskCount`。沒有記錄「已抵達過」的地點，若用戶在同一點停留，會持續重複計數，導致誤判任務完成。

**建議修正**：記錄已計算過的地點 index，避免重複計數。

---

### 10. fetchProfile 回傳值從未被使用
**檔案**：`CityAdventure/ViewModel/EpisodeViewModel.swift:27-29`

```swift
var tasks: [TaskLocations]? {
  didSet {
    fetchAnnotationsAndCoordinate()
    fetchProfile()   // ← 抓到的 profile 存到 self.user，但 self.user 沒有任何地方讀取
    getDistance()
  }
}
```

`fetchProfile()` 所取得的資料沒有任何實際用途，應釐清是否需要此呼叫。

---

### 11. lastPage() 導航邏輯重複
**檔案**：`CityAdventure/View/Task/EpisodeViewController.swift:286-296`

```swift
self.navigationController?.popToRootViewController(animated: true)   // 已回到 root
guard let controllers = self.navigationController?.viewControllers else { return }
for controller in controllers {   // 此時 controllers 只剩 root，for loop 多餘
  if let homeVC = controller as? HomeViewController {
    self.navigationController?.popToViewController(homeVC, animated: true)
  }
}
```

`popToRootViewController` 執行後 navigation stack 已清空，後續的 for loop 是多餘的。應選擇其中一種方式，建議直接使用 `popToViewController`。

---

## 🔵 架構建議

### 12. UserDefaults key 字串散落各處
**相關檔案**：`HomeViewModel.swift`, `EpisodeViewModel.swift`, `SuccessViewModel.swift`

所有 ViewModel 都直接使用字串 `"uid"` 取得用戶 ID，沒有集中定義。若 key 名稱改變，需逐一修改所有地方。

**建議**：建立常數統一管理，例如：
```swift
enum UserDefaultsKey {
  static let uid = "uid"
}
```

---

### 13. FireStoreManager 錯誤處理不完整
**檔案**：`CityAdventure/Manager/FireStoreManager.swift`

幾乎所有 Firebase 錯誤只 `print(error)`，沒有透過 callback 或 delegate 通知 UI 層，用戶無法得知操作失敗。

---

### 14. UserDefaults() 應改為 UserDefaults.standard
**檔案**：`HomeViewModel.swift:15`, `EpisodeViewModel.swift:18`, `SuccessViewModel.swift:10`

```swift
// 現況（功能上等同，但語意不清）
let userDefault = UserDefaults()

// 建議
let userDefault = UserDefaults.standard
```

---

## 修復進度

| # | 問題 | 狀態 |
|---|------|------|
| 1 | 測試中硬寫真實 Firebase ID | ✅ 已修復 |
| 2 | Unit Test 呼叫真實 Firebase | ✅ 已修復 |
| 3 | SpeechViewModel retain cycle | ⬜ 待修復 |
| 4 | SuccessViewModel retain cycle | ⬜ 待修復 |
| 5 | getFilteredDocumentRef 空函式 | ⬜ 待修復 |
| 6 | TaskStatus enum 未使用 | ⬜ 待修復 |
| 7 | SuccessViewModel 空 didSet | ⬜ 待修復 |
| 8 | Commented-out 程式碼 | ⬜ 待修復 |
| 9 | Task B 完成判斷去重缺失 | ⬜ 待修復 |
| 10 | fetchProfile 結果未使用 | ⬜ 待修復 |
| 11 | lastPage() 邏輯重複 | ⬜ 待修復 |
| 12 | UserDefaults key 分散 | ⬜ 待修復 |
| 13 | Firebase 錯誤未通知 UI | ⬜ 待修復 |
| 14 | UserDefaults() 應用 .standard | ⬜ 待修復 |
